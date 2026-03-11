# Upload results API

Serverless endpoint: **POST /api/upload-results**

Accepts `{ participantId: string, zipBase64: string }` and can send the results zip by email and/or save it to GitHub. At least one of (email) or (GitHub) must be configured.

## Environment variables (e.g. Vercel)

| Variable | Required | Description |
|----------|----------|-------------|
| `RESEND_API_KEY` | For email | Resend API key |
| `EMAIL_TO` | For email | Recipient email (Resend free tier: only account owner until domain verified) |
| `GITHUB_TOKEN` | For GitHub | Personal access token with **Contents: Read and write** |
| `GITHUB_REPO` | Optional | Repo as `owner/repo`; default `vkuperman/MoTR_Click` |

## Save reports on GitHub alongside email

1. **Create a GitHub token:** GitHub → Settings → Developer settings → Personal access tokens. Create a token with **Contents: Read and write**. Copy the value.

2. **Add in Vercel:** Project → Settings → Environment Variables. Add `GITHUB_TOKEN` (Secret) with the token. Optionally add `GITHUB_REPO` (e.g. `owner/repo`) if not using the default.

3. **Redeploy** so the new env vars are used.

Zips are written to the **main** branch under **Results/** with names like `Results/<participantId>_motr_results_<timestamp>.zip`. View them at `https://github.com/<owner>/<repo>/tree/main/Results`.

## Troubleshooting

- Only email, no file in GitHub: ensure `GITHUB_TOKEN` is set and the deployment ran after adding it; token must have Contents write.
- 401/403 from GitHub: token expired or missing scope; create a new token with Contents read/write.
- 404 on PUT: `GITHUB_REPO` must be `owner/repo` (e.g. `vkuperman/MoTR_Click`).
