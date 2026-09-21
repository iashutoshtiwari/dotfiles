#!/usr/bin/env python3
"""
osd-extensions-smoke.py — Verification suite for predator-shell OSD extensions & fixes:
- Hyprland compositor device status (numLock, capsLock)
- rfkill radio status query
- Quickshell IPC OSD trigger responsiveness
- Hyprland keybindings verification
"""

import json
import os
import subprocess
import sys
import time

def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)

def test_compositor_keyboard():
    print("[1/5] Checking Hyprland compositor keyboard state...")
    res = run(["hyprctl", "devices", "-j"])
    data = json.loads(res.stdout)
    kbs = data.get("keyboards", [])
    assert len(kbs) > 0, "No keyboards detected by Hyprland"
    main_kb = next((k for k in kbs if k.get("main")), kbs[0])
    assert "numLock" in main_kb, "numLock field missing from main keyboard"
    assert "capsLock" in main_kb, "capsLock field missing from main keyboard"
    print(f"      Main keyboard: {main_kb.get('name')} (numLock={main_kb.get('numLock')}, capsLock={main_kb.get('capsLock')})")
    print("      PASSED")

def test_rfkill():
    print("[2/5] Checking rfkill JSON parsing...")
    res = run(["rfkill", "-J", "list", "all"])
    data = json.loads(res.stdout)
    devices = data.get("rfkilldevices", [])
    assert len(devices) > 0, "No rfkill devices discovered"
    wlan_devices = [d for d in devices if d.get("type") == "wlan" or "wireless" in str(d.get("device"))]
    assert len(wlan_devices) > 0, "No wireless devices found in rfkill output"
    for d in devices:
        assert "soft" in d and "type" in d, f"Malformed rfkill device record: {d}"
        print(f"      Device {d.get('id')}: {d.get('device')} ({d.get('type')}) -> soft={d.get('soft')}")
    print("      PASSED")

def test_quickshell_ipc():
    print("[3/5] Testing Quickshell OSD IPC handlers...")
    methods = [
        "updateCapsLock",
        "updateNumLock",
        "toggleScrollLock",
        "updateAirplaneMode"
    ]
    for method in methods:
        cmd = ["qs", "ipc", "-c", "predator-shell", "call", "osd", method]
        res = run(cmd)
        assert res.returncode == 0, f"IPC call failed for {method}: {res.stderr}"
        print(f"      call osd {method}: OK")
    print("      PASSED")

def test_hyprland_config():
    print("[4/5] Verifying Hyprland config validity...")
    res = run(["hyprctl", "configerrors"])
    errors = res.stdout.strip()
    assert errors == "ok" or not errors, f"Hyprland config errors found: {errors}"
    print("      Hyprland config: Valid, 0 errors")
    print("      PASSED")

def test_hyprland_binds():
    print("[5/5] Verifying Hyprland keybindings for OSD...")
    res = run(["hyprctl", "binds", "-j"])
    binds = json.loads(res.stdout)

    expected = {
        "Num_Lock": {"locked": True, "non_consuming": True},
        "Scroll_Lock": {"locked": True, "non_consuming": True},
        "Caps_Lock": {"locked": True, "non_consuming": True},
        "XF86RFKill": {"locked": True},
        "XF86WLAN": {"locked": True},
    }

    found = {}
    for b in binds:
        key = b.get("key")
        if key in expected:
            found[key] = b

    for key, attrs in expected.items():
        assert key in found, f"Missing keybinding for {key}"
        bind = found[key]
        for attr, val in attrs.items():
            actual = bind.get(attr)
            assert actual == val, f"Binding for {key} expected {attr}={val}, got {actual}"
        print(f"      Bind {key}: OK (flags: {attrs})")

    print("      PASSED")

def main():
    print("=== Predator Shell OSD Extensions & Fixes Smoke Test ===")
    try:
        test_compositor_keyboard()
        test_rfkill()
        test_quickshell_ipc()
        test_hyprland_config()
        test_hyprland_binds()
        print("\nAll OSD extensions & fixes smoke tests PASSED successfully!")
        return 0
    except Exception as e:
        print(f"\nTEST FAILED: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
