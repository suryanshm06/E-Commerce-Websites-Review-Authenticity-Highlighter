# Review Authenticity Highlighter

A local Chrome/Brave extension for Amazon.in, Amazon.com, and Flipkart. It sends review text to a local Express bridge and a local Python service, highlights reviews the supplied TF-IDF + XGBoost model flags, and can calculate an average star rating from analyzed reviews the model did not flag.

## Important model limitations

The supplied GitHub model uses `OR = 0` (original/presumed-genuine) and `CG = 1` (computer-generated/fake). Its class-1 probability is treated as a suspicion score; reviews at or above `0.50` are flagged. A model-unflagged review is **not verified** as human-written or genuine, and a flagged review is not proof of deception or AI authorship. Treat both the badge and adjusted rating as decision aids, not facts.

The model expects review text prefixed with a rating when one is available (for example, `5 stars. Review text`). The extension tries to extract star ratings from each supported site's review markup. Missing or unreadable ratings are omitted from the average.

## Project files

- `manifest.json` — Manifest V3 extension settings and local API permission.
- `content.js` — review extraction, dynamic page observation, model results, badge, and adjusted-rating UI.
- `styles.css` — red warning highlight and bottom-right rating panel.
- `background.js` — extension service worker that requests the local Node bridge.
- `server.js` — local Express/CORS bridge on port 3000.
- `model/model_service.py` — local Python API on port 8000; loads the included saved artifacts.
- `model/fake_review_detector/tfidf.pkl` and `xgb_model.pkl` — pretrained model files from the repository supplied by the user.
- `model/requirements.txt` — Python dependencies.

No training run is required. Do not run a separate baseline trainer; the bundled GitHub artifacts are the model used for inference.

## Requirements

- Windows 10 or newer.
- Python 3.10 or newer. If the `py` launcher is unavailable, use `python` commands as shown below.
- Node.js 18 or newer.
- Chrome or a Chromium-based browser such as Brave.

## First-time setup on Windows

### Requirements

- Windows 10 or newer.
- Python 3.10 or newer. If `python` is not recognized, install Python from python.org, select **Add python.exe to PATH**, and reopen Command Prompt.
- Node.js 18 or newer (including npm).
- Chrome or a Chromium-based browser such as Brave.

### 1. Run the setup script

Extract the complete project folder. Open the folder containing `setup.bat`, `run.bat`, `manifest.json`, and `package.json`. Run `setup.bat` (double-click it, or run it from Command Prompt):

```cmd
setup.bat
```

The script installs the Python dependencies required by the model. The saved TF-IDF vectorizer was serialized with scikit-learn 1.9.0; the requirements pin that version for compatibility. No model training or virtual environment setup is needed.

### 2. Install Node.js dependencies

The setup script does not install Node.js packages. In Command Prompt, from the project folder, run this once:

```cmd
npm install
```

### 3. Start the services

Run `run.bat` from the project folder:

```cmd
run.bat
```

It opens separate Command Prompt windows for the Python model service and Node bridge. Keep both windows open while using the extension. You can check that they are running at `http://127.0.0.1:8000/health` (should report `"modelLoaded": true`) and `http://localhost:3000/health` (should report `"ok": true`).

### 4. Add the extension to Chrome (first time)

1. In Chrome, enter `chrome://extensions` in the address bar and press Enter.
2. Turn on **Developer mode** using the switch in the top-right corner.
3. Click **Load unpacked**.
4. In the folder picker, select the extracted project folder that contains `manifest.json`. Do not select the ZIP file or the `model` subfolder.
5. Confirm the extension appears on the Extensions page and is enabled.

For Brave, use `brave://extensions` and follow the same steps.

The extension only needs to be loaded once. On later uses, start the services by running `run.bat`; if you move or remove the project folder, load the extension again from its new location.

## Use the extension

1. Keep both service windows running.
2. Open a product page on Amazon.in, Amazon.com, or Flipkart.
3. Refresh the page and scroll so reviews load. The extension analyzes review batches as they appear.
4. Reviews the model flags receive a red border and the badge `⚠️ AI flagged as likely fake.`
5. To request the adjusted rating, click **Show adjusted rating** at the bottom-right of the page. The panel shows the arithmetic mean of readable star ratings on analyzed reviews that the model did not flag.
6. Scroll to load more reviews, allow the analysis to finish, then click **Recalculate** to include the newly loaded reviews.

The adjusted rating only covers reviews that are currently loaded on the page, have a readable star rating, and have a completed model verdict. Model-unflagged does not mean confirmed genuine.

## Quick troubleshooting

- Python health: `http://127.0.0.1:8000/health` → `modelLoaded` should be `true`.
- Node health: `http://localhost:3000/health` → `ok` should be `true`.
- After reloading the extension in `chrome://extensions` or `brave://extensions`, refresh the product tab.
- On the product page, DevTools Console checks:

  ```js
  document.querySelectorAll('[data-ml-status="complete"]').length
  document.querySelectorAll('[data-ml-status="error"]').length
  document.querySelectorAll('[data-ml-fake="true"]').length
  ```

  Completed reviews with no errors means the pipeline is working, even if no review is flagged.
- Amazon advertising/CSP console messages are from Amazon, not necessarily the extension. Look for messages beginning `[Review Highlighter]` for extension errors.
- Keep the services bound to the local computer. Do not expose them to the internet or LAN.

## Stop the services

When finished, press **Ctrl+C** in each service Command Prompt. Next time, run `run.bat` again. The Python and Node dependencies only need to be installed once unless you reinstall or move the project. No retraining is needed.
