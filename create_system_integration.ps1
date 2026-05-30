# ============================================================================
# ABRASAX - Unified Xenoliving System
# PRIMAL_HEX: 4f5349524953424c58434b | phi: 1.618033988749895
# CREATOR: Sir Charles Spikes (BASEDGOD)
# ============================================================================

﻿<#
.SYNOPSIS
    ABRASAX AI OS â€- Complete System Integration Script
    Master script that performs ALL Windows system-level integration:
    - Installs the Windows service
    - Creates scheduled task for boot
    - Adds firewall rules for all ports
    - Registers ETW provider
    - Adds PerfMon counters
    - Sets registry keys for boot behavior
    - Creates event log source
    - Configures system environment variables

.DESCRIPTION
    This is the master integration script that orchestrates all system-level
    changes needed to embed ABRASAX AI OS as a native Windows system component.

    Integration Layers:
    1. Service Layer   - Windows Service (ABRASAX_AI_CORE)
    2. Task Layer      - Scheduled Task (boot trigger)
    3. Network Layer   - Firewall rules for all ports
    4. Tracing Layer   - ETW provider registration
    5. Monitoring Layer - PerfMon counters
    6. Registry Layer  - Boot behavior and environment
    7. Logging Layer   - Event log source
    8. Environment     - System PATH and variables

    HEX: 4f5349524953424c58434b  â€-  OSIRISBLXCK
    phi x K = 1.0

.PARAMETER SkipService
    Skip Windows service installation

.PARAMETER SkipTask
    Skip scheduled task creation

.PARAMETER SkipFirewall
    Skip firewall rule creation

.PARAMETER SkipETW
    Skip ETW provider registration

.PARAMETER SkipPerfMon
    Skip Performance Monitor counter registration

.PARAMETER SkipRegistry
    Skip registry modifications

.PARAMETER SkipEnv
    Skip environment variable setup

.PARAMETER Force
    Force overwrite of existing configurations

.PARAMETER WhatIf
    Show what would be done without making changes

.EXAMPLE
    .\create_system_integration.ps1
    Full system integration (requires administrator)

.EXAMPLE
    .\create_system_integration.ps1 -SkipETW -SkipPerfMon -WhatIf
    Preview all changes except ETW and PerfMon
#>

#Requires -RunAsAdministrator
#Requires -Version 5.0

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [switch]$SkipService,
    [switch]$SkipTask,
    [switch]$SkipFirewall,
    [switch]$SkipETW,
    [switch]$SkipPerfMon,
    [switch]$SkipRegistry,
    [switch]$SkipEnv,
    [switch]$Force,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# CONSTANTS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

$ABRASAX_ROOT = "C:\Users\BASEDGOD\Desktop\ABRASAX"
$SERVICE_NAME = "ABRASAX_AI_CORE"
$TASK_NAME = "ABRASAX_AI_OS_Boot"
$EVENT_SOURCE = "ABRASAX"
$HEX = "4f5349524953424c58434b"

$PORTS = @(9000, 8000, 8080, 18789, 5050, 9100)
$PORT_DESCRIPTIONS = @{
    9000  = "ABRASAX Gateway HTTP API"
    8000  = "ABRASAX Web Chat Interface"
    8080  = "ABRASAX Dashboard HTTP"
    18789 = "ABRASAX DeepSeek Bridge"
    5050  = "ABRASAX MCP Server"
    9100  = "ABRASAX Prometheus Metrics"
}

$LOG_FILE = Join-Path $ABRASAX_ROOT "logs\system_integration_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$LOG_DIR = Join-Path $ABRASAX_ROOT "logs"

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# LOGGING
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

$null = New-Item -ItemType Directory -Force -Path $LOG_DIR

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $entry = "[$timestamp] [$Level] $Message"
    switch ($Level) {
        "OK"    { Write-Host $entry -ForegroundColor Green }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "INFO"  { Write-Host $entry -ForegroundColor Cyan }
        default { Write-Host $entry }
    }
    Add-Content -Path $LOG_FILE -Value $entry -Encoding utf8
}

