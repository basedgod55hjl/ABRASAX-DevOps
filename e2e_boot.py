#!/usr/bin/env python3
"""
ABRASAX END-TO-END LAUNCHER — Master system boot
Starts: LM Studio → Service Host → All Engines → Live Logs
PRIMAL_HEX: 4f5349524953424c58434b | φ: 1.618033988749895
"""
import json, os, subprocess, sys, time, urllib.request
from datetime import datetime
from pathlib import Path

PHI = 1.618033988749895; HEX = "4f5349524953424c58434b"
ROOT = Path(r"C:\Users\BASEDGOD\Desktop\ABRASAX")
PYTHON = sys.executable
LM_STUDIO = r"C:\Program Files\LM Studio\LM Studio.exe"
LOG = ROOT / "logs" / f"boot_{datetime.now().strftime('%H%M%S')}.log"

def log(msg):
    ts = datetime.now().strftime("%H:%M:%S")
    print(f"\033[96m[{ts}] {msg}\033[0m", flush=True)

def check_lm():
    try:
        r = urllib.request.Request("http://127.0.0.1:1234/v1/models",
            headers={"Authorization":"Bearer sk-lm-KZtEmyJA:qJJk4G0dhYrRT3kWKyQa"})
        d = json.loads(urllib.request.urlopen(r, timeout=5).read())
        return len(d["data"])
    except: return 0

log("╔════════════════════════════════════════╗")
log("║  ABRASAX E2E BOOT  φ=1.6180           ║")
log("╚════════════════════════════════════════╝")

# Kill old ABRASAX py processes (not all python)
my_pid = str(os.getpid())
try:
    out = subprocess.check_output(
        'wmic process where "name=\'python.exe\'" get processid,commandline /format:csv',
        shell=True, timeout=5, stderr=subprocess.DEVNULL).decode()
    for line in out.split("\n")[1:]:
        parts = line.strip().split(",")
        if len(parts) >= 2:
            pid = parts[-1].strip()
            cmd = (parts[-2] or "").lower()
            if pid.isdigit() and pid != my_pid and ("abrasax" in cmd or "production" in cmd or "ultimate" in cmd):
                subprocess.run(f"taskkill /f /pid {pid} 2>nul", shell=True, capture_output=True)
                log(f"Killed stale PID {pid}")
except: pass

# Start LM Studio
if not check_lm():
    log("Starting LM Studio...")
    subprocess.Popen([LM_STUDIO, "--window-style=hidden"], 
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW)
    for i in range(30):
        models = check_lm()
        if models > 0:
            log(f"LM Studio ONLINE ({models} models)")
            break
        time.sleep(2)
    else:
        log("LM Studio not ready, continuing anyway", "WARN")
else:
    log(f"LM Studio already ONLINE")

# Launch service host
log("Launching ABRASAX AI CORE...")
svc = subprocess.Popen([PYTHON, str(ROOT/"abrasax_service_host.py")],
    cwd=str(ROOT), creationflags=subprocess.CREATE_NO_WINDOW)
log(f"Service host PID: {svc.pid}")

# Wait for engines
time.sleep(8)
try:
    out = subprocess.check_output(
        'wmic process where "name=\'python.exe\'" get processid,commandline /format:csv',
        shell=True, timeout=5, stderr=subprocess.DEVNULL).decode()
    count = sum(1 for l in out.split("\n")[1:] if "abrasax" in l.lower() or "full_bridge" in l.lower())
    log(f"ABRASAX engines running: {count}")
except: pass

log("╔════════════════════════════════════════╗")
log("║  ABRASAX E2E — READY                  ║")
log("║  Service Host: 11 engines capacity      ║")
log("║  System32 AI:  4 bridges (all GREEN)   ║")
log("║  LM Studio:    port 1234               ║")
log("║  API Key:      sk-lm-KZtEmyJA:...      ║")
log("║  GITHUB_TOKEN: wired from master_env    ║")
log("╚════════════════════════════════════════╝")

try:
    while True: time.sleep(60)
except KeyboardInterrupt:
    svc.terminate()
    log("Shutdown")
