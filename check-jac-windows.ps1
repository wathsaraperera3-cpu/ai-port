# Run from the extracted PortMind project root in Windows PowerShell.
$ErrorActionPreference = 'Continue'
if (-not (Get-Command jac -ErrorAction SilentlyContinue)) {
    $scripts = python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))"
    if ($scripts) { $env:Path += ";$scripts" }
}
if (-not (Get-Command jac -ErrorAction SilentlyContinue)) {
    Write-Error 'Jac was not found. Try: python -m pip install jaclang'
    exit 1
}
Write-Host 'Using Jac:'
jac --version
$files = @('model.jac','seed.jac','engine.jac','agents.jac','api.jac')
$results = @()
foreach ($file in $files) {
    $path = Join-Path 'jac' $file
    Write-Host "`nChecking $path ..." -ForegroundColor Cyan
    $lines = & jac check $path 2>&1 | ForEach-Object { $_.ToString() }
    $code = $LASTEXITCODE
    $output = Join-Path '.' ("jac-check-" + $file + '.log')
    $lines | Out-File -FilePath $output -Encoding utf8
    $results += [pscustomobject]@{ File=$file; ExitCode=$code; Log=$output }
    if ($code -eq 0) { Write-Host "PASS: $path" -ForegroundColor Green }
    else {
        Write-Host "FAIL: $path. First diagnostics:" -ForegroundColor Red
        $lines | Select-Object -First 30 | ForEach-Object { Write-Host $_ }
    }
}
$results | Format-Table -AutoSize
# Always bundle diagnostics for simple upload back to ChatGPT.
$allLogs = @(Get-ChildItem -File -Filter 'jac-check-*.log' | Select-Object -ExpandProperty FullName)
if ($allLogs.Count -gt 0) {
    Compress-Archive -Path $allLogs -DestinationPath '.\PortMind-Jac-Compiler-Logs.zip' -Force
    Write-Host 'Saved: PortMind-Jac-Compiler-Logs.zip' -ForegroundColor Cyan
}
if (($results | Where-Object { $_.ExitCode -ne 0 }).Count -gt 0) {
    Write-Host 'Jac validation FAILED. Share jac-check-api.jac.log and other failing logs for further repairs.' -ForegroundColor Yellow
    exit 1
}
Write-Host 'Jac syntax checks passed. Runtime integration tests are still required.' -ForegroundColor Green
