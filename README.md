# PortMind AI Colombo — Jac-first Smart Port Digital Twin

A **Jac/Jaseci-first GitHub-ready source package** for a fictional Colombo-inspired port control tower. The app includes a real OpenStreetMap **geographic basemap** with **simulated** vessel positions, synthetic container/berth/crane/truck/worker events, nine rule-based operational specialists, incident recovery proposals requiring manager review, and a separately labeled live **Open-Meteo Colombo-area weather forecast**.

> **Status / crucial limitation:** The Jac compiler/runtime (`jaclang` / Jac Cloud) was **not available in the authoring environment**. Accordingly, this is a substantive Jac migration **source package**, **not a certified working Jac deployment**. The frontend syntax, fixture references and ratio checks were executed; Jac compilation, backend walker endpoint compatibility, and full browser-to-Jac integration **remain unverified**. Do not submit as a functional Jac hackathon deliverable before testing on a real Jac/Jaseci installation and fixing any version incompatibilities.

## Source-code percentage — read carefully

This source uses Jac for all intended business logic, the simulation engine, constraint checker, 9 agents, seed records and backend walker service. The browser UI is thin JavaScript/HTML/CSS; `dev_server.py` is a local HTTP forwarding helper, **not** a Python simulation engine.

**Jac percentage calculation, authored application files only:** bytes in `jac/*.jac` divided by bytes in `jac/*.jac`, `web/*.js`, `web/*.html`, `web/*.css`, and `dev_server.py`. Tests, documentation, CI metadata, generated caches, binaries and vendors are excluded. This **includes 360 synthetic container records** inside `jac/seed.jac`; therefore it is not a measure of *algorithm-only* code. Please don't claim that the 90% byte share proves runtime Jac compliance or that a jury will use this measurement method.

Recalculate via:

```bash
python -c "from pathlib import Path; p=Path('.'); a=sum(f.stat().st_size for f in p.glob('jac/*.jac')); b=sum(f.stat().st_size for f in p.glob('web/*') if f.is_file())+(p/'dev_server.py').stat().st_size; print(f'Jac authored application bytes: {a}, other: {b}, percentage: {100*a/(a+b):.2f}%')"
```

## Included synthetic port resources

- 9 vessels: 6 container vessels, 1 passenger ship, 1 tanker, 1 bulk carrier.
- 6 type-compatible berths (3 container, 1 passenger, 1 tanker, 1 bulk).
- 6 handling assets (4 container cranes, a tanker transfer asset, a bulk grab crane).
- 12 inland trucks with simulated custody flows, driver coverage and gate queues.
- 30 fictional employees covering morning, afternoon and night shifts.
- 360 individually searchable fictional container records; import/export release flags are **not customs records**.
- 3 yard blocks with 1,200 TEU modeled capacity / 800 TEU initial occupancy.
- Reefer temperature records, traffic events, shift handover, weather simulation and equipment breakdowns.
- 9 Jac rule-based agents: vessel, berth, cargo/yard, crane, traffic/trucks, workforce, maintenance, environment/safety, negotiation/planning.

## Geographic map and real weather

- **Geographic background:** OpenStreetMap via Leaflet, centered on Colombo harbor (approx. latitude 6.9515, longitude 79.837). Requires internet; OpenStreetMap basemap is real geography.
- **Vessel and berth overlays:** Entirely synthetic/illustrative coordinates and movements. They are **NOT** real AIS tracks, official port berth GPS points, navigational charts, or live Colombo Port data.
- **Weather report:** Open-Meteo public area forecast at approx. Colombo 6.945, 79.85, with current temperature, rain, wind, humidity and 12-hour outlook, source timestamps and an error fallback. Requires internet. Not official maritime station data.
- **Simulated safety/weather:** A separate Jac scenario rule set. It does **not** automatically apply live forecast values to actual equipment.

## Run on your computer — requires Jac/Jaseci installation

**Step 1: Check your Jac version and adapt syntax if needed**

```bash
python -m pip install jaclang jac-cloud
jac --version
jac check jac/model.jac
jac check jac/seed.jac
jac check jac/engine.jac
jac check jac/agents.jac
jac check jac/api.jac
```

