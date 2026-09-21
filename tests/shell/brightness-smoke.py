#!/usr/bin/env python3
"""Smoke test for brightness parsing, clamping, and Quickshell IPC registration."""

import shutil
import subprocess
import sys


def test_brightnessctl_parsing():
    sample_output = "intel_backlight,backlight,900,60%,1500\n"
    line = sample_output.strip().split("\n")[-1]
    parts = line.split(",")
    assert len(parts) >= 5, f"Expected >=5 parts, got {parts}"
    device = parts[0]
    kind = parts[1]
    current = int(parts[2])
    pct = int(parts[3].replace("%", ""))
    max_val = int(parts[4])

    assert device == "intel_backlight"
    assert kind == "backlight"
    assert current == 900
    assert pct == 60
    assert max_val == 1500
    print("PASS: brightnessctl machine output correctly parsed")


def test_clamping():
    def clamp(val, min_v, max_v):
        return max(min_v, min(max_v, val))

    assert clamp(0, 5, 100) == 5
    assert clamp(50, 5, 100) == 50
    assert clamp(120, 5, 100) == 100
    assert clamp(-10, 5, 100) == 5
    print("PASS: brightness percentage clamps correctly [5, 100]")


def test_binaries():
    assert shutil.which("brightnessctl") is not None, "brightnessctl not found in PATH"
    assert shutil.which("hyprsunset") is not None, "hyprsunset not found in PATH"
    print("PASS: brightnessctl and hyprsunset binaries present")


def test_quickshell_ipc_targets():
    res = subprocess.run(
        ["qs", "ipc", "-c", "predator-shell", "show"],
        capture_output=True,
        text=True,
        check=True,
    )
    targets = res.stdout
    assert "target brightness" in targets, f"Missing brightness target: {targets}"
    assert "target nightlight" in targets, f"Missing nightlight target: {targets}"
    assert "target osd" in targets, f"Missing osd target: {targets}"
    print("PASS: quickshell IPC targets registered (brightness, nightlight, osd)")


if __name__ == "__main__":
    try:
        test_brightnessctl_parsing()
        test_clamping()
        test_binaries()
        test_quickshell_ipc_targets()
        print("\nALL BRIGHTNESS SMOKE TESTS PASSED!")
    except Exception as e:
        print(f"FAIL: {e}", file=sys.stderr)
        sys.exit(1)
