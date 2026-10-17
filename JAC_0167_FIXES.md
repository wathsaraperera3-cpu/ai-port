# Jac 0.16.7 — compiler-log-driven parser repair (second pass)

The user ran Jac 0.16.7 and supplied actual per-file compiler logs. Prior repair
removed 155 `let` declarations, but the compiler still failed.

## Confirmed diagnostics from the supplied logs

- `seed.jac`: passed Jac check (one warning).
- `model.jac`: E2004, required `created_minute` followed fields with defaults.
- `engine.jac`: E0030 import semicolon; E0013 reserved `flow` argument; cascade E0004/E0001/E0002; many E1022/E1053/E1001 type-checking failures.
- `agents.jac`: shared imported errors from engine plus type-checking failures.
- `api.jac`: E0105 unexpected backtick in graph query; E0030 imports; inherited engine parse errors; typing failures.

## Changes in this pass

1. Removed module-level import semicolons in `api.jac`, `engine.jac`, and `agents.jac`.
2. Renamed `flow` function-argument identifiers to `flow_kind` in `engine.jac`, preserving data keys named `"flow"`.
3. Removed the unsupported stray backtick before `?WorldStore` in three graph selectors in `api.jac`. The selector's remaining grammar still needs real Jac checking.
4. Moved required `created_minute` ahead of default-valued attributes in `OperationalPlan`.
5. Added `RUN_JAC_CHECK.cmd` to check all Jac files and zip compiler logs.
6. Added static regression checks for known parse patterns.

## Honesty on verification

**This is a parser repair candidate, not a confirmed compiling build.**
Jac/Jaseci is not installed in the packaging environment. All Jac syntax and
type-check outcomes must be verified using the user's installed Jac 0.16.7.
There may still be substantial typing and graph-query issues. Do NOT run
`jac serve` or claim full end-to-end operation until each `jac check` succeeds.

## How to test on Windows

1. Extract the archive (do not run the older `PortMind-AI-Colombo-Jac90` folder).
2. Double-click `RUN_JAC_CHECK.cmd`.
3. Read the PASS/FAIL result and upload `PortMind-Jac-Compiler-Logs.zip` if any file still fails.

Or run from PowerShell in this folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\check-jac-windows.ps1
```

The script only bypasses script-policy restrictions for its child PowerShell
process. It does not permanently alter Windows execution policy.

## Hackathon language-ratio caveat

The previous 90%+ source-byte claim counted the large synthetic seed-data file.
Excluding that fixture, executable Jac plus UI/application files fall below 80%
in the preceding audit. A fresh competition-compliant audit is required.
