const FLUTTRIM_DOCS = [
  {
    slug: "readme",
    title: "Project README",
    description: "Architecture, setup, and project overview.",
    file: "content/readme.md",
    source: "https://github.com/curogom/fluttrim/blob/main/README.md",
    category: "core",
  },
  {
    slug: "core-package-docs",
    title: "Core Package Docs",
    description: "fluttrim_core publish and package operations guide.",
    file: "content/core-package-docs.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/pubdev-publishing.md",
    category: "core",
  },
  {
    slug: "contributing",
    title: "Contributing",
    description: "PR workflow, tests, and contribution expectations.",
    file: "content/contributing.md",
    source: "https://github.com/curogom/fluttrim/blob/main/CONTRIBUTING.md",
    category: "core",
  },
  {
    slug: "security",
    title: "Security",
    description: "How to report security issues privately.",
    file: "content/security.md",
    source: "https://github.com/curogom/fluttrim/blob/main/SECURITY.md",
    category: "core",
  },
  {
    slug: "code-of-conduct",
    title: "Code of Conduct",
    description: "Community behavior standards and scope.",
    file: "content/code-of-conduct.md",
    source: "https://github.com/curogom/fluttrim/blob/main/CODE_OF_CONDUCT.md",
    category: "core",
  },
  {
    slug: "roadmap",
    title: "Roadmap",
    description: "Public priorities for feature and ops delivery.",
    file: "content/roadmap.md",
    source: "https://github.com/curogom/fluttrim/blob/main/ROADMAP.md",
    category: "core",
  },
  {
    slug: "governance",
    title: "Governance",
    description: "Decision model and maintainer responsibilities.",
    file: "content/governance.md",
    source: "https://github.com/curogom/fluttrim/blob/main/GOVERNANCE.md",
    category: "core",
  },
  {
    slug: "maintainers",
    title: "Maintainers",
    description: "Current project maintainer list.",
    file: "content/maintainers.md",
    source: "https://github.com/curogom/fluttrim/blob/main/MAINTAINERS.md",
    category: "core",
  },
  {
    slug: "support",
    title: "Support",
    description: "Issue and support channel guidance.",
    file: "content/support.md",
    source: "https://github.com/curogom/fluttrim/blob/main/SUPPORT.md",
    category: "core",
  },
  {
    slug: "license",
    title: "MIT License",
    description: "License terms used by this project.",
    file: "content/license.md",
    source: "https://github.com/curogom/fluttrim/blob/main/LICENSE",
    category: "core",
  },
  {
    slug: "cloudflare-pages-setup",
    title: "Cloudflare Pages Setup",
    description: "Dashboard-only deployment flow (no token in repo).",
    file: "content/cloudflare-pages-setup.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/cloudflare-pages-setup.md",
    category: "ops",
  },
  {
    slug: "service-readiness-checklist",
    title: "Service Readiness Checklist",
    description: "MVP launch readiness checklist.",
    file: "content/service-readiness-checklist.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/service-readiness-checklist.md",
    category: "ops",
  },
  {
    slug: "open-source-maintenance",
    title: "Open Source Maintenance",
    description: "Minimum maintenance checklist for OSS operations.",
    file: "content/open-source-maintenance.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/open-source-maintenance.md",
    category: "ops",
  },
  {
    slug: "manual-tests",
    title: "Manual Tests",
    description: "Smoke/manual test guide by platform.",
    file: "content/manual-tests.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/manual-tests.md",
    category: "ops",
  },
  {
    slug: "json-schemas",
    title: "JSON Schemas",
    description: "Scan and cleanup JSON schema reference.",
    file: "content/json-schemas.md",
    source: "https://github.com/curogom/fluttrim/blob/main/docs/json-schemas.md",
    category: "ops",
  },
];

const FLUTTRIM_DOC_MAP = Object.fromEntries(FLUTTRIM_DOCS.map((doc) => [doc.slug, doc]));

function getDocBySlug(slug) {
  return FLUTTRIM_DOC_MAP[slug] || null;
}

function renderDocCards(container, category) {
  const docs = FLUTTRIM_DOCS.filter((doc) => doc.category === category);
  container.innerHTML = "";

  docs.forEach((doc) => {
    const card = document.createElement("article");
    card.className = "card";
    card.innerHTML = `
      <h3>${doc.title}</h3>
      <p>${doc.description}</p>
      <div class="actions">
        <a class="btn" href="/docs/${doc.slug}/">Read in site</a>
        <a class="btn" href="${doc.source}" target="_blank" rel="noopener noreferrer">Source</a>
      </div>
    `;
    container.appendChild(card);
  });
}

window.FluttrimDocs = {
  docs: FLUTTRIM_DOCS,
  getDocBySlug,
  renderDocCards,
};
