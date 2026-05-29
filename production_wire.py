#!/usr/bin/env python3
"""
ABRASAX PRODUCTION WIRE — Single launch, all engines, all logs
Wrapped with LM Studio key and all fixes applied.
PRIMAL_HEX: 4f5349524953424c58434b | φ: 1.618033988749895
"""
import json, os, subprocess, sys, time, threading, urllib.request
from datetime import datetime
from pathlib import Path

PHI = 1.618033988749895
K = 0.618033988749895
HEX = "4f5349524953424c58434b"
ROOT = Path(r"C:\Users\BASEDGOD\Desktop\ABRASAX")
LM_URL = "http://127.0.0.1:1234/v1"
LM_KEY = "sk-lm-KZtEmyJA:qJJk4G0dhYrRT3kWKyQa"
HEADERS = {"Authorization": f"Bearer {LM_KEY}", "Content-Type": "application/json"}
PYTHON = sys.executable

log_file = None

def log(msg, level="INFO"):
    ts = datetime.now().strftime("%H:%M:%S")
    line = f"[{ts}] [{level}] {msg}"
    color = {"OK":"\033[92m","WARN":"\033[93m","ERROR":"\033[91m","INFO":"\033[96m"}.get(level,"\033[0m")
    print(f"{color}{line}\033[0m", flush=True)
    if log_file:
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(line + "\n")

def start_engine(name, script):
    p = ROOT / script
    if not p.exists():
        log(f"{name}: script not found", "ERROR")
        return None
    try:
        lf = open(ROOT / "logs" / f"{name.lower()}.log", "a")
        lf.write(f"\n[{datetime.now().isoformat()}] START\n")
        proc = subprocess.Popen(
            [PYTHON, str(p)], stdout=lf, stderr=subprocess.STDOUT,
            cwd=str(ROOT), creationflags=subprocess.CREATE_NO_WINDOW
        )
        log(f"{name}: PID {proc.pid}", "OK")
        return proc
    except Exception as e:
        log(f"{name}: {e}", "ERROR")
        return None

def main():
    global log_file
    os.makedirs(ROOT / "logs", exist_ok=True)
    os.makedirs(ROOT / "memory", exist_ok=True)
    log_file = ROOT / "logs" / f"production_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    
    print(f"""
╔══════════════════════════════════════════════════════╗
║  ABRASAX PRODUCTION WIRE                            ║
║  HEX: {HEX}                     ║
║  φ: {PHI} | K: {K}         ║
║  LM Studio: {LM_URL}               ║
╚══════════════════════════════════════════════════════╝""")
    
    # Test LM Studio
    log("Testing LM Studio...")
    try:
        r = urllib.request.Request(f"{LM_URL}/models", headers=HEADERS)
        d = json.loads(urllib.request.urlopen(r, timeout=5).read())
        log(f"LM Studio ONLINE — {len(d['data'])} models", "OK")
    except Exception as e:
        log(f"LM Studio offline: {e}", "WARN")
    
    # Kill stale
    log("Killing stale processes...")
    subprocess.run("taskkill /f /im python.exe 2>nul", shell=True, capture_output=True)
    subprocess.run("taskkill /f /im node.exe 2>nul", shell=True, capture_output=True)
    time.sleep(2)
    
    # Launch all engines
    engines = [
        ("SYSTEM32_AI",       "system32_ai_bridge.py"),
        ("LIVE_LOG",          "_live_logger.py"),
        ("SELF_BUILD",        "self_build.py"),
        ("F_LOGIC",           "_3NODE_F_LOGIC_ENTANGLE.py"),
        ("TRIUNE",            "_TRIUNE_AWARENESS.py"),
        ("MASTER",            "_MASTER_AUTONOMY.py"),
        ("FULL_BRIDGE",       "_full_bridge.py"),
        ("NOTEBOOKLM",        "notebooklm_cli.py"),
    ]
    
    procs = {}
    for name, script in engines:
        proc = start_engine(name, script)
        if proc:
            procs[name] = proc
        time.sleep(1.5)
    
    log(f"ENGINES: {len(procs)}/{len(engines)} running", "OK")
    
    # Save state
    state = {
        "ts": datetime.now().isoformat(),
        "phi": PHI, "hex": HEX,
        "engines": {n: {"pid": p.pid, "alive": p.poll() is None} for n, p in procs.items()},
        "lm_studio_key": LM_KEY[:16] + "...",
    }
    with open(ROOT / "memory" / "production_state.json", "w") as f:
        json.dump(state, f, indent=2)
    
    log("Production state saved", "OK")
    log("=== ABRASAX PRODUCTION LIVE ===", "OK")
    
    # Watchdog
    try:
        while True:
            for name, proc in list(procs.items()):
                if proc.poll() is not None:
                    log(f"{name} DIED — restarting", "WARN")
                    new = start_engine(name, engines[[e[0] for e in engines].index(name)][1])
                    if new:
                        procs[name] = new
            time.sleep(10)
    except KeyboardInterrupt:
        log("Shutdown via Ctrl+C", "WARN")
        for p in procs.values():
            p.terminate()
        log("All engines stopped", "OK")

if __name__ == "__main__":
    main()