`jac`/Jac Cloud CLI options and walker mounting may differ by version. Consult the installed `jac --help` and Jac Cloud docs. The above commands were not run successfully here because `jaclang` was unavailable, so **version adjustments may be needed before the project can launch**.

**Step 2: Launch the Jac walker backend** (example; adjust for installed Jac Cloud):

```bash
jac serve jac/api.jac --port 8000
```

Expected walker endpoint (confirm in your Jac server logs): `POST http://127.0.0.1:8000/walker/PortMindAPI` with walker fields:

```json
{"action":"state","payload":{},"actor_role":"OBSERVER"}
```

The `WorldStore` node retains the world snapshot at the Jac graph root. If your Jac Cloud version uses different walker initialization or API routing, update `jac/api.jac` and the proxy's `PORTMIND_JAC_URL`; **don't** replace the simulator with JavaScript.

**Step 3: Launch the same-origin web UI and API proxy** in a second terminal:

```bash
python dev_server.py
```

Open `http://127.0.0.1:5500`.

You can override the Jac URL by setting `PORTMIND_JAC_URL`. The local proxy exists to avoid browser CORS issues, not to execute operations logic.

### What to test immediately

1. Reset → +5 min should increment simulated clock and vessel positions.
2. Play → vessel markers and truck stages should advance every 2 real seconds. Pause should stop progress.
3. Trigger C2 failure → cargo affected → run nine agents → verified substitution proposal or explicit no-feasible-plan outcome.
4. Switch role to Observer → approval rejected. Manager demo role → approval of a current verified plan.
5. Search `PMCU7700000`, compare container flow and events; inspect import gate-out and export-to-quay movement after ticks.
6. Switch to the **Live Weather Report** → refresh Open-Meteo. When offline, show unavailable state, not fabricated weather.
7. Advance through 14:00 → crane/drivers should hand over or mark assets as unavailable without abandoning container jobs.
8. Test all berth compatibility and crane setup constraints, then export a JSON audit report.

**Demo role selection is not server-side authentication**. Do not deploy this as a production multi-user system. True authentication and durable per-user permissions are future integration work.

## Tests and verification

Tests that can run in this offline package:

```bash
python -m unittest discover -s tests -v
node --check web/app.js
```

These validate source and fixture consistency, Jac source presence, browser syntax, and the explicit code-percentage formula. They **DO NOT** compile or execute Jac code.

The GitHub Actions workflow includes static checks on push; it also offers a manually triggered Jac syntax-check job with online package installation. Failures in that optional job indicate migration work still required before hackathon submission.

## Important architecture notes

- All intended runtime simulation decisions live in `jac/engine.jac` and `jac/agents.jac`.
- `jac/api.jac` defines the walker interface and a graph-anchored `WorldStore` node; `jac/model.jac` provides typed domain graph nodes/edges and specialist investigation walkers. **Not every domain entity is yet mirrored into graph edges**; the authoritative world snapshot remains a graph-attached dictionary. Completing full graph traversal is recommended before claiming deep Jac graph usage.
- Workers and shifts are fictional; rates and weather restrictions are demonstration assumptions.
- Nine operational specialists are deterministic agent functions, **not nine LLM API calls**. The grounded chat is a rule-based query assistant, not a natural-language foundation model integration.
- The proposed plan updates automatically after relevant simulation incidents. Applying any suggested changes requires manager demo-role confirmation. Never connect demo approval to live port dispatch.
- GitHub Pages can host static `web/` assets but **cannot execute a Jac backend**; use a backend-capable host and reverse proxy for a working deployed app.

## Manual GitHub upload

1. Create a GitHub repository named `PortMind-AI-Colombo-Jac90`.
2. Extract this ZIP and upload **the contents** of its folder (including `.github`, `jac`, `web`, `tests`, `dev_server.py`, `README.md`).
3. Commit and check the static workflow in Actions.
4. Run the optional Jac syntax job, correct version-specific errors, then verify the live local workflow above.
5. Record a truthful hackathon demo only after you have a successful Jac-backed end-to-end run.

This software is a synthetic teaching/hackathon example, **not an operating system for real Colombo Port navigation, crane control, customs, workers, weather safety or container dispatch**.
