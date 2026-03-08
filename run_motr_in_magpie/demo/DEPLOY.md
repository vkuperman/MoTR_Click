# Running the study from GitHub (GitHub Pages)

## 1. One-time setup in your repo

1. **Enable GitHub Pages**
   - Open your repo on GitHub → **Settings** → **Pages** (left sidebar).
   - Under **Build and deployment**, set **Source** to **Deploy from a branch**.
   - Choose branch **gh-pages** and folder **/ (root)**, then Save.
   - (The workflow will create and update the `gh-pages` branch when you push.)

2. **Push the workflow**
   - Commit and push the `.github/workflows/deploy-to-gh-pages.yml` file (and the rest of the demo) to the `main` or `master` branch.
   - The first push (or any push to `main`/`master`) will trigger a build and deploy.

3. **Wait for the first deploy**
   - Go to the **Actions** tab and wait for the “Build and Deploy to GitHub Pages” workflow to finish successfully.
   - The site is then available (it can take 1–2 minutes the first time).

## 2. Your participant link

After deployment, the study runs at:

**`https://<your-username>.github.io/<repo-name>/`**

Examples:
- Repo `motr-demo` under user `jane`: `https://jane.github.io/motr-demo/`
- Repo `MouseTracking` under org `MyLab`: `https://mylab.github.io/MouseTracking/`

Share that URL with participants. They open it in a browser and the experiment runs.

## 3. If your repo has the demo in a subfolder

If the Vue app (e.g. this `demo` folder) is **not** at the root of the repo, either:

- Move the contents of `demo` (including `.github`) to the repo root and push, or  
- Edit `.github/workflows/deploy-to-gh-pages.yml` and add a `defaults.run.working-directory` (or run `npm ci` and `npm run build` inside the demo folder in the workflow).

## 4. Manual build (optional)

To test the production build locally:

```bash
npm ci
npm run build
```

Then open `dist/index.html` in a browser or serve the `dist` folder with any static server. The same `dist` is what gets deployed by the workflow.
