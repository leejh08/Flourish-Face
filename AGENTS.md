# Flourish Face — Project Reference

안면 마비 재활을 위한 iOS 앱. Swift Student Challenge 2025 Distinguished Winner.
실제 사용자에게 App Store 배포를 목표로 한다.

---

## 목적 & 포지셔닝

- **대상**: 안면 마비(Bell's palsy, 뇌졸중 후유증 등) 경험자
- **핵심 가치**: 매일 짧은 얼굴 운동 루틴 + 꽃 성장 보상으로 꾸준한 습관 형성
- **의료 클레임 없음**: "치료"가 아닌 "gentle daily practice" 프레이밍 유지 (App Store 필수)
- **완전 오프라인**: 네트워크 호출 없음. 모든 데이터 기기 로컬 저장

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Swift 5 (Swift Tools Version 6.0) |
| UI | SwiftUI |
| 상태 관리 | `@Observable` + `@AppStorage` + SwiftData |
| 얼굴 추적 | ARKit (`ARFaceTrackingConfiguration`) — TrueDepth 전용 |
| 퍼시스턴스 | SwiftData (`GrowthSession`, `Flower`) + UserDefaults (`@AppStorage`) |
| 알림 | UserNotifications (매일 오후 8시 streak 리마인더) |
| 최소 배포 | iOS 18.0 / iPadOS 18.0 |
| 패키지 형식 | Swift Package Manager (.swiftpm) — Xcode에서 열어서 빌드 |
| 번들 ID | `com.jh.Flourish-Face` |
| Team ID | `3DFKU6DVCR` |
| 로컬라이제이션 | en (기본), ko, ja, zh-Hans |

**TrueDepth 필수**: `ARFaceTrackingConfiguration.isSupported`가 false인 기기(Face ID 없는 구형 iPhone, 대부분의 iPad)는 운동 세션 진입 불가.

---

## 프로젝트 구조

```
Flourish_Face.swiftpm/
├── MyApp.swift                        # @main, ModelContainer 초기화
├── Package.swift                      # 번들 ID, Team ID, iOS 버전, 지원 기기
├── Resources/
│   ├── Info.plist                     # NSCameraUsageDescription, 화면 방향
│   └── Localizable.xcstrings          # 모든 유저 노출 문자열 (4개 언어)
│
├── Models/
│   ├── AppStorageKeys.swift           # UserDefaults 키 상수 + 날짜/인코딩 헬퍼
│   ├── DailyProgressState.swift       # 오늘 진행상태 계산 로직 (순수 값 타입)
│   ├── TrackingConfig.swift           # 추적 파라미터 상수 (threshold, holdRequired 등)
│   ├── Delay.swift                    # 세션 내 타이밍 상수
│   ├── AppShellActions.swift          # AppRootShellState 액션
│   ├── Enums/
│   │   ├── FaceExercise.swift         # 5가지 운동 enum (rawValue = SwiftData 키)
│   │   ├── Difficulty.swift           # basic(3개) / advanced(5개)
│   │   ├── AffectedSide.swift         # left / right / none
│   │   ├── Chapter.swift              # 성장 단계 (seed → ...)
│   │   ├── SessionPhase.swift         # intro→guide→ready→tracking→setRest
│   │   ├── FlowerType.swift           # 꽃 종류 enum
│   │   └── PlantStage.swift           # 식물 성장 단계
│   ├── Session/
│   │   ├── GrowthSession.swift        # SwiftData @Model: 완료한 운동 1건
│   │   └── SessionConfig.swift        # 세션 시작 파라미터
│   └── Flower/
│       └── FlowerModel.swift          # SwiftData @Model: 수집한 꽃 1개
│
├── Managers/
│   ├── FaceTracking/
│   │   ├── FaceTrackingManager.swift          # @Observable: blend shape 프로퍼티 + ARSCNViewDelegate
│   │   ├── FaceTrackingManager+ARSession.swift # startTracking / stopTracking
│   │   ├── FaceTrackingManager+Delegate.swift  # ARSCNViewDelegate: blend shape → growthRate
│   │   ├── FaceTrackingManager+Logic.swift     # processFrame: threshold 판정 + hold 누적
│   │   └── (Vision fallback 없음 — ARKit 전용)
│   └── NotificationManager.swift      # 일일 오후 8시 리마인더 (idempotent)
│
├── Components/
│   ├── AR/ARFaceView.swift            # UIViewRepresentable, ARSCNView 래핑
│   ├── Guide/                         # 대칭 가이드 오버레이, 랜드마크 표시
│   ├── Plant/                         # GardenView, PlantView (SwiftUI 드로잉)
│   ├── Particles/ParticleEffectView.swift
│   └── Shapes/WaveShape.swift
│
└── Views/
    ├── AppRootView.swift              # 최상위 라우팅 (intro→onboarding→main)
    ├── Session/
    │   ├── SessionView.swift          # 세션 진입점, FaceTrackingManager 소유
    │   ├── SessionOrchestrator.swift  # 세션 페이즈 FSM + 타이밍 스케줄
    │   ├── SessionView+Phases.swift
    │   ├── SessionView+DataSave.swift
    │   ├── SessionIntroView.swift
    │   ├── SessionGuideView.swift
    │   ├── SessionTrackingView.swift
    │   ├── SessionSetRestView.swift
    │   └── SessionCalibrateView.swift
    ├── Home/                          # HomeView, 진행 링, 운동/세트 선택 시트
    ├── Collection/                    # 꽃 컬렉션 그리드 + 상세
    ├── Log/                           # 운동 기록, 통계, 설정
    ├── Onboarding/                    # 영향받은 쪽 선택 + 난이도 선택
    ├── Intro/IntroView.swift          # 최초 앱 소개 (한 번만 표시)
    └── Common/                        # RestView(세션 완료), FlowerPickerView
```

---

## 앱 라우팅 흐름

```
AppRootView
  ├── hasCompletedIntro = false  → IntroView
  ├── hasCompletedOnboarding = false → OnboardingView
  └── 둘 다 true → TabView
        ├── [0] HomeView      (house.fill)
        ├── [1] CollectionView (star.fill)
        └── [2] LogView        (chart.bar.fill)
```

**HomeView → SessionView** 진입 시 `NavigationStack` 사용. SessionView는 TabBar/NavigationBar 완전히 숨긴다.

---

## 세션 페이즈 FSM

```
.intro → .guide → .ready → .tracking → .setRest → (반복) → showResult = true
```

- `SessionOrchestrator`가 페이즈 전환 및 모든 타이밍 (`DispatchWorkItem`) 관리
- `FaceTrackingManager.setCompleted = true`가 세트 완료 트리거
- 마지막 세트 완료 → `saveSession()` 호출 → `showResult = true` → `RestView` fullScreenCover

---

## 얼굴 추적 시스템

```
ARSCNViewDelegate.renderer(_:didUpdate:for:)
  → FaceTrackingManager+Delegate  (blend shape 추출)
  → FaceTrackingManager+Logic.processFrame(deltaTime:)
      ├── 운동별 sensitivity 적용 → growthRate 계산
      ├── growthRate > threshold(0.5) → aboveThresholdDuration 누적
      ├── aboveThresholdDuration >= holdRequired(4.0s) → setCompleted = true
      └── holdProgress = min(1.0, aboveThresholdDuration / 4.0)
```

**운동별 blend shape 매핑** (`TrackingConfig`의 sensitivity 참고):
- `browRaise` → `browInnerUp` (sensitivity 3.0)
- `smile` → `mouthSmileLeft/Right` 평균 (sensitivity 4.0)
- `eyeClosure` → `eyeBlinkLeft/Right` 평균 (sensitivity 2.5)
- `jawOpen` → `jawOpen` (sensitivity 3.0)
- `mouthFrown` → `mouthFrownLeft/Right` 평균 (sensitivity 4.0)

`affectedSide`가 설정된 경우 영향받은 쪽 값 vs 건강한 쪽 값 비교로 `mirrorProgress` 계산.

---

## 상태 관리

### AppStorage (UserDefaults)
| 키 | 타입 | 설명 |
|----|------|------|
| `todayCompletedExercisesData` | String | 오늘 완료 운동 rawValue, 콤마 구분 (예: `"0,1,2"`) |
| `lastExerciseDate` | String | `"yyyy-MM-dd"` 형식 |
| `totalGrowthPoints` | Double | 누적 성장 포인트 |
| `flowersEarned` | Int | 획득한 꽃 총 개수 |
| `pendingFlowerPick` | Bool | 꽃 선택 대기 중 여부 |
| `affectedSide` | AffectedSide | 영향받은 쪽 |
| `selectedDifficulty` | String | `Difficulty.rawValue` |
| `hasCompletedOnboarding` | Bool | 온보딩 완료 여부 |
| `hasCompletedIntro` | Bool | 인트로 완료 여부 |

### SwiftData Models
- `GrowthSession`: 운동 완료 1건 (`date: Date`, `exerciseRaw: Int`)
- `Flower`: 획득한 꽃 1개 (`id: UUID`, `type: FlowerType`, `earnedDate: Date`)

### DailyProgressState
순수 값 타입. AppStorage에서 읽어서 계산하고 다시 저장하는 패턴.
새 날짜가 되면 `normalizedForToday()`로 `completedExercisesData` 초기화.

---

## 운동 & 난이도

```swift
// FaceExercise.exercises(for:)
.basic    → [.browRaise, .smile, .eyeClosure]  // 3개
.advanced → FaceExercise.allCases              // 5개 전부
```

**`FaceExercise.rawValue`는 SwiftData의 안정적인 키다. enum case 순서 절대 변경 금지.**
순서를 바꿔야 할 경우 반드시 SwiftData migration plan과 함께 진행.

---

## 알림

`NotificationManager.shared`가 싱글턴.
- `requestPermission()`: `MyApp.init()`에서 호출 (→ 배포 전 defer 필요, TODO 참고)
- `scheduleStreakReminder()`: 매일 20:00 반복. idempotent (중복 등록 방지)
- `cancelStreakReminder()`: 오늘 운동 완료 시 호출

---

## 로컬라이제이션

`Resources/Localizable.xcstrings`에 모든 유저 노출 문자열.
`String(localized: "...")` 패턴 사용. 절대 하드코딩 금지.
지원 언어: **en(기본), ko, ja, zh-Hans**

---

## 핵심 불변 규칙 (위반 시 버그/데이터 손상)

1. **`FaceExercise.rawValue` 순서 변경 금지** — SwiftData `exerciseRaw` 컬럼과 직결
2. **`selectedDifficulty` AppStorage 기본값은 반드시 `Difficulty.basic.rawValue`** — `"none"` 쓰면 Difficulty 파싱 실패
3. **같은 View에 `.sheet` 2개 금지** — 두 번째 sheet가 무시됨. `if/else` 또는 별도 View로 분리
4. **ARFaceView는 TrueDepth 기기에서만 작동** — `ARFaceTrackingConfiguration.isSupported` 체크 없이 세션 진입 금지
5. **네트워크 호출 금지** — 완전 오프라인 앱. 외부 SDK, 분석 도구 추가 불가

---

## 개발 방법론 — Kent Beck TDD

> 참고: [Kent Beck Augmented Coding](https://velog.io/@qlgks1/Kent-Beck-Augmented-Coding) · [CLAUDE.md 원문](https://github.com/KentBeck/BPlusTree3/blob/ca80e4d85a99cd0af2effe717f709d43e80403bc/rust/docs/CLAUDE.md)

### TDD 사이클 (Red → Green → Refactor)

```
1. RED    — 실패하는 테스트를 먼저 작성한다
2. GREEN  — 테스트를 통과시키는 최소한의 코드만 구현한다
3. REFACTOR — 테스트가 초록인 상태에서만 구조를 개선한다
4. REPEAT — 다음 작은 기능으로 반복
```

- 한 번에 테스트 하나씩. 그 테스트를 통과시키고 나서 다음으로.
- 테스트 이름은 행동을 설명한다: `testBrowRaiseReturnsTrueWhenIntensityExceedsThreshold`
- 버그 수정 순서: API 레벨 실패 테스트 작성 → 버그를 재현하는 가장 작은 단위 테스트 작성 → 두 테스트 모두 통과

### Tidy First — 구조 변경과 행위 변경의 분리

Beck의 핵심 원칙: **한 커밋에 구조 변경(refactor)과 행위 변경(feat/fix)을 절대 섞지 않는다.**

| 구조 변경 (Structural) | 행위 변경 (Behavioral) |
|----------------------|----------------------|
| 이름 변경, 메서드 추출, 파일 이동 | 새 기능 추가, 버그 수정 |
| 동작이 바뀌지 않음 | 동작이 바뀜 |
| `refactor:` 커밋 | `feat:` / `fix:` 커밋 |

두 가지가 모두 필요할 때: **항상 구조 변경을 먼저** 완료하고 커밋한 뒤, 행위 변경을 별도 커밋으로.

### 커밋 규칙

모든 커밋은 아래 조건을 만족할 때만 한다:
1. **모든 테스트가 통과** (빌드 에러, 컴파일러 경고 없음)
2. **단일 논리 단위** — 한 커밋 = 한 가지 변경
3. 크고 드문 커밋보다 **작고 잦은 커밋**

---

## 커밋 컨벤션

형식: `<type>: <what changed>`

| 타입 | 용도 | Beck 분류 |
|------|------|-----------|
| `test:` | 실패 테스트 추가 (RED 단계) | — |
| `feat:` | 새 기능 구현 (GREEN 단계) | Behavioral |
| `fix:` | 버그 수정 | Behavioral |
| `refactor:` | 동작 변경 없는 구조 개선 | Structural |
| `chore:` | 빌드, 설정, 비코드 변경 | — |
| `docs:` | 문서, 주석 | — |

**핵심 규칙: `refactor:`와 `feat:`/`fix:`는 절대 같은 커밋에 오지 않는다.**

```
# 올바른 순서 예시
refactor: extract blend shape calculation into separate method
test: add failing test for Vision-based browRaise detection
feat: implement VisionBlendShapeCalculator.browRaise

# 틀린 예시 (구조+행위 혼합)
feat: refactor FaceTrackingManager and add Vision fallback  ← 금지
```

본문(body)은 선택. 이유가 비명백한 경우에만 추가.

---

## 개발 규칙

- 주석은 WHY가 비명백할 때만. WHAT 설명 주석 금지.
- 유저 노출 문자열은 반드시 `Localizable.xcstrings` 등록.
- 배포 빌드는 `Flourish_Face PROD.xcscheme` 사용.
- 실기기 테스트 필수 (Face ID 노치가 있는 iPhone). 시뮬레이터는 ARKit face tracking 미지원.
- SwiftData 스키마 변경 시 반드시 `VersionedSchema` + `SchemaMigrationPlan` 작성.
