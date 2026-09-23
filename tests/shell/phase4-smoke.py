#!/usr/bin/env python3
"""
phase4-smoke.py — Verification suite for Phase 4 Desktop Experience & Utilities:
- Open-Meteo Weather integration and data parsing
- Weather IPC handler responsiveness
- Wallpaper service inventory and active symlink reading
- Wallpaper IPC handler responsiveness
- Screenshot workflow (grim, slurp, wl-copy, ~/Pictures/Screenshots)
- Hyprland keybindings (Print, Super+Shift+S, Super+W)
- Quickshell runtime health
"""

import json
import os
import subprocess
import sys
import time

def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)

def test_weather_api():
    print("[1/7] Testing Open-Meteo Weather query for Lucknow, IN...")
    url = (
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=26.8467&longitude=80.9462"
        "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m"
        "&daily=weather_code,temperature_2m_max,temperature_2m_min"
        "&timezone=auto&forecast_days=3"
    )
    res = run(["curl", "-s", "--max-time", "6", url])
    data = json.loads(res.stdout)
    assert "current" in data, "Open-Meteo response missing 'current'"
    assert "daily" in data, "Open-Meteo response missing 'daily'"
    curr = data["current"]
    assert "temperature_2m" in curr and "weather_code" in curr, "Invalid current weather metrics"
    daily = data["daily"]
    assert len(daily.get("time", [])) == 3, "Forecast should have 3 days"
    print(f"      Lucknow: {curr['temperature_2m']}°C, Humidity: {curr['relative_humidity_2m']}%, WMO: {curr['weather_code']}")
    print("      PASSED")

def test_weather_ipc():
    print("[2/7] Testing Weather IPC handler in ghost-shell...")
    res = run(["qs", "ipc", "-c", "ghost-shell", "call", "weather", "refresh"])
    assert res.returncode == 0, f"Weather IPC call failed: {res.stderr}"
    print("      call weather refresh: OK")
    print("      PASSED")

def test_wallpaper_service():
    print("[3/7] Verifying Wallpaper backend and directory contents...")
    res = run(["/home/ashutosh/.local/bin/set-wallpaper", "--current"])
    current_wp = res.stdout.strip()
    assert os.path.isfile(current_wp), f"Current wallpaper link does not point to valid file: {current_wp}"
    
    # Check ~/Pictures/Wallpapers
    wp_dir = os.path.expanduser("~/Pictures/Wallpapers")
    assert os.path.isdir(wp_dir), "Wallpaper directory ~/Pictures/Wallpapers missing"
    files = [f for f in os.listdir(wp_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp', '.jxl'))]
    assert len(files) >= 1, "Expected at least 1 wallpaper image in ~/Pictures/Wallpapers"
    print(f"      Current selection: {os.path.basename(current_wp)}")
    print(f"      Available wallpapers: {files}")
    print("      PASSED")

def test_wallpaper_ipc():
    print("[4/7] Testing Wallpaper Picker IPC handler...")
    res1 = run(["qs", "ipc", "-c", "ghost-shell", "call", "wallpaper", "open"])
    assert res1.returncode == 0, f"Failed to open wallpaper picker: {res1.stderr}"
    time.sleep(0.1)
    res2 = run(["qs", "ipc", "-c", "ghost-shell", "call", "wallpaper", "close"])
    assert res2.returncode == 0, f"Failed to close wallpaper picker: {res2.stderr}"
    print("      call wallpaper open / close: OK")
    print("      PASSED")

def test_screenshot_workflow():
    print("[5/7] Testing Screenshot script execution and clipboard copy...")
    res = run(["/home/ashutosh/.local/bin/screenshot", "screen"])
    assert res.returncode == 0, "Screenshot execution failed"

    # Verify clipboard content
    clip_res = run(["wl-paste", "-l"])
    assert "image/png" in clip_res.stdout, f"Clipboard does not contain image/png: {clip_res.stdout}"

    # Verify file saved in ~/Pictures/Screenshots
    ss_dir = os.path.expanduser("~/Pictures/Screenshots")
    files = sorted([os.path.join(ss_dir, f) for f in os.listdir(ss_dir) if f.startswith("Screenshot_")])
    assert len(files) > 0, "No screenshot saved to ~/Pictures/Screenshots"
    latest = files[-1]
    assert os.path.getsize(latest) > 1000, f"Screenshot file suspiciously small: {latest}"
    print(f"      Generated screenshot: {os.path.basename(latest)} ({os.path.getsize(latest)} bytes)")
    print("      Clipboard format: image/png")

    # Clean up test screenshot
    os.remove(latest)
    print("      Cleaned up test screenshot: OK")
    print("      PASSED")

def test_hyprland_binds():
    print("[6/7] Verifying Hyprland keybindings for Phase 4...")
    res = run(["hyprctl", "binds", "-j"])
    binds = json.loads(res.stdout)

    wp_bind = next((b for b in binds if b.get("key", "").lower() == "w" and b.get("modmask") == 64), None)
    assert wp_bind is not None, "SUPER + W binding not found in Hyprland"

    print_bind = next((b for b in binds if b.get("key", "").lower() == "print" and b.get("modmask") == 0), None)
    assert print_bind is not None, "Print key binding not found in Hyprland"

    snip_bind = next((b for b in binds if b.get("key", "").lower() == "s" and b.get("modmask") == 65), None)
    assert snip_bind is not None, "SUPER + SHIFT + S binding not found in Hyprland"

    print("      SUPER + W (Wallpaper Gallery): OK")
    print("      Print (Area Screenshot): OK")
    print("      SUPER + SHIFT + S (Area Screenshot): OK")
    print("      PASSED")

def test_quickshell_log():
    print("[7/7] Checking quickshell log for errors post-reload...")
    res = run(["qs", "log", "-c", "ghost-shell"])
    lines = res.stdout.strip().split("\n")
    recent = lines[-40:] if len(lines) >= 40 else lines
    last_reload = -1
    for i, l in enumerate(recent):
        if "Reloading configuration..." in l:
            last_reload = i
    if last_reload >= 0:
        post_reload = recent[last_reload:]
        errors = [l for l in post_reload if "ERROR" in l]
        assert len(errors) == 0, f"Errors found after last reload: {errors}"
    print("      Shell runtime: Clean, 0 errors post-reload")
    print("      PASSED")

def main():
    print("=== Ghost Shell Phase 4 Smoke Test ===")
    try:
        test_weather_api()
        test_weather_ipc()
        test_wallpaper_service()
        test_wallpaper_ipc()
        test_screenshot_workflow()
        test_hyprland_binds()
        test_quickshell_log()
        print("\nAll Phase 4 smoke tests PASSED successfully!")
        return 0
    except Exception as e:
        print(f"\nTEST FAILED: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
