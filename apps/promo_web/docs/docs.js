const FLUTTRIM_I18N = {
  en: {
    docsTitle: "Fluttrim Docs",
    home: "Home",
    docs: "Docs",
    pubdev: "pub.dev",
    github: "GitHub",
    languageLabel: "Language",
    heroTitle: "Documentation is available under /docs paths.",
    heroBody:
      "Browse product and operations docs directly in the site. English and Korean are both available.",
    coreHeading: "Core Docs",
    opsHeading: "Operations Docs",
    notice: "Note: Web docs are deployment-time copies of repository sources.",
    readInSite: "Read in site",
    source: "Source",
    loading: "Loading...",
    allDocs: "All docs",
    tocTitle: "On this page",
    emptyToc: "No headings found.",
    viewerNotice:
      "If rendering fails, use Source to open the original markdown.",
    viewerFallback:
      "English content is unavailable for this page. Displaying Korean source.",
    notFoundTitle: "Document not found",
    notFoundBody:
      'Invalid document path. Use <a href="/docs/">/docs/</a> to browse available documents.',
    loadFailedPrefix: "Failed to load document",
  },
  ko: {
    docsTitle: "Fluttrim 문서",
    home: "홈",
    docs: "문서",
    pubdev: "pub.dev",
    github: "GitHub",
    languageLabel: "언어",
    heroTitle: "문서는 /docs 경로에서 제공합니다.",
    heroBody:
      "제품/운영 문서를 웹에서 바로 확인할 수 있습니다. 한국어와 영어를 모두 제공합니다.",
    coreHeading: "핵심 문서",
    opsHeading: "운영 문서",
    notice: "참고: 웹 문서는 배포 시점의 저장소 사본입니다.",
    readInSite: "사이트에서 읽기",
    source: "원문",
    loading: "불러오는 중...",
    allDocs: "전체 문서",
    tocTitle: "이 문서의 목차",
    emptyToc: "표시할 제목이 없습니다.",
    viewerNotice:
      "문서 렌더링 실패 시 원문(Source) 링크로 확인할 수 있습니다.",
    viewerFallback:
      "요청한 언어 문서가 없어 한국어 원문을 표시합니다.",
    notFoundTitle: "문서를 찾을 수 없습니다",
    notFoundBody:
      '잘못된 문서 경로입니다. <a href="/docs/">/docs/</a>에서 문서를 선택해 주세요.',
    loadFailedPrefix: "문서를 불러오지 못했습니다",
  },
};

