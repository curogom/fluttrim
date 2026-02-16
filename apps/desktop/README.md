# fluttrim_desktop

Fluttrim 데스크톱 GUI 앱입니다.

## 실행

```bash
cd apps/desktop
flutter pub get
flutter run
```

## 주요 원칙

- 비즈니스 로직은 `packages/core`에만 위치
- GUI는 core API를 호출하는 얇은 프론트엔드
- Preview-before-apply / allowlist / containment 안전 규칙 준수
