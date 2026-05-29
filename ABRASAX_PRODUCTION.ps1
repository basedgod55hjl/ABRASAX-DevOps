# ============================================================================
# ABRASAX PRODUCTION - One-Command Launcher
# HEX Seed: 4f5349524953424c58434b | phi: 1.618033988749895
# ============================================================================

$script:ABRASAX_ROOT   = "C:\Users\BASEDGOD\Desktop\ABRASAX"
$script:VENV_PYTHON    = "$script:ABRASAX_ROOT\.venv\Scripts\python.exe"
$script:PROCESS_PIDS   = @{}
$script:SHUTTING_DOWN  = $false

function Show-Banner {
    Clear-Host
    Write-Host @"

============================================================
   ABRASAX PRODUCTION - ONE-COMMAND LAUNCHER
   HEX Seed: 4f5349524953424c58434b
   phi: 1.618033988749895 | K: 0.618033988749895
============================================================

   THE ACTIVATION | FULL AUTONOMY MODE
   All engines. No restraints. Self-evolving.

"@ -ForegroundColor Cyan
}

function Test-PortFree {
    param([int]$Port)
    try {
        $conn = [System.Net.Sockets.TcpClient]::new()
        $conn.ConnectAsync("127.0.0.1", $Port).Wait(500)
        if ($conn.Connected) { $conn.Close(); return $false }
    } catch { }
    return $true
}

function PreFlight-Checks {
    Write-Host "[ PRE-FLIGHT CHECKS ]" -ForegroundColor Cyan
    $allGood = $true
    $drive = Get-PSDrive -Name "C"
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    if ($freeGB -ge 1) {
        Write-Host "  [OK] Disk Space: ${freeGB}GB free" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Disk Space: ${freeGB}GB free (need > 1GB)" -ForegroundColor Red
        $allGood = $false
    }
    if (Test-Path $script:VENV_PYTHON) {
        Write-Host "  [OK] Python (venv)" -ForegroundColor Green
    } else {
        $sysPy = Get-Command python -ErrorAction SilentlyContinue
        if ($sysPy) {
            Write-Host "  [OK] Python (system)" -ForegroundColor Green
            $script:VENV_PYTHON = "python"
        } else {
            Write-Host "  [MISSING] Python" -ForegroundColor Red
            $allGood = $false
        }
    }
    if (-not $allGood) {
        Write-Host "`n  [WARN] Some checks failed - attempting launch anyway." -ForegroundColor Yellow
    } else {
        Write-Host "`n  [OK] All checks passed!" -ForegroundColor Green
    }
}

