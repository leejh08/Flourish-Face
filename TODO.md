# Flourish Face — 배포 TODO

## 내가 직접 해야 할 것 (수동 작업)

### App Store Connect
- [ ] Apple Developer 계정에서 번들 ID `com.jh.Flourish-Face` 등록
- [ ] App Store Connect에서 앱 레코드 생성 (이름, 기본 언어, 카테고리: Health & Fitness)
- [ ] 개인정보처리방침 URL 등록 (카메라 권한 앱 필수 — GitHub Pages나 Notion으로 간단히 가능)
- [ ] 지원 URL 등록 (GitHub Issues 페이지로 대체 가능)
- [ ] 연령 등급 설정 (4+)
- [ ] 앱 설명(국문/영문), 키워드(100자), 홍보 문구 작성
- [ ] 가격 설정 (무료 추천)

### 스크린샷 / 미디어 (실기기에서 직접 촬영)
- [ ] 6.7인치 iPhone 스크린샷 (1290×2796) — **필수**
- [ ] 6.5인치 iPhone 스크린샷 (1242×2688) — **필수**
- [ ] 5.5인치 iPhone 스크린샷 (1242×2208) — **필수**
- [ ] iPad 12.9인치 스크린샷 (2048×2732) — iPad 지원 유지 시 필수
- [ ] 앱 프리뷰 영상 (선택, 30초 이내)

### 심사 제출
- [ ] Xcode에서 `Flourish_Face PROD` 스킴으로 Archive
- [ ] TestFlight 내부 테스트 (TrueDepth 기기에서 직접 확인)
  - 온보딩 전체 흐름
  - 5가지 운동 각각 완료
  - 꽃 수집 및 컬렉션
  - 알림 수신
- [ ] App Store 심사 제출 시 리뷰어 노트 작성
  - TrueDepth(Face ID) 기기 필수 명시
  - 안면 마비 재활 목적 간략 설명
  - 데모 영상 첨부 권장

---

## Claude가 코드에서 처리할 것

### 즉시 (배포 블로커)
- [ ] `PrivacyInfo.xcprivacy` 추가 — 2024년 5월부터 App Store 필수 요건
- [ ] 알림 권한 요청 시점 변경 — `MyApp.init()`에서 첫 세션 완료 후로 이동

### 기기 호환성
- [ ] TrueDepth 미지원 기기 대응 화면 추가 (`ARFaceTrackingConfiguration.isSupported == false`)
- [ ] iPad 지원 범위 결정 및 처리 (대부분의 iPad는 TrueDepth 없음)

### 안정성
- [ ] SwiftData `VersionedSchema` + `SchemaMigrationPlan` 추가 — 업데이트 시 데이터 보호

### 문서
- [ ] README 개선 — 스크린샷 섹션, 기기 요건, 빌드 방법 추가
