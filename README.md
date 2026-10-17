# PortMind AI Colombo — Jac-first Rebuild

**Status: source rebuild / compiler validation pending on Jac 0.16.7.** This is **NOT a certified running or hackathon-compliant backend** until `jac check` and the full walker end-to-end test pass. The uploaded logs showed version-specific syntax and type issues in prior versions; this rebuilt source addresses the observed loop typing issue as a candidate fix but was not compiled here because Jac isn't installed in the packaging environment.

## Source split (honest metric)

- **Jac runtime source excluding the synthetic `seed.jac` fixture:** 100,218 bytes.
- **HTML/CSS/JS, Python local proxy, root redirect:** 18,435 bytes.
- **Jac share of these runtime files, excluding seed fixture:** **84.46%**.
- Large synthetic data fixtures deliberately excluded from the headline measurement. This is a **byte-share**, not a definitive judge-approved compliance number.
- Do not claim 90%: the non-fixture metric is 84.46% and Jac has not compiled here.
- Recalculate with a different denominator if the hackathon specifies source lines or includes test code.

## Functional intent

One source-of-truth Jac simulation (9 vessels: container/passenger/tanker/bulk, 6 berths, 6 handling assets, 12 trucks, 360 synthetic container records, 30 fictional workers, 3 yard blocks). Synthetic vessel coordinates are drawn on a **real OpenStreetMap basemap** via Leaflet. Live Open-Meteo Colombo-area weather is shown separately from simulated operating limits. Nine **rule-based** specialist agent functions create and verify recovery proposals; no LLM API calls or live AIS/terminal data are claimed.

The browser under `web/` is a thin dashboard. All world-state mutations are intended to occur in Jac (`jac/engine.jac`, `jac/agents.jac`). `dev_server.py` forwards requests to a Jac walker and does not contain a second simulator.

## Windows setup (Jac 0.16.7)

1. Extract ZIP; open PowerShell **in this extracted folder**.
2. Run `jac --version`. On the user's PC, Jac 0.16.7 was installed already (keep the working PowerShell window open if PATH was modified temporarily).
3. Run `CHECK_JAC_WINDOWS.cmd` (double-click or use `cmd /c .\CHECK_JAC_WINDOWS.cmd`). The logs are in `jac-check-*.log`.
4. **If any Jac check fails, do not attempt to launch the backend yet.** Zip the logs and fix all parser/type errors. There may still be unresolved errors.
5. Once **every** Jac source checks cleanly, install a compatible Jac Cloud server and consult `jac --help` / server documentation for the supported `jac serve` invocation in your installed version.
6. Start the Jac API at the endpoint used by `dev_server.py`, default `http://127.0.0.1:8000/walker/PortMindAPI`. Confirm it actually responds to `{"action":"state","payload":{}}` before continuing.
7. In another terminal, run `python dev_server.py`. Open `http://127.0.0.1:5500` (not the GitHub Pages URL) and test reset → advance → failed crane → replanning → manager approval → continuing simulation.

## Hosting and GitHub Pages

The repository-root `index.html` sends GitHub Pages to `/web/` so the **interface** is shown instead of README. **GitHub Pages cannot execute Jac**. The published GitHub Pages interface may show **Jac backend offline**. That is expected until a secure publicly reachable Jac backend and same-origin reverse proxy are deployed. Never deploy the local demo-role selector as real authentication.

## What passes locally

Offline tests: `python -m unittest discover -s tests -v` (fixture integrity, API wiring, source code and JS syntax). These tests **do not run Jac**. Jac compatibility and browser integration remain unverified in this environment. GitHub Actions runs an actual Jac 0.16.7 compilation job; that job is expected to flag unresolved migration problems, rather than masking them.

## Key folders

- `jac/model.jac`: Jac graph entities, edges and specialist walkers
- `jac/seed.jac`: synthetic demo records (fixture)
- `jac/engine.jac`: simulation clock, berth/cargo/truck/shift rules
- `jac/agents.jac`: nine specialists, negotiation, hard constraints and approval
- `jac/operations.jac`: truck dispatch, inventory and berth forecasts
- `jac/audit.jac`: invariant checking, provenance and audit reports
- `jac/api.jac`: Jac walker service boundary
- `web/`: minimal frontend with Colombo map and weather API
- `dev_server.py`: local Jac walker proxy only

## Safety and representation

No live Port of Colombo berth records, vessel telemetry, shipping manifests, equipment commands, official customs release, worker records or authoritative marine weather data. Do not use this as a real navigation, customs or dispatch system. Shift rules and safety thresholds are synthetic demonstration assumptions.
