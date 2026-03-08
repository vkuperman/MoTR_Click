# Fix 404 on https://vkuperman.github.io/MoTR_Click/

If that URL shows **404** or a README instead of the study, do this:

1. Open your repo on GitHub: **https://github.com/vkuperman/MoTR_Click**
2. Go to **Settings** → **Pages** (left sidebar).
3. Under **Build and deployment** → **Source**, choose **Deploy from a branch**.
4. Under **Branch**, select **gh-pages** (not `main`). Folder: **/ (root)**.
5. Click **Save**.

Wait 1–2 minutes. Then open **https://vkuperman.github.io/MoTR_Click/** again. The study should load.

If **gh-pages** is not in the dropdown, the deploy workflow may not have run yet. Go to **Actions**, run **Build and Deploy to GitHub Pages** (or push a commit to `main`), wait for it to finish, then set Pages to **gh-pages** as above.
