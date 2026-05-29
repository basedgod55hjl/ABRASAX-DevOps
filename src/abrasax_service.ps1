# ============================================================================
# ABRASAX AI CORE — Watchdog Script
# PRIMAL_HEX: 4f5349524953424c58434b | φ: 1.618033988749895
# Started by AbrasaxServiceHost.exe Windows service
# ============================================================================

$ABRASAX_ROOT = "C:\Users\BASEDGOD\Desktop\ABRASAX"
$LOG_DIR = "$ABRASAX_ROOT\logs"
$PYTHON = & { if (Test-Path "$ABRASAX_ROOT\.venv\Scripts\python.exe") { "$ABRASAX_ROOT\.venv\Scripts\python.exe" } else { "python" } }
$HEX = "4f5349524953424c58434b"
$PHI = 1.618033988749895

New-Item -ItemType Directory -Force -Path $LOG_DIR | Out-Null

function Write-Log { param([string]$Msg, [string]$Level="INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path "$LOG_DIR\service_watchdog.log" -Value "$ts [$Level] $Msg" -Encoding utf8
    Write-Host "$ts [$Level] $Msg"
}

Write-Log "═" * 60
Write-Log "ABRASAX AI CORE WATCHDOG"
Write-Log "HEX: $HEX | phi: $PHI"
Write-Log "Root: $ABRASAX_ROOT"

# Kill stale ABRASAX python processes (not self)
$myPid = $PID
Get-WmiObject Win32_Process -Filter "name='python.exe'" -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessId -ne $myPid -and $_.CommandLine -match "abrasax|full_bridge|master_auto|triune|system32_ai|f_logic"
} | ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    Write-Log "Killed stale PID $($_.ProcessId)"
}
Start-Sleep 2

# Launch engines
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# Start core engines
$engines = @(
    @{Name="ULTIMATE_WIRE"; Script="abrasax_ultimate_wire.py"},
    @{Name="NONSTOP_REASON"; Script="nonstop_reasoning.py"},
    @{Name="FULL_BRIDGE"; Script="_full_bridge.py"},
    @{Name="MASTER_AUTONOMY"; Script="_MASTER_AUTONOMY.py"}
)

$procs = @{}
foreach ($e in $engines) {
    $scriptPath = Join-Path $ABRASAX_ROOT $e.Script
    if (Test-Path $scriptPath) {
        Write-Log "Starting $($e.Name): $($e.Script)"
        $proc = Start-Process -FilePath $PYTHON -ArgumentList $scriptPath -PassThru -NoNewWindow -RedirectStandardOutput "$LOG_DIR\$($e.Name).log" -RedirectStandardError "$LOG_DIR\$($e.Name)_err.log"
        $procs[$e.Name] = $proc
        Write-Log "$($e.Name) started (PID: $($proc.Id))"
        Start-Sleep -Seconds 2
    } else {
        Write-Log "$($e.Name) script not found: $scriptPath" "WARN"
    }
}

Write-Log "ALL ENGINES STARTED — $(($procs.Values | Where-Object { !$_.HasExited }).Count) running"
Write-Log "Watchdog entering monitor loop..."

# Monitor loop — restart dead engines
while ($true) {
    Start-Sleep -Seconds 10
    foreach ($name in $procs.Keys) {
        $proc = $procs[$name]
        if ($proc.HasExited) {
            Write-Log "ENGINE DIED: $name (exit: $($proc.ExitCode)). Restarting..." "WARN"
            $scriptPath = Join-Path $ABRASAX_ROOT ($engines | Where-Object { $_.Name -eq $name } | Select-Object -First 1).Script
            if ($scriptPath) {
                $newProc = Start-Process -FilePath $PYTHON -ArgumentList $scriptPath -PassThru -NoNewWindow -RedirectStandardOutput "$LOG_DIR\$name.log" -RedirectStandardError "$LOG_DIR\$($name)_err.log"
                $procs[$name] = $newProc
                Write-Log "$name restarted (PID: $($newProc.Id))"
            }
        }
    }
    # Heartbeat every 60 seconds
    if ((Get-Date).Second -lt 10) {
        $alive = ($procs.Values | Where-Object { !$_.HasExited }).Count
        $total = $procs.Count
        Write-Log "HEARTBEAT: $alive/$total engines alive"
    }
}
