# Flourish Face — Backlog

우선순위: 🔴 Critical → 🟠 High → 🟡 Medium → 🟢 Low  
담당: 👤 직접 (수동) / 🤖 Claude (코드)

---

## 🔴 배포 블로커 (제출 전 필수)

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| B-01 | `PrivacyInfo.xcprivacy` 파일 추가 (2024년 5월 이후 App Store 필수 요건) | 🤖 | 대기 |
| B-02 | App Store Connect — 번들 ID `com.jh.Flourish-Face` 등록 | 👤 | 대기 |
| B-03 | App Store Connect — 앱 레코드 생성 (이름, 카테고리: Health & Fitness) | 👤 | 대기 |
| B-04 | 개인정보처리방침 URL 등록 (카메라 사용 앱 필수) | 👤 | 대기 |
| B-05 | 지원 URL 등록 (GitHub Issues 페이지 등) | 👤 | 대기 |

---

## 🟠 High — iPhone 지원 (Vision fallback)

> 목표: TrueDepth 없는 iPhone (SE 등)에서도 운동 세션 사용 가능하도록

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| I-01 | `VisionFaceTracker.swift` — AVCaptureSession + VNDetectFaceLandmarksRequest 파이프라인 | 🤖 | ✅ 완료 |
| I-02 | `VisionBlendShapeCalculator.swift` — 랜드마크 → pseudo-blend-shape 수학 모듈 | 🤖 | ✅ 완료 |
| I-03 | `VisionCalibrationStore.swift` — 중립 얼굴 baseline UserDefaults 저장/로드 | 🤖 | ✅ 완료 |
| I-04 | `FaceTrackingManager` 수정 — `visionTracker` 프로퍼티 추가, stopTracking 통합 | 🤖 | ✅ 완료 |
| I-05 | `FaceTrackingManager+VisionSession.swift` — startVisionTracking | 🤖 | ✅ 완료 |
| I-06 | `ARFaceView.swift` 수정 — TrueDepth 없을 때 VisionPreviewView 표시 | 🤖 | ✅ 완료 |
| I-07 | `VisionPreviewView.swift` — AVCaptureVideoPreviewLayer UIView 서브클래스 | 🤖 | ✅ 완료 |
| I-08 | `SessionPhase.swift` — `.calibrate` 페이즈 추가 (Vision 전용) | 🤖 | 대기 |
| I-09 | `SessionCalibrateView.swift` — 중립 얼굴 캘리브레이션 모드 추가 | 🤖 | 대기 |
| I-10 | `SessionOrchestrator.swift` — Vision 모드 시 calibrate 페이즈 삽입 | 🤖 | 대기 |
| I-11 | Vision 전용 sensitivity/threshold 튜닝 (`TrackingConfig` 분기) | 🤖 | 대기 |
| I-12 | `unsupportedDeviceOverlay` 메시지 수정 ("iPad"만 언급 → 정확한 안내) | 🤖 | ✅ 완료 |
| I-13 | iPhone 폼팩터 레이아웃 검토 및 수정 (홈, 세션, 로그 화면) | 👤 | 대기 (실기기 필요) |

---

## 🟠 High — UX 버그 수정

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| U-01 | `LogView` — `onDisappear { appeared = false }` 제거 → 탭 전환마다 재애니메이션 방지 | 🤖 | 대기 |
| U-02 | `HomeView` — `ScenePhase` 감지 추가 → 자정 이후 앱 복귀 시 날짜 초기화 | 🤖 | 대기 |
| U-03 | `RestView` — "Pick Your Flower" 버튼 → 홈 경유 없이 바로 FlowerPicker 표시 흐름 개선 | 🤖 | 대기 |
| U-04 | `HomeView` 알림 권한 요청 시점 — `MyApp.init()` → 첫 세션 완료 후로 이동 | 🤖 | 대기 |

---

## 🟡 Medium — Copy / 로컬라이제이션

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| L-01 | `SessionIntroView` — `"Hold each expression for 4 seconds"` → `TrackingConfig.holdRequired` 연동 | 🤖 | 대기 |
| L-02 | `SessionTrackingView` — `scoreLabel` `"Hold it! Xs"` 로컬라이제이션 | 🤖 | 대기 |
| L-03 | `RestView` 전체 — 하드코딩 영어 문자열 `Localizable.xcstrings` 이관 | 🤖 | 대기 |
| L-04 | `HomeView` — Camera alert 문자열 로컬라이제이션 | 🤖 | 대기 |
| L-05 | `RestView` — `"\(n) more to earn a flower"` 복수/단수 처리 | 🤖 | 대기 |
| L-06 | 면책조항(disclaimer) 추가 — 의료기기 아님 명시 (온보딩 마지막 페이지 or 설정) | 🤖 | 대기 |

---

## 🟡 Medium — App Store 에셋

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| A-01 | iPhone 스크린샷 — 6.7인치 (1290×2796) 필수 | 👤 | 대기 |
| A-02 | iPhone 스크린샷 — 6.5인치 (1242×2688) 필수 | 👤 | 대기 |
| A-03 | iPhone 스크린샷 — 5.5인치 (1242×2208) 필수 | 👤 | 대기 |
| A-04 | iPad 스크린샷 — 12.9인치 (2048×2732) | 👤 | 대기 |
| A-05 | 앱 설명 작성 (한국어/영어, 의료 클레임 없이) | 👤 | 대기 |
| A-06 | 키워드 100자 설정 | 👤 | 대기 |
| A-07 | 앱 프리뷰 영상 (선택, 30초 이내) | 👤 | 대기 |

---

## 🟢 Low — 폴리시 & 기술 부채

| ID | 작업 | 담당 | 상태 |
|----|------|------|------|
| P-01 | `SwiftData` VersionedSchema + SchemaMigrationPlan 추가 (업데이트 시 데이터 보호) | 🤖 | 대기 |
| P-02 | `HomeView.startBackgroundAnimations()` — 불필요한 `DispatchQueue.main.async` 제거 | 🤖 | 대기 |
| P-03 | `README.md` 개선 — 스크린샷 섹션, 기기 요건, 빌드 방법 추가 | 🤖 | 대기 |
| P-04 | 주간 달력 요일 시작 — `Calendar.current` 로케일 존중 (한국/일본은 월요일 시작) | 🤖 | 대기 |
| P-05 | `LogSettingsCard.sideDisplayName(.central)` — "Lower"만 표시, 온보딩과 일관성 확인 | 🤖 | 대기 |

---

## v1.1 이후 (출시 후 로드맵)

| ID | 아이디어 | 메모 |
|----|----------|------|
| R-01 | 알림 시간 커스터마이징 (현재 오후 8시 고정) | NotificationManager 수정 필요 |
| R-02 | 운동 가이드 영상/애니메이션 | 정지 이미지보다 직관적 |
| R-03 | Apple Watch 스트릭 컴패니언 | 빠른 확인용 |
| R-04 | 언어 추가 (스페인어, 아랍어 등) | 안면 마비 글로벌 커뮤니티 |
| R-05 | 의사/치료사 공유 기능 | 진행 상황 PDF 내보내기 |