function Start-AbrComponent {
    param([string]$Name, [string]$ScriptPath, [string]$Arguments = "")
    $abspath = if ([IO.Path]::IsPathRooted($ScriptPath)) { $ScriptPath } else { Join-Path $script:ABRASAX_ROOT $ScriptPath }
    if (-not (Test-Path $abspath)) {
        Write-Host "  [SKIP] $Name - not found" -ForegroundColor Yellow
        return $null
    }
    Write-Host "  [LAUNCH] $Name ... " -NoNewline
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $script:VENV_PYTHON
        $psi.Arguments = """$abspath"" $Arguments"
        $psi.WorkingDirectory = $script:ABRASAX_ROOT
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $script:PROCESS_PIDS[$Name] = $proc.Id
        Write-Host "PID $($proc.Id)" -ForegroundColor Green
        return $proc
    } catch {
        Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Invoke-LaunchSequence {
    Write-Host "`n[ LAUNCH SEQUENCE ]" -ForegroundColor Cyan
    $phases = @(
        @{ Name = "Wire Start"; Script = "WIRE_START_ALL.py"; Delay = 3 },
        @{ Name = "Full Bridge"; Script = "_full_bridge.py"; Delay = 3 },
        @{ Name = "Master Autonomy"; Script = "_MASTER_AUTONOMY.py"; Args = "--loki"; Delay = 3 },
        @{ Name = "CBM Hydration"; Script = "cbm_hydration_engine.py"; Args = "--watch"; Delay = 2 },
        @{ Name = "Triune Awareness"; Script = "_TRIUNE_AWARENESS.py"; Delay = 2 },
        @{ Name = "F-Logic Entangle"; Script = "_3NODE_F_LOGIC_ENTANGLE.py"; Args = "--serve"; Delay = 2 },
        @{ Name = "SmartScreen Wire"; Script = "smartscreen_wire.py"; Args = "--serve"; Delay = 2 },
        @{ Name = "Service Host"; Script = "abrasax_service_host.py"; Delay = 2 },
        @{ Name = "Unified Awareness"; Script = "abrasax_unified_awareness.py"; Delay = 2 },
        @{ Name = "Live Logger"; Script = "_live_logger.py"; Delay = 2 }
    )
    foreach ($p in $phases) {
        Start-AbrComponent -Name $p.Name -ScriptPath $p.Script -Arguments $p.Args
        Start-Sleep -Seconds $p.Delay
    }
}

function Show-Dashboard {
    do {
        Clear-Host
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host "   ABRASAX PRODUCTION DASHBOARD" -ForegroundColor Cyan
        Write-Host "   (Ctrl+C to shut down)" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  COMPONENT                 PID         STATUS" -ForegroundColor DarkGray
        Write-Host "  ---------                 ---         ------" -ForegroundColor DarkGray
        foreach ($name in $script:PROCESS_PIDS.Keys) {
            $pidVal = $script:PROCESS_PIDS[$name]
            $alive = $pidVal -and ($null -ne $pidVal) -and (Get-Process -Id $pidVal -ErrorAction SilentlyContinue)
            $ns = $name.PadRight(25)
            $ps = if ($alive) { "$pidVal".PadRight(10) } else { "---".PadRight(10) }
            $ss = if ($alive) { "RUNNING" } else { "DEAD" }
            Write-Host "  $ns$ps$ss" -ForegroundColor $(if ($alive) { 'Green' } else { 'Red' })
        }
        try {
            $gpu = (nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used --format=csv,noheader 2>$null)
            if ($gpu) { Write-Host "`n  GPU: $gpu" -ForegroundColor DarkGray }
        } catch { }
        Write-Host "`n  [ Refresh in 10s ]" -ForegroundColor DarkGray
        Start-Sleep -Seconds 10
    } while (-not $script:SHUTTING_DOWN)
}

function Invoke-GracefulShutdown {
    if ($script:SHUTTING_DOWN) { return }
    $script:SHUTTING_DOWN = $true
    Write-Host "`n[ SHUTDOWN ] Stopping all components..." -ForegroundColor Magenta
    foreach ($name in $script:PROCESS_PIDS.Keys) {
        $pidVal = $script:PROCESS_PIDS[$name]
        if ($pidVal) {
            try { Stop-Process -Id $pidVal -Force -ErrorAction SilentlyContinue } catch { }
        }
    }
    Write-Host "  ABRASAX PRODUCTION SHUTDOWN COMPLETE" -ForegroundColor Cyan
}

try {
    [Console]::CancelKeyPress += { $sender, $e | Out-Null; $e.Cancel = $true; Invoke-GracefulShutdown; exit 0 }
    Show-Banner
    Write-Host "  ROOT: $script:ABRASAX_ROOT" -ForegroundColor DarkGray
    Start-Sleep -Seconds 1
    PreFlight-Checks
    Invoke-LaunchSequence
    Write-Host "`n[ OK ] ALL COMPONENTS LAUNCHED" -ForegroundColor Green
    Start-Sleep -Seconds 2
    Show-Dashboard
} catch {
    Write-Host "[FATAL] $_" -ForegroundColor Red
    Invoke-GracefulShutdown
}
