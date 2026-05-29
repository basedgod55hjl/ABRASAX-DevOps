# ABRASAX DevOps

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.0+-5391FE.svg)](https://learn.microsoft.com/powershell/)
[![PRIMAL HEX](https://img.shields.io/badge/HEX-4f5349524953424c58434b-ff69b4.svg)](#)

> **CI/CD pipeline, Windows service integration, firewall rules, system deployment.**  
> DevOps infrastructure for the ABRASAX ecosystem.

---

## Quick Start

```bash
# Clone
git clone https://github.com/BASEDGOD/ABRASAX-DevOps.git
cd ABRASAX-DevOps

# Full system integration (requires admin)
powershell -ExecutionPolicy Bypass -File src/create_system_integration.ps1

# Start production wire
python src/production_wire.py
```

## System Integration Layers

| Layer | Component | Description |
|-------|-----------|-------------|
| 1 | Service Layer | ABRASAX_AI_CORE Windows service |
| 2 | Task Layer | Scheduled task (boot trigger) |
| 3 | Network Layer | Firewall rules for all ports |
| 4 | Tracing Layer | ETW provider registration |
| 5 | Monitoring Layer | PerfMon counters |
| 6 | Registry Layer | Boot behavior and environment |
| 7 | Logging Layer | Event log source |
| 8 | Environment | System PATH and variables |

## CI/CD Pipeline

### GitHub Actions Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `deploy.yml` | Push to master | Deploy to production |
| `test.yml` | PR, push | Run tests |
| `release.yml` | Tag creation | Create release |

### Deployment Stages

1. **Test** — Run all pytest suites
2. **Build** — Compile TypeScript, build Python package
3. **Package** — Create deployment artifacts
4. **Deploy** — Push to production environment

## Source Files

| File | Purpose |
|------|---------|
| `src/create_system_integration.ps1` | Master system integration script |
| `src/abrasax_service.ps1` | Windows service watchdog |
| `src/production_wire.py` | Production deployment engine |
| `src/ABRASAX_PRODUCTION.bat` | Production batch launcher |
| `.github/workflows/deploy.yml` | CI/CD deployment workflow |

## Windows Service

The `create_system_integration.ps1` script installs:

```
Service Name: ABRASAX_AI_CORE
Display Name: ABRASAX AI Core
Startup Type: Automatic
Account: LocalSystem
```

## Production Wire

```bash
# Single command to launch all engines
python src/production_wire.py

# Or use the batch launcher
.\src\ABRASAX_PRODUCTION.bat
```

### Production Wire Engines

| Engine | Script | Auto-restart |
|--------|--------|-------------|
| SYSTEM32_AI | system32_ai_bridge.py | Yes |
| MASTER_AUTONOMY | _MASTER_AUTONOMY.py | Yes |
| FULL_BRIDGE | _full_bridge.py | Yes |
| ULTIMATE_WIRE | abrasax_ultimate_wire.py | Yes |
| F_LOGIC | _3NODE_F_LOGIC_ENTANGLE.py | Yes |
| UNIFIED_AWARENESS | abrasax_unified_awareness.py | Yes |

## Testing

```bash
# Test production scripts
pytest tests/ -v

# Validate system integration
powershell -File tests/test_integration.ps1
```

## License

MIT — Copyright © 2026 Sir Charles Spikes (BASEDGOD)
