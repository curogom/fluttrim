const translations = {
  en: {
    hero_eyebrow: "Flutter cache clarity, not guesswork.",
    hero_title: "Recover disk space safely with a Flutter-first cache inspector.",
    hero_body:
      "Fluttrim scans Flutter projects, builds explicit cleanup plans, and applies with safe defaults. Desktop GUI + CLI with identical core rules.",
    cta_download: "Get Early Access",
    cta_features: "Explore Features",
    metric_reclaimable: "Total Reclaimable",
    hero_screen_label: "Actual desktop capture (current build)",
    hero_screen_note:
      "Dashboard tab after launch. Same UI shipped in desktop release binaries.",
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
    screens_title: "Actual GUI captures",
    screens_body: "Real screenshots from the current desktop build, not mock illustrations.",
    screen_onboarding_caption:
      "Onboarding: language selection and initial scan root configuration.",
    screen_dashboard_caption: "Dashboard: reclaimable totals, scan status, and recent run logs.",
    gui_title: "Understand the GUI in one pass",
    gui_body:
      "Follow the typical flow from onboarding to safe apply before your first cleanup.",
    gui_step_1_title: "Onboarding",
    gui_step_1_body:
      "Choose language and set scan roots with a home-folder shortcut.",
    gui_step_2_title: "Scan",
    gui_step_2_body:
      "Run SAFE profile first and review reclaimable totals and permission warnings.",
    gui_step_3_title: "Preview plan",
    gui_step_3_body:
      "Batch-select projects, inspect explicit targets, and verify risk labels.",
    gui_step_4_title: "Apply and verify",
    gui_step_4_body:
      "Apply cleanup with Trash-first mode, then confirm reclaimed bytes in history.",
    gui_cta: "Open full GUI guide",
    cli_title: "CLI quick start for automation",
    cli_body:
      "Install the global fluttrim command from pub.dev and run the same cleanup flow in shell scripts or CI jobs.",
    cli_install_title: "Install and verify",
    cli_flow_title: "Typical safe flow",
    cli_button_pubdev: "View CLI on pub.dev",
    cli_button_docs: "Open CLI docs",
    cli_note:
      "CLI and GUI share one core engine, so safety rules and JSON schema stay aligned.",
    trust_title: "Safety is product behavior, not a disclaimer",
    trust_1: "Allowlist + containment guards prevent out-of-scope deletions.",
    trust_2: "Unknown attribution is blocked by default unless explicitly enabled.",
    trust_3: "Trash-first cleanup mode where OS supports it.",
    trust_4: "Machine-readable JSON logs for scan and cleanup runs.",
    oss_title: "Open source operations kit included",
    oss_body:
      "Fluttrim ships with practical docs and policies for running a public OSS project.",
    oss_readme_title: "Project README",
    oss_readme_body: "Architecture, setup, and deployment overview.",
    oss_core_title: "Core package docs",
    oss_core_body: "fluttrim_core API and publish preparation guide.",
    oss_contrib_title: "Contributing",
    oss_contrib_body: "PR flow, test requirements, and review expectations.",
    oss_security_title: "Security policy",
    oss_security_body: "Private reporting path for vulnerabilities.",
    oss_coc_title: "Code of conduct",
    oss_coc_body: "Community behavior expectations and enforcement scope.",
    oss_roadmap_title: "Roadmap",
    oss_roadmap_body: "Public priorities for v1 delivery and operations.",
    oss_governance_title: "Governance",
    oss_governance_body:
      "Decision model, release rules, and maintainer responsibilities.",
    oss_maintainers_title: "Maintainers",
    oss_maintainers_body: "Owner identity and stewardship scope for the project.",
    oss_support_title: "Support policy",
    oss_support_body: "How to ask questions and report problems.",
    oss_license_title: "MIT License",
    oss_license_body: "Permissive open-source license with attribution.",
    oss_link_label: "Open document",
    stat_label: "Core design promise",
    stat_title: "Same rules in CLI and GUI",
    stat_body: "One shared core engine. No duplicated cleanup logic.",
    download_title: "Download desktop builds",
    download_body:
      "Get the latest macOS, Windows, and Ubuntu binaries from GitHub Releases.",
    download_button: "Open Downloads",
    download_button_pubdev: "View Core on pub.dev",
    download_button_github: "View on GitHub",
    waitlist_disabled_note:
      "Waitlist email collection is disabled for now. TODO: re-enable only after privacy policy and secure storage are in place.",
    footer_tagline: "Flutter-focused cache inspector and space trimmer.",
    footer_owner_label: "Created by",
  },
  ko: {
    hero_eyebrow: "감(感)으로 정리하지 않는 Flutter 캐시 관리.",
    hero_title: "Flutter 전용 캐시 인스펙터로 디스크 공간을 안전하게 회수하세요.",
    hero_body:
      "Fluttrim은 Flutter 프로젝트를 스캔하고, 경로 기반 정리 계획을 만든 뒤 안전 기본값으로 실행합니다. Desktop GUI와 CLI는 동일한 코어 규칙을 공유합니다.",
    cta_download: "얼리 액세스 신청",
    cta_features: "기능 보기",
    metric_reclaimable: "회수 가능 총량",
    hero_screen_label: "실제 데스크톱 실행 화면 (현재 빌드)",
    hero_screen_note: "앱 실행 직후 Dashboard 탭 화면입니다. 실제 배포 바이너리와 동일한 UI입니다.",
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
    screens_title: "실제 GUI 화면",
    screens_body: "목업이 아닌 현재 데스크톱 빌드에서 캡처한 실제 화면입니다.",
    screen_onboarding_caption: "온보딩: 언어 선택 및 초기 스캔 루트 설정",
    screen_dashboard_caption: "대시보드: 회수 가능 용량, 스캔 상태, 최근 로그",
    gui_title: "GUI 흐름을 한 번에 이해하기",
    gui_body: "첫 실행 온보딩부터 안전한 Apply까지 핵심 단계를 빠르게 따라갈 수 있습니다.",
    gui_step_1_title: "온보딩",
    gui_step_1_body: "언어를 선택하고 홈 폴더 바로가기로 스캔 루트를 설정합니다.",
    gui_step_2_title: "스캔",
    gui_step_2_body:
      "먼저 SAFE 프로파일로 실행하고 회수 가능 용량과 권한 경고를 확인합니다.",
    gui_step_3_title: "플랜 미리보기",
    gui_step_3_body:
      "프로젝트를 다중 선택한 뒤 경로별 대상과 위험 라벨을 검토합니다.",
    gui_step_4_title: "적용 및 확인",
    gui_step_4_body:
      "휴지통 우선 모드로 적용하고 History에서 회수 결과를 확인합니다.",
    gui_cta: "GUI 가이드 문서 열기",
    cli_title: "자동화를 위한 CLI 빠른 시작",
    cli_body:
      "pub.dev에서 전역 fluttrim 커맨드를 설치하고 셸 스크립트/CI에서 동일한 정리 흐름을 실행할 수 있습니다.",
    cli_install_title: "설치 및 확인",
    cli_flow_title: "일반적인 안전 실행 흐름",
    cli_button_pubdev: "CLI pub.dev 보기",
    cli_button_docs: "CLI 문서 열기",
    cli_note:
      "CLI와 GUI는 하나의 코어 엔진을 공유하므로 안전 규칙과 JSON 스키마가 동일하게 유지됩니다.",
    trust_title: "안전은 문구가 아니라 제품 동작입니다",
    trust_1: "Allowlist + containment 가드로 범위 밖 삭제를 차단합니다.",
    trust_2: "Unknown 귀속 항목은 기본적으로 삭제가 차단됩니다.",
    trust_3: "OS가 지원하면 기본 삭제 모드는 휴지통입니다.",
    trust_4: "스캔/정리 결과를 JSON 로그로 남깁니다.",
    oss_title: "오픈소스 운영 기본 세트 제공",
    oss_body: "Fluttrim은 공개 OSS 운영에 필요한 실무 문서/정책을 함께 제공합니다.",
    oss_readme_title: "프로젝트 README",
    oss_readme_body: "아키텍처, 실행, 배포 흐름을 한 번에 확인할 수 있습니다.",
    oss_core_title: "Core 패키지 문서",
    oss_core_body: "fluttrim_core API와 pub.dev 배포 준비 가이드를 제공합니다.",
    oss_contrib_title: "기여 가이드",
    oss_contrib_body: "PR 흐름, 테스트 요구사항, 리뷰 기준을 안내합니다.",
    oss_security_title: "보안 정책",
    oss_security_body: "취약점 비공개 제보 경로를 제공합니다.",
    oss_coc_title: "행동 강령",
    oss_coc_body: "커뮤니티 행동 기준과 적용 범위를 정의합니다.",
    oss_roadmap_title: "로드맵",
    oss_roadmap_body: "v1 기능/운영 우선순위를 공개합니다.",
    oss_governance_title: "거버넌스",
    oss_governance_body: "의사결정 구조, 릴리즈 기준, 메인테이너 책임을 정의합니다.",
    oss_maintainers_title: "메인테이너",
    oss_maintainers_body: "프로젝트 오너와 운영 책임 범위를 명시합니다.",
    oss_support_title: "지원 정책",
    oss_support_body: "질문/문제 제기 경로와 작성 기준을 안내합니다.",
    oss_license_title: "MIT 라이선스",
    oss_license_body: "저작권 고지 조건의 퍼미시브 오픈소스 라이선스입니다.",
    oss_link_label: "문서 열기",
    stat_label: "코어 설계 약속",
    stat_title: "CLI와 GUI 동일 규칙",
    stat_body: "하나의 코어 엔진을 공유하며 정리 로직 중복이 없습니다.",
    download_title: "데스크톱 빌드 다운로드",
    download_body: "GitHub Releases에서 macOS, Windows, Ubuntu 빌드를 받을 수 있습니다.",
    download_button: "다운로드 열기",
    download_button_pubdev: "Core pub.dev 보기",
    download_button_github: "GitHub 보기",
    waitlist_disabled_note:
      "대기자 이메일 수집은 현재 비활성화 상태입니다. TODO: 개인정보 처리방침 및 안전한 저장소 준비 후 재개합니다.",
    footer_tagline: "Flutter 전용 캐시 인스펙터 및 공간 정리 도구",
    footer_owner_label: "만든 사람",
  },
};

function withDocsLanguage(url, language) {
  if (!url || !url.startsWith("/docs/")) {
    return url;
  }

  const parsed = new URL(url, window.location.origin);
  parsed.searchParams.set("lang", language);
  return `${parsed.pathname}${parsed.search}${parsed.hash}`;
}

function syncDocsLinks(language) {
  document.querySelectorAll("[data-doc-link]").forEach((link) => {
    const baseHref = link.dataset.baseHref || link.getAttribute("href");
    link.dataset.baseHref = baseHref;
    link.setAttribute("href", withDocsLanguage(baseHref, language));
  });
}

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
  localStorage.setItem("fluttrim_docs_lang", language);
  syncDocsLinks(language);
}

document.querySelectorAll("[data-lang-btn]").forEach((button) => {
  button.addEventListener("click", () => {
    setLanguage(button.getAttribute("data-lang-btn"));
  });
});

setLanguage(localStorage.getItem("fluttrim_promo_lang") || "en");