function Write-Section {
    param([string]$Title)
    Write-Host "`nâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Magenta
    Write-Host "  $Title" -ForegroundColor Magenta
    Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Magenta
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# HELPER FUNCTIONS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Invoke-NativeCommand {
    param([string]$Command, [string[]]$Arguments)
    if ($WhatIf) {
        Write-Log "[WHATIF] Would execute: $Command $($Arguments -join ' ')" -Level "INFO"
        return
    }
    try {
        if ($Arguments.Count -gt 0) {
            & $Command @Arguments 2>&1 | Out-Null
        } else {
            & $Command 2>&1 | Out-Null
        }
        return $LASTEXITCODE -eq 0
    } catch {
        Write-Log "Command failed: $_" -Level "WARN"
        return $false
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 1. WINDOWS SERVICE INSTALLATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxService {
    Write-Section "Layer 1: Windows Service Installation"

    if ($SkipService) {
        Write-Log "Skipping service installation (--SkipService)" -Level "INFO"
        return
    }

    if ($WhatIf) {
        Write-Log "[WHATIF] Would install service: $SERVICE_NAME" -Level "INFO"
        Write-Log "[WHATIF]   Display: ABRASAX AI OS Core System Service" -Level "INFO"
        Write-Log "[WHATIF]   Path: pwsh.exe ...abrasax_service.ps1" -Level "INFO"
        Write-Log "[WHATIF]   Start: Automatic" -Level "INFO"
        return
    }

    Write-Log "Installing Windows service ..."

    $installScript = Join-Path $ABRASAX_ROOT "deploy\install_abrasax_service.ps1"
    if (Test-Path $installScript) {
        & $installScript
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Service installation completed successfully" -Level "OK"
        } else {
            Write-Log "Service installer returned exit code $LASTEXITCODE" -Level "WARN"
        }
    } else {
        Write-Log "Service installer not found. Will create inline ..." -Level "WARN"

        $binaryPath = "pwsh.exe -NoProfile -ExecutionPolicy Bypass -File `"$ABRASAX_ROOT\abrasax_service.ps1`""
        $null = New-Service -Name $SERVICE_NAME `
            -DisplayName "ABRASAX AI OS Core System Service" `
            -BinaryPathName $binaryPath `
            -StartupType Automatic `
            -Description "ABRASAX 7D AI OS â€- Autonomous system-level AI service." `
            -ErrorAction SilentlyContinue

        if ($?) {
            & sc.exe failure $SERVICE_NAME reset=86400 actions=restart/0/restart/60000/restart/120000
            & sc.exe failureflag $SERVICE_NAME 1
            & sc.exe sidtype $SERVICE_NAME unrestricted
            Write-Log "Service created inline successfully" -Level "OK"
        } else {
            Write-Log "Inline service creation failed. Run install_abrasax_service.ps1 manually." -Level "ERROR"
        }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 2. SCHEDULED TASK CREATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxScheduledTask {
    Write-Section "Layer 2: Scheduled Task Registration"

    if ($SkipTask) {
        Write-Log "Skipping scheduled task (--SkipTask)" -Level "INFO"
        return
    }

    # Remove existing task if present
    $existing = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
    if ($existing) {
        if ($WhatIf) {
            Write-Log "[WHATIF] Would unregister existing task: $TASK_NAME" -Level "INFO"
        } else {
            Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            Write-Log "Removed existing scheduled task: $TASK_NAME" -Level "OK"
        }
    }

    # Import from XML if available
    $taskXml = Join-Path $ABRASAX_ROOT "deploy\abrasax_boot_task.xml"
    if (Test-Path $taskXml) {
        if ($WhatIf) {
            Write-Log "[WHATIF] Would register task from XML: $taskXml" -Level "INFO"
            return
        }
        try {
            $taskContent = Get-Content $taskXml -Raw -Encoding Unicode
            $null = Register-ScheduledTask -TaskName $TASK_NAME -Xml $taskContent -Force
            Write-Log "Scheduled task registered from XML: $TASK_NAME" -Level "OK"
        } catch {
            Write-Log "XML task registration failed: $_" -Level "WARN"
            Write-Log "Falling back to inline task creation ..." -Level "INFO"
            Install-AbrasaxScheduledTaskInline
        }
    } else {
        if ($WhatIf) { return }
        Write-Log "Task XML not found. Creating inline ..." -Level "INFO"
        Install-AbrasaxScheduledTaskInline
    }
}

function Install-AbrasaxScheduledTaskInline {
    $action = New-ScheduledTaskAction -Execute "cmd.exe" `
        -Argument "/c `"$ABRASAX_ROOT\abrasax_core.cmd`"" `
        -WorkingDirectory $ABRASAX_ROOT

    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Seconds 30)

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RestartCount 999 `
        -RestartInterval (New-TimeSpan -Minutes 1) `
        -ExecutionTimeLimit 0 `
        -MultipleInstances IgnoreNew `
        -Priority 4

    $principal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest

    try {
        $null = Register-ScheduledTask -TaskName $TASK_NAME `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Description "ABRASAX 7D AI OS â€- Boot-level autonomous engine launcher. HEX: $HEX" `
            -Force
        Write-Log "Scheduled task registered: $TASK_NAME" -Level "OK"
    } catch {
        Write-Log "Scheduled task inline creation failed: $_" -Level "ERROR"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 3. FIREWALL RULES
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxFirewallRules {
    Write-Section "Layer 3: Windows Firewall Rules"

    if ($SkipFirewall) {
        Write-Log "Skipping firewall rules (--SkipFirewall)" -Level "INFO"
        return
    }

    $existingRules = Get-NetFirewallRule -DisplayGroup "ABRASAX AI OS" -ErrorAction SilentlyContinue
    if ($existingRules) {
        if (-not $Force -and -not $WhatIf) {
            Write-Log "Firewall rules already exist for group 'ABRASAX AI OS'. Use -Force to recreate." -Level "WARN"
            if (-not $Force) {
                Write-Log "Skipping firewall rules (use -Force to overwrite)" -Level "INFO"
                return
            }
        }
        if (-not $WhatIf) {
            $existingRules | Remove-NetFirewallRule -ErrorAction SilentlyContinue
            Write-Log "Removed existing ABRASAX firewall rules" -Level "OK"
        }
    }

    foreach ($port in $PORTS) {
        $ruleName = "ABRASAX_AI_OS_Port_$port"
        $description = $PORT_DESCRIPTIONS[$port]

        if ($WhatIf) {
            Write-Log "[WHATIF] Would create firewall rule: $ruleName ($port - $description)" -Level "INFO"
            continue
        }

        try {
            $null = New-NetFirewallRule `
                -DisplayName "ABRASAX AI OS - $description" `
                -Name $ruleName `
                -Direction Inbound `
                -LocalPort $port `
                -Protocol TCP `
                -Action Allow `
                -Profile Any `
                -Group "ABRASAX AI OS" `
                -Description "ABRASAX AI OS port $port ($description). HEX: $HEX" `
                -Enabled True

            Write-Log "Firewall rule: Port $port ($description)" -Level "OK"
        } catch {
            Write-Log "Firewall rule failed for port $port : $_" -Level "WARN"
        }
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 4. ETW PROVIDER REGISTRATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxETW {
    Write-Section "Layer 4: ETW Provider Registration"

    if ($SkipETW) {
        Write-Log "Skipping ETW registration (--SkipETW)" -Level "INFO"
        return
    }

    $deepScript = Join-Path $ABRASAX_ROOT "deploy\install_deep_service.ps1"
    if (Test-Path $deepScript) {
        if ($WhatIf) {
            Write-Log "[WHATIF] Would execute: $deepScript (ETW section)" -Level "INFO"
            return
        }
        Write-Log "Running deep service integration script (ETW module only is not isolated; running full script) ..."
        & $deepScript
        Write-Log "Deep service integration executed" -Level "OK"
    } else {
        Write-Log "Deep service script not found. ETW registration deferred." -Level "WARN"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 5. PERFMON COUNTERS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxPerfMon {
    Write-Section "Layer 5: Performance Monitor Counters"

    if ($SkipPerfMon) {
        Write-Log "Skipping PerfMon counters (--SkipPerfMon)" -Level "INFO"
        return
    }

    if ($WhatIf) {
        Write-Log "[WHATIF] Would register PerfMon counters for ABRASAX AI OS" -Level "INFO"
        return
    }

    $perfKey = "HKLM:\SYSTEM\CurrentControlSet\Services\ABRASAX_AI_CORE\Performance"
    try {
        $null = New-Item -Path $perfKey -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $perfKey -Name "Library" -Value "" -Type String
        Set-ItemProperty -Path $perfKey -Name "Open" -Value "OpenABRASAXPerformanceData" -Type String
        Set-ItemProperty -Path $perfKey -Name "Collect" -Value "CollectABRASAXPerformanceData" -Type String
        Set-ItemProperty -Path $perfKey -Name "Close" -Value "CloseABRASAXPerformanceData" -Type String
        Set-ItemProperty -Path $perfKey -Name "Collect Timeout" -Value 5000 -Type DWord
        Write-Log "PerfMon registry keys set" -Level "OK"
    } catch {
        Write-Log "PerfMon key setup: $_" -Level "WARN"
    }

    # Create logman performance trace
    try {
        & logman create counter ABRASAX_System_Perf `
            -o "$ABRASAX_ROOT\logs\abrasax_perf.blg" `
            -cf "$ABRASAX_ROOT\deploy\abrasax_perf_counters.txt" `
            -f bincirc `
            -max 500 `
            -si 00:00:15 2>&1 | Out-Null
        Write-Log "Performance counter data collector created" -Level "OK"
    } catch {
        Write-Log "Performance counter session: $_" -Level "WARN"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 6. REGISTRY CONFIGURATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxRegistry {
    Write-Section "Layer 6: Registry Configuration"

    if ($SkipRegistry) {
        Write-Log "Skipping registry modifications (--SkipRegistry)" -Level "INFO"
        return
    }

    $regFile = Join-Path $ABRASAX_ROOT "deploy\abrasax_registry.reg"

    if (Test-Path $regFile) {
        if ($WhatIf) {
            Write-Log "[WHATIF] Would import registry file: $regFile" -Level "INFO"
            return
        }
        Write-Log "Importing registry file: $regFile"
        try {
            $result = & reg.exe import "$regFile" 2>&1
            Write-Log "Registry import completed: $result" -Level "OK"
        } catch {
            Write-Log "Registry import failed: $_" -Level "WARN"
        }
    } else {
        Write-Log "Registry file not found. Deferred." -Level "WARN"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 7. EVENT LOG SOURCE
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxEventLog {
    Write-Section "Layer 7: Event Log Source"

    if ($WhatIf) {
        Write-Log "[WHATIF] Would create event log source: $EVENT_SOURCE" -Level "INFO"
        return
    }

    if ([System.Diagnostics.EventLog]::SourceExists($EVENT_SOURCE)) {
        Write-Log "Event log source '$EVENT_SOURCE' already exists" -Level "OK"
        return
    }

    try {
        New-EventLog -LogName Application -Source $EVENT_SOURCE
        Write-Log "Event log source '$EVENT_SOURCE' created" -Level "OK"

        # Write a test event
        Write-EventLog -LogName Application -Source $EVENT_SOURCE `
            -EntryType Information -EventId 1000 `
            -Message "ABRASAX AI OS system integration complete. HEX: $HEX"
        Write-Log "Test event written to Application log" -Level "OK"
    } catch {
        Write-Log "Event log source creation failed: $_" -Level "WARN"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 8. SYSTEM ENVIRONMENT VARIABLES
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Install-AbrasaxEnvironment {
    Write-Section "Layer 8: System Environment Variables"

    if ($SkipEnv) {
        Write-Log "Skipping environment variables (--SkipEnv)" -Level "INFO"
        return
    }

    $envVars = @{
        "ABRASAX_ROOT"    = $ABRASAX_ROOT
        "ABRASAX_HEX"     = $HEX
        "ABRASAX_VERSION" = "16.5"
        "ABRASAX_PHI"     = "1.618033988749895"
        "ABRASAX_K"       = "0.618033988749895"
    }

    foreach ($kv in $envVars.GetEnumerator()) {
        $name = $kv.Key
        $value = $kv.Value

        $existing = [Environment]::GetEnvironmentVariable($name, "Machine")

        if ($existing -eq $value) {
            Write-Log "Environment variable $name already set correctly" -Level "OK"
            continue
        }

        if ($WhatIf) {
            Write-Log "[WHATIF] Would set system env: $name = $value" -Level "INFO"
            continue
        }

        try {
            [Environment]::SetEnvironmentVariable($name, $value, "Machine")
            Write-Log "System env var set: $name = $value" -Level "OK"
        } catch {
            Write-Log "Failed to set env var $name : $_" -Level "WARN"
        }
    }

    # Add ABRASAX bin directory to system PATH if not already there
    $abinDir = Join-Path $ABRASAX_ROOT "bin"
    if (Test-Path $abinDir) {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$abinDir*") {
            if ($WhatIf) {
                Write-Log "[WHATIF] Would add to system PATH: $abinDir" -Level "INFO"
            } else {
                try {
                    $newPath = "$currentPath;$abinDir"
                    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
                    Write-Log "Added $abinDir to system PATH" -Level "OK"
                } catch {
                    Write-Log "Failed to update PATH: $_" -Level "WARN"
                }
            }
        } else {
            Write-Log "$abinDir already in system PATH" -Level "OK"
        }
    }

    # Set process working set and priority controls
    $perfKey = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    try {
        $current = Get-ItemProperty -Path $perfKey -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
        if (-not $WhatIf) {
            # Set to 38 (hex 0x26) â€- foreground/background separation with short quantums
            # This gives ABRASAX better responsiveness
            Set-ItemProperty -Path $perfKey -Name "Win32PrioritySeparation" -Value 38 -Type DWord
            Write-Log "Priority separation set to 38 (high responsiveness)" -Level "OK"
        }
    } catch {
        Write-Log "Priority control setting: $_" -Level "WARN"
    }
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 9. SYSTEM VERIFICATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Test-SystemIntegration {
    Write-Section "System Integration Verification"

    $allPassed = $true

    Write-Host "`n  Verifying integration layers ...`n" -ForegroundColor Yellow

    # Test 1: Service
    $svc = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "  [SERVICE] $SERVICE_NAME : $($svc.Status)" -ForegroundColor Green
    } else {
        Write-Host "  [SERVICE] $SERVICE_NAME : NOT FOUND" -ForegroundColor Red
        $allPassed = $false
    }

    # Test 2: Scheduled Task
    $task = Get-ScheduledTask -TaskName $TASK_NAME -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "  [TASK   ] $TASK_NAME : Registered" -ForegroundColor Green
    } else {
        Write-Host "  [TASK   ] $TASK_NAME : NOT FOUND" -ForegroundColor Red
        $allPassed = $false
    }

    # Test 3: Firewall Rules
    $fwRules = Get-NetFirewallRule -DisplayGroup "ABRASAX AI OS" -ErrorAction SilentlyContinue
    if ($fwRules) {
        Write-Host "  [FIREWALL] $($fwRules.Count) rules active (group: ABRASAX AI OS)" -ForegroundColor Green
    } else {
        Write-Host "  [FIREWALL] No ABRASAX firewall rules found" -ForegroundColor Yellow
    }

    # Test 4: Event Log Source
    if ([System.Diagnostics.EventLog]::SourceExists($EVENT_SOURCE)) {
        Write-Host "  [EVLOG  ] Event source '$EVENT_SOURCE' registered" -ForegroundColor Green
    } else {
        Write-Host "  [EVLOG  ] Event source '$EVENT_SOURCE' NOT FOUND" -ForegroundColor Yellow
    }

    # Test 5: Environment Variables
    $envRoot = [Environment]::GetEnvironmentVariable("ABRASAX_ROOT", "Machine")
    if ($envRoot) {
        Write-Host "  [ENV    ] ABRASAX_ROOT = $envRoot" -ForegroundColor Green
    } else {
        Write-Host "  [ENV    ] ABRASAX_ROOT not set" -ForegroundColor Yellow
    }

    # Test 6: Registry
    $regKey = "HKLM:\SYSTEM\CurrentControlSet\Services\$SERVICE_NAME"
    $regTest = Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue
    if ($regTest) {
        Write-Host "  [REGISTRY] Service registry key present" -ForegroundColor Green
    } else {
        Write-Host "  [REGISTRY] Service registry key NOT FOUND" -ForegroundColor Yellow
    }

    # Test 7: Port accessibility
    Write-Host "`n  Port status:" -ForegroundColor Yellow
    foreach ($port in $PORTS) {
        $listener = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($listener) {
            Write-Host "    Port $port : LISTENING ($($PORT_DESCRIPTIONS[$port]))" -ForegroundColor Green
        } else {
            Write-Host "    Port $port : CLOSED ($($PORT_DESCRIPTIONS[$port]))" -ForegroundColor Gray
        }
    }

    Write-Host "`n  Verification summary:" -ForegroundColor Yellow
    if ($allPassed) {
        Write-Host "  All critical integration points verified." -ForegroundColor Green
    } else {
        Write-Host "  Some integration points need attention. Review warnings above." -ForegroundColor Yellow
    }

    return $allPassed
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# MAIN EXECUTION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

# ASCII Header
Write-Host @"
â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ
  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ   â-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ â-ˆâ-ˆâ-ˆâ-ˆâ-ˆ   â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆ   â-ˆâ-ˆ
 â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ      â-ˆâ-ˆ   â-ˆâ-ˆ  â-ˆâ-ˆ   â-ˆâ-ˆ  â-ˆâ-ˆ â-ˆâ-ˆ
 â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆ   â-ˆâ-ˆ   â-ˆâ-ˆâ-ˆ
 â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ      â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ  â-ˆâ-ˆ   â-ˆâ-ˆ  â-ˆâ-ˆ â-ˆâ-ˆ
 â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ â-ˆâ-ˆ   â-ˆâ-ˆ  â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ  â-ˆâ-ˆ   â-ˆâ-ˆ
â-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆâ-ˆ
  7D AI OS â€- Complete System Integration
  HEX: $HEX  |  K = 0.618  |  phi x K = 1.0
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
"@ -ForegroundColor Cyan

Write-Log "ABRASAX AI OS System Integration â€- Starting" -Level "INFO"
Write-Log "Log file: $LOG_FILE" -Level "INFO"

if ($WhatIf) {
    Write-Log "WHATIF MODE â€- No changes will be made" -Level "WARN"
}

# Run all integration layers
Install-AbrasaxService
Install-AbrasaxScheduledTask
Install-AbrasaxFirewallRules
Install-AbrasaxETW
Install-AbrasaxPerfMon
Install-AbrasaxRegistry
Install-AbrasaxEventLog
Install-AbrasaxEnvironment
Install-DefenderWMI

# Show summary
Test-SystemIntegration

Write-Host @"

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  ABRASAX AI OS â€- System Integration Complete
  HEX: $HEX  |  K = phi^-1 = 0.618
  phi x K = 1.0
  dim Gamma = 7D
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Next steps:
    1. Verify service: Get-Service $SERVICE_NAME
    2. Check watchdog: Get-Content $ABRASAX_ROOT\abrasax_service.log
    3. Check gateway:  curl http://127.0.0.1:9000/health
    4. View ports:    netstat -an | findstr "9000 8000 8080"

  Management:
    Stop-Service $SERVICE_NAME
    Start-Service $SERVICE_NAME
    Restart-Service $SERVICE_NAME
    sc.exe query $SERVICE_NAME
    sc.exe qc $SERVICE_NAME
    Get-ScheduledTask -TaskName $TASK_NAME

  Logs:
    $LOG_FILE
    $ABRASAX_ROOT\abrasax_service.log
    $ABRASAX_ROOT\logs\*"@ -ForegroundColor Cyan