const FLUTTRIM_DOCS = [
  {
    slug: "readme",
    title: {
      en: "Project README",
      ko: "프로젝트 README",
    },
    description: {
      en: "Architecture, setup, and project overview.",
      ko: "아키텍처, 실행 방법, 프로젝트 개요.",
    },
    file: {
      en: "content/en/readme.md",
      ko: "content/readme.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/README.md",
    category: "core",
  },
  {
    slug: "gui-usage",
    title: {
      en: "GUI User Guide",
      ko: "GUI 사용자 가이드",
    },
    description: {
      en: "Understand each desktop tab and cleanup flow quickly.",
      ko: "데스크톱 각 탭과 정리 흐름을 빠르게 이해하는 안내서.",
    },
    file: {
      en: "content/en/gui-usage.md",
      ko: "content/gui-usage.md",
    },
    source: "https://github.com/curogom/fluttrim/tree/main/apps/desktop",
    category: "core",
  },
  {
    slug: "core-package-docs",
    title: {
      en: "Core Package Docs",
      ko: "코어 패키지 문서",
    },
    description: {
      en: "fluttrim_core/fluttrim_cli publish and package operations guide.",
      ko: "fluttrim_core/fluttrim_cli 공개/배포 운영 가이드.",
    },
    file: {
      en: "content/en/core-package-docs.md",
      ko: "content/core-package-docs.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/pubdev-publishing.md",
    category: "core",
  },
  {
    slug: "contributing",
    title: {
      en: "Contributing",
      ko: "기여 가이드",
    },
    description: {
      en: "PR workflow, tests, and contribution expectations.",
      ko: "PR 흐름, 테스트, 리뷰 기대치.",
    },
    file: {
      en: "content/en/contributing.md",
      ko: "content/contributing.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/CONTRIBUTING.md",
    category: "core",
  },
  {
    slug: "security",
    title: {
      en: "Security",
      ko: "보안 정책",
    },
    description: {
      en: "How to report security issues privately.",
      ko: "보안 취약점 비공개 제보 절차.",
    },
    file: {
      en: "content/en/security.md",
      ko: "content/security.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/SECURITY.md",
    category: "core",
  },
  {
    slug: "code-of-conduct",
    title: {
      en: "Code of Conduct",
      ko: "행동 강령",
    },
    description: {
      en: "Community behavior standards and scope.",
      ko: "커뮤니티 행동 기준과 집행 범위.",
    },
    file: {
      en: "content/en/code-of-conduct.md",
      ko: "content/code-of-conduct.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/CODE_OF_CONDUCT.md",
    category: "core",
  },
  {
    slug: "roadmap",
    title: {
      en: "Roadmap",
      ko: "로드맵",
    },
    description: {
      en: "Public priorities for feature and ops delivery.",
      ko: "기능/운영 우선순위 공개 계획.",
    },
    file: {
      en: "content/en/roadmap.md",
      ko: "content/roadmap.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/ROADMAP.md",
    category: "core",
  },
  {
    slug: "governance",
    title: {
      en: "Governance",
      ko: "거버넌스",
    },
    description: {
      en: "Decision model and maintainer responsibilities.",
      ko: "의사결정 구조와 유지관리 책임.",
    },
    file: {
      en: "content/en/governance.md",
      ko: "content/governance.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/GOVERNANCE.md",
    category: "core",
  },
  {
    slug: "maintainers",
    title: {
      en: "Maintainers",
      ko: "메인테이너",
    },
    description: {
      en: "Current project maintainer list.",
      ko: "현재 프로젝트 메인테이너 정보.",
    },
    file: {
      en: "content/en/maintainers.md",
      ko: "content/maintainers.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/MAINTAINERS.md",
    category: "core",
  },
  {
    slug: "support",
    title: {
      en: "Support",
      ko: "지원 정책",
    },
    description: {
      en: "Issue and support channel guidance.",
      ko: "이슈/문의 채널과 운영 기준.",
    },
    file: {
      en: "content/en/support.md",
      ko: "content/support.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/SUPPORT.md",
    category: "core",
  },
  {
    slug: "license",
    title: {
      en: "MIT License",
      ko: "MIT 라이선스",
    },
    description: {
      en: "License terms used by this project.",
      ko: "프로젝트 라이선스 조건.",
    },
    file: {
      en: "content/en/license.md",
      ko: "content/license.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/LICENSE",
    category: "core",
  },
  {
    slug: "cloudflare-pages-setup",
    title: {
      en: "Cloudflare Pages Setup",
      ko: "Cloudflare Pages 설정",
    },
    description: {
      en: "Dashboard-only deployment flow (no token in repo).",
      ko: "대시보드 기반 배포 절차(저장소 토큰 없음).",
    },
    file: {
      en: "content/en/cloudflare-pages-setup.md",
      ko: "content/cloudflare-pages-setup.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/cloudflare-pages-setup.md",
    category: "ops",
  },
  {
    slug: "service-readiness-checklist",
    title: {
      en: "Service Readiness Checklist",
      ko: "서비스 공개 체크업",
    },
    description: {
      en: "MVP launch readiness checklist.",
      ko: "MVP 공개 전 점검 체크리스트.",
    },
    file: {
      en: "content/en/service-readiness-checklist.md",
      ko: "content/service-readiness-checklist.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/service-readiness-checklist.md",
    category: "ops",
  },
  {
    slug: "open-source-maintenance",
    title: {
      en: "Open Source Maintenance",
      ko: "오픈소스 공개 범위 관리",
    },
    description: {
      en: "Minimum maintenance checklist for OSS operations.",
      ko: "오픈소스 운영 최소 점검 기준.",
    },
    file: {
      en: "content/en/open-source-maintenance.md",
      ko: "content/open-source-maintenance.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/open-source-maintenance.md",
    category: "ops",
  },
  {
    slug: "manual-tests",
    title: {
      en: "Manual Tests",
      ko: "수동 테스트",
    },
    description: {
      en: "Smoke/manual test guide by platform.",
      ko: "OS별 스모크/수동 테스트 가이드.",
    },
    file: {
      en: "content/en/manual-tests.md",
      ko: "content/manual-tests.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/manual-tests.md",
    category: "ops",
  },
  {
    slug: "json-schemas",
    title: {
      en: "JSON Schemas",
      ko: "JSON 스키마",
    },
    description: {
      en: "Scan and cleanup JSON schema reference.",
      ko: "스캔/정리 JSON 스키마 명세.",
    },
    file: {
      en: "content/en/json-schemas.md",
      ko: "content/json-schemas.md",
    },
    source: "https://github.com/curogom/fluttrim/blob/main/docs/json-schemas.md",
    category: "ops",
  },
];

const FLUTTRIM_DOC_MAP = Object.fromEntries(FLUTTRIM_DOCS.map((doc) => [doc.slug, doc]));

function resolveLanguage(language) {
  return language === "ko" ? "ko" : "en";
}

function getPreferredLanguage(explicit) {
  if (explicit) {
    return resolveLanguage(explicit);
  }
  const params = new URLSearchParams(window.location.search);
  const queryLang = params.get("lang");
  if (queryLang) {
    return resolveLanguage(queryLang);
  }
  return resolveLanguage(localStorage.getItem("fluttrim_docs_lang") || "en");
}

function setPreferredLanguage(language) {
  const resolved = resolveLanguage(language);
  localStorage.setItem("fluttrim_docs_lang", resolved);
  document.documentElement.lang = resolved;
  return resolved;
}

function getI18n(language) {
  return FLUTTRIM_I18N[resolveLanguage(language)] || FLUTTRIM_I18N.en;
}

function getDocBySlug(slug) {
  return FLUTTRIM_DOC_MAP[slug] || null;
}

function getLocalizedDoc(doc, language) {
  const lang = resolveLanguage(language);
  return {
    ...doc,
    titleText: doc.title[lang] || doc.title.en,
    descriptionText: doc.description[lang] || doc.description.en,
    filePath: doc.file[lang] || doc.file.ko || doc.file.en,
    fallbackFilePath:
      doc.file[lang] === doc.file.ko ? doc.file.en : doc.file.ko,
  };
}

function withLang(url, language) {
  const u = new URL(url, window.location.origin);
  u.searchParams.set("lang", resolveLanguage(language));
  return `${u.pathname}${u.search}`;
}

function renderDocCards(container, category, language) {
  const i18n = getI18n(language);
  const docs = FLUTTRIM_DOCS.filter((doc) => doc.category === category);
  container.innerHTML = "";

  docs.forEach((doc) => {
    const localized = getLocalizedDoc(doc, language);
    const card = document.createElement("article");
    card.className = "card";
    card.innerHTML = `
      <h3>${localized.titleText}</h3>
      <p>${localized.descriptionText}</p>
      <div class="actions">
        <a class="btn" href="${withLang(`/docs/${doc.slug}/`, language)}">${i18n.readInSite}</a>
        <a class="btn" href="${doc.source}" target="_blank" rel="noopener noreferrer">${i18n.source}</a>
      </div>
    `;
    container.appendChild(card);
  });
}

window.FluttrimDocs = {
  docs: FLUTTRIM_DOCS,
  getDocBySlug,
  getLocalizedDoc,
  getPreferredLanguage,
  setPreferredLanguage,
  getI18n,
  renderDocCards,
  resolveLanguage,
  withLang,
};
