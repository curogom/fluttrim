# Cloudflare Pages Setup (Promo Web)

This guide deploys `apps/promo_web` using GitHub Actions workflow:

- `.github/workflows/promo-web-pages.yml`

## 1) Create Cloudflare Pages project

In Cloudflare Dashboard:

1. Go to **Workers & Pages**.
2. Click **Create application** -> **Pages** -> **Direct Upload**.
3. Create project name (example: `fluttrim-site`).
4. Keep it created; initial manual upload is optional.

Use this project name for GitHub variable `CLOUDFLARE_PAGES_PROJECT`.

## 2) Create API token

In Cloudflare Dashboard:

1. Go to **My Profile** -> **API Tokens** -> **Create Token**.
2. Start from template **Edit Cloudflare Workers** (or custom token).
3. Required permission (minimum practical):
   - Account: `Cloudflare Pages:Edit`
4. Restrict token to the account that owns the Pages project.
5. Create and copy token.

## 3) Get Cloudflare Account ID

- Open Cloudflare Dashboard home for your account.
- Copy **Account ID**.

## 4) Set GitHub repository secrets/variable

Repository: `curogom/fluttrim`

Add these in **Settings** -> **Secrets and variables** -> **Actions**:

Secrets:

- `CLOUDFLARE_API_TOKEN` = your API token
- `CLOUDFLARE_ACCOUNT_ID` = your account id

Variable:

- `CLOUDFLARE_PAGES_PROJECT` = your Pages project name

## 5) Deploy

### Option A: Manual

- GitHub -> **Actions** -> **Promo Web Cloudflare Pages** -> **Run workflow**

### Option B: Auto

- Push changes to `main` under:
  - `apps/promo_web/**`
  - `.github/workflows/promo-web-pages.yml`

## 6) Verify

- Check workflow log for deployment URL output.
- Open the URL and confirm EN default + KO toggle.
- Optional: add custom domain in Cloudflare Pages -> **Custom domains**.

## Troubleshooting

- Error: `Missing repository variable CLOUDFLARE_PAGES_PROJECT`
  - Add repository variable with exact name.
- Unauthorized token/account errors
  - Confirm token permission and account scope.
  - Confirm `CLOUDFLARE_ACCOUNT_ID` matches the Pages project account.
- Deploy succeeds but old content appears
  - Hard refresh / wait CDN propagation briefly.

