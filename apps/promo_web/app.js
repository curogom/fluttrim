const translations = {
  en: {
    hero_eyebrow: "Flutter cache clarity, not guesswork.",
    hero_title: "Recover disk space safely with a Flutter-first cache inspector.",
    hero_body:
      "Fluttrim scans Flutter projects, builds explicit cleanup plans, and applies with safe defaults. Desktop GUI + CLI with identical core rules.",
    cta_download: "Get Early Access",
    cta_features: "Explore Features",
    metric_reclaimable: "Total Reclaimable",
    features_title: "Built for Flutter developer workflows",
    feature_scan_title: "Smart scan profiles",
    feature_scan_body:
      "SAFE / MEDIUM / AGGRESSIVE targeting only Flutter-related caches and artifacts.",
    feature_plan_title: "Mandatory plan preview",
    feature_plan_body:
      "Every cleanup starts with an explicit path-by-path plan and risk labels.",
    feature_xcode_title: "Xcode attribution",
    feature_xcode_body:
      "DerivedData entries are marked Attributed/Unknown with confidence evidence.",
    feature_fvm_title: "FVM visibility",
    feature_fvm_body:
      "See installed SDK usage by project and clean unused SDKs with confirmation.",
    trust_title: "Safety is product behavior, not a disclaimer",
    trust_1: "Allowlist + containment guards prevent out-of-scope deletions.",
    trust_2: "Unknown attribution is blocked by default unless explicitly enabled.",
    trust_3: "Trash-first cleanup mode where OS supports it.",
    trust_4: "Machine-readable JSON logs for scan and cleanup runs.",
    stat_label: "Core design promise",
    stat_title: "Same rules in CLI and GUI",
    stat_body: "One shared core engine. No duplicated cleanup logic.",
    download_title: "Join the early desktop preview",
    download_body:
      "Tell us your OS + team size and we will prioritize your onboarding slot.",
    download_button: "Request Invite",
    footer_tagline: "Flutter-focused cache inspector and space trimmer.",
  },
  ko: {
    hero_eyebrow: "감(感)으로 정리하지 않는 Flutter 캐시 관리.",
    hero_title: "Flutter 전용 캐시 인스펙터로 디스크 공간을 안전하게 회수하세요.",
    hero_body:
      "Fluttrim은 Flutter 프로젝트를 스캔하고, 경로 기반 정리 계획을 만든 뒤 안전 기본값으로 실행합니다. Desktop GUI와 CLI는 동일한 코어 규칙을 공유합니다.",
    cta_download: "얼리 액세스 신청",
    cta_features: "기능 보기",
    metric_reclaimable: "회수 가능 총량",
    features_title: "Flutter 개발 흐름에 맞춘 기능",
    feature_scan_title: "프로파일 기반 스캔",
    feature_scan_body:
      "SAFE / MEDIUM / AGGRESSIVE 프로파일로 Flutter 관련 캐시만 정밀 타겟팅합니다.",
    feature_plan_title: "미리보기 우선",
    feature_plan_body:
      "모든 정리는 경로별 위험 라벨이 포함된 명시적 플랜으로 시작합니다.",
    feature_xcode_title: "Xcode 귀속 분석",
    feature_xcode_body:
      "DerivedData를 Attributed/Unknown으로 구분하고 신뢰 근거를 제공합니다.",
    feature_fvm_title: "FVM 가시성",
    feature_fvm_body:
      "프로젝트별 SDK 사용 현황을 확인하고 미사용 SDK를 확인 후 정리할 수 있습니다.",
    trust_title: "안전은 문구가 아니라 제품 동작입니다",
    trust_1: "Allowlist + containment 가드로 범위 밖 삭제를 차단합니다.",
    trust_2: "Unknown 귀속 항목은 기본적으로 삭제가 차단됩니다.",
    trust_3: "OS가 지원하면 기본 삭제 모드는 휴지통입니다.",
    trust_4: "스캔/정리 결과를 JSON 로그로 남깁니다.",
    stat_label: "코어 설계 약속",
    stat_title: "CLI와 GUI 동일 규칙",
    stat_body: "하나의 코어 엔진을 공유하며 정리 로직 중복이 없습니다.",
    download_title: "데스크톱 프리뷰에 참여하세요",
    download_body: "사용 OS와 팀 규모를 남겨주시면 온보딩 우선순위를 반영합니다.",
    download_button: "초대 요청",
    footer_tagline: "Flutter 전용 캐시 인스펙터 및 공간 정리 도구",
  },
};

function setLanguage(language) {
  const pack = translations[language] || translations.en;
  document.documentElement.lang = language;
  document.querySelectorAll("[data-i18n]").forEach((node) => {
    const key = node.getAttribute("data-i18n");
    const text = pack[key];
    if (text) {
      node.textContent = text;
    }
  });

  document.querySelectorAll("[data-lang-btn]").forEach((button) => {
    const active = button.getAttribute("data-lang-btn") === language;
    button.classList.toggle("is-active", active);
  });

  localStorage.setItem("fluttrim_promo_lang", language);
}

document.querySelectorAll("[data-lang-btn]").forEach((button) => {
  button.addEventListener("click", () => {
    setLanguage(button.getAttribute("data-lang-btn"));
  });
});

setLanguage(localStorage.getItem("fluttrim_promo_lang") || "en");
