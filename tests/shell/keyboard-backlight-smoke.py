#!/usr/bin/env python3
"""
keyboard-backlight-smoke.py — Verification suite for Ghost desktop keyboard backlight:
- Device detection parsing & false-positive filtering
- Unsupported device behavior (graceful fallback)
- Clamping and integer snapping (discrete steps)
- Label resolution (0 -> Off, 1 -> Low, 2 -> High for max=2)
- Boundary behavior (increase at max, decrease at zero)
- Live hardware detection
- Quickshell IPC registration & control
"""

import subprocess
import sys


def parse_device_list(raw_output):
    """Replicates KeyboardBacklightService detection logic in Python."""
    lines = raw_output.strip().split("\n")
    found_device = ""
    found_current = 0
    found_max = 0

    for line in lines:
        line = line.strip()
        if not line:
            continue
        parts = line.split(",")
        if len(parts) >= 5:
            dev_name = parts[0].lower()
            dev_class = parts[1].lower()

            if dev_class not in ("leds", "backlight"):
                continue

            is_false_positive = any(
                fp in dev_name
                for fp in [
                    "capslock", "numlock", "scrolllock", "micmute", "mute",
                    "power", "charging", "standby", "lid", "thinkvantage", "lan"
                ]
            )
            if is_false_positive:
                continue

            is_kbd_backlight = (
                ("kbd_backlight" in dev_name)
                or ("kbd-backlight" in dev_name)
                or ("kbd" in dev_name and "backlight" in dev_name)
                or ("keyboard_backlight" in dev_name)
                or ("keyboard-backlight" in dev_name)
            )

            if is_kbd_backlight:
                max_brightness = int(parts[4]) if parts[4].isdigit() else 0
                if max_brightness > 0:
                    found_device = parts[0]
                    found_current = int(parts[2]) if parts[2].isdigit() else 0
                    found_max = max_brightness
                    break

    if found_device:
        return {"device": found_device, "current": found_current, "max": found_max, "available": True}
    return {"device": "", "current": 0, "max": 0, "available": False}


def clamp(val, min_v, max_v):
    return max(min_v, min(max_v, val))


def snap_level(ratio, max_steps):
    clamped_ratio = max(0.0, min(1.0, ratio))
    return round(clamped_ratio * max_steps)


def get_label(index, max_steps):
    if max_steps == 2:
        if index == 0:
            return "Off"
        if index == 1:
            return "Low"
        return "High"
    if index == 0:
        return "Off"
    if index == max_steps:
        return "Max"
    return str(index)


def test_device_detection_parsing():
    sample_thinkpad = """
amdgpu_bl1,backlight,32768,50%,65535
input4::capslock,leds,0,0%,1
platform::mute,leds,0,0%,1
input4::scrolllock,leds,0,0%,1
tpacpi::power,leds,0,0%,255
enp1s0-2::lan,leds,0,0%,255
tpacpi::lid_logo_dot,leds,0,0%,255
enp1s0-1::lan,leds,0,0%,255
tpacpi::standby,leds,0,0%,255
input4::numlock,leds,0,0%,1
enp1s0-0::lan,leds,0,0%,255
tpacpi::thinkvantage,leds,0,0%,255
tpacpi::kbd_backlight,leds,2,100%,2
platform::micmute,leds,0,0%,1
"""
    res = parse_device_list(sample_thinkpad)
    assert res["available"] is True, "ThinkPad kbd_backlight not detected"
    assert res["device"] == "tpacpi::kbd_backlight", f"Wrong device: {res['device']}"
    assert res["current"] == 2, f"Wrong current: {res['current']}"
    assert res["max"] == 2, f"Wrong max: {res['max']}"

    sample_asus = "asus::kbd_backlight,leds,1,33%,3\n"
    res_asus = parse_device_list(sample_asus)
    assert res_asus["available"] is True
    assert res_asus["device"] == "asus::kbd_backlight"
    assert res_asus["max"] == 3

    sample_dell = "dell::kbd_backlight,leds,0,0%,2\n"
    res_dell = parse_device_list(sample_dell)
    assert res_dell["available"] is True
    assert res_dell["device"] == "dell::kbd_backlight"
    assert res_dell["max"] == 2

    print("PASS: device detection parsing & candidate filtering")


def test_unsupported_device_behavior():
    sample_no_kbd = """
amdgpu_bl1,backlight,32768,50%,65535
input4::capslock,leds,0,0%,1
platform::mute,leds,0,0%,1
tpacpi::power,leds,0,0%,255
"""
    res = parse_device_list(sample_no_kbd)
    assert res["available"] is False, "Expected available=False when no kbd device exists"
    assert res["device"] == "", "Expected empty device string"

    res_empty = parse_device_list("")
    assert res_empty["available"] is False

    print("PASS: unsupported device returns available=False and empty device")


def test_level_clamping():
    max_val = 2
    assert clamp(-1, 0, max_val) == 0
    assert clamp(0, 0, max_val) == 0
    assert clamp(1, 0, max_val) == 1
    assert clamp(2, 0, max_val) == 2
    assert clamp(3, 0, max_val) == 2
    assert clamp(100, 0, max_val) == 2

    print("PASS: level clamping correctly bounds to [0, max]")


def test_integer_snapping():
    max_val = 2
    # Continuous ratios -> integer steps (0, 1, 2)
    assert snap_level(0.00, max_val) == 0
    assert snap_level(0.15, max_val) == 0
    assert snap_level(0.24, max_val) == 0
    assert snap_level(0.26, max_val) == 1
    assert snap_level(0.50, max_val) == 1
    assert snap_level(0.74, max_val) == 1
    assert snap_level(0.76, max_val) == 2
    assert snap_level(1.00, max_val) == 2

    # Verify return types are strictly int
    for ratio in [0.12, 0.45, 0.88]:
        level = snap_level(ratio, max_val)
        assert isinstance(level, int), f"Level must be integer, got {type(level)}"
        assert level in (0, 1, 2), f"Level must be 0, 1, or 2, got {level}"

    print("PASS: integer snapping from continuous inputs")


def test_label_mapping():
    assert get_label(0, 2) == "Off"
    assert get_label(1, 2) == "Low"
    assert get_label(2, 2) == "High"

    # Fallback behavior when max != 2
    assert get_label(0, 3) == "Off"
    assert get_label(1, 3) == "1"
    assert get_label(2, 3) == "2"
    assert get_label(3, 3) == "Max"

    print("PASS: label mapping (0 -> Off, 1 -> Low, 2 -> High)")


def test_increase_decrease_boundaries():
    max_val = 2

    # Increase at max stays at max
    current = 2
    current = clamp(current + 1, 0, max_val)
    assert current == 2

    # Decrease at zero stays at zero
    current = 0
    current = clamp(current - 1, 0, max_val)
    assert current == 0

    # Normal step progression
    current = 0
    current = clamp(current + 1, 0, max_val)
    assert current == 1
    current = clamp(current + 1, 0, max_val)
    assert current == 2
    current = clamp(current - 1, 0, max_val)
    assert current == 1

    print("PASS: boundary behavior (increase at max, decrease at zero)")


def test_live_hardware():
    res = subprocess.run(
        ["brightnessctl", "-m", "--list"],
        capture_output=True,
        text=True,
        check=True
    )
    detected = parse_device_list(res.stdout)
    assert detected["available"] is True, "No keyboard backlight found on this hardware"
    assert "kbd_backlight" in detected["device"], f"Unexpected device name: {detected['device']}"
    assert detected["max"] == 2, f"Expected ThinkPad E14 Gen 6 max brightness to be 2, got {detected['max']}"

    print(f"PASS: live hardware detected {detected['device']} (max={detected['max']}, current={detected['current']})")


def test_quickshell_ipc():
    # 1. Verify target keyboardBacklight is registered
    res = subprocess.run(
        ["qs", "ipc", "-c", "ghost-shell", "show"],
        capture_output=True,
        text=True,
        check=True
    )
    targets = res.stdout
    assert "target keyboardBacklight" in targets, f"Missing keyboardBacklight target: {targets}"
    assert "function set(value: string): void" in targets
    assert "function increase(): void" in targets
    assert "function decrease(): void" in targets
    assert "function refresh(): void" in targets

    # 2. Test hardware interaction via IPC
    def get_hw_brightness():
        with open("/sys/class/leds/tpacpi::kbd_backlight/brightness", "r") as f:
            return int(f.read().strip())

    orig_brightness = get_hw_brightness()

    try:
        # Test set 0
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "set", "0"], check=True)
        import time
        time.sleep(0.3)
        assert get_hw_brightness() == 0, f"Expected 0, got {get_hw_brightness()}"

        # Test increase -> 1
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "increase"], check=True)
        time.sleep(0.3)
        assert get_hw_brightness() == 1, f"Expected 1, got {get_hw_brightness()}"

        # Test increase -> 2
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "increase"], check=True)
        time.sleep(0.3)
        assert get_hw_brightness() == 2, f"Expected 2, got {get_hw_brightness()}"

        # Test increase at max -> 2
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "increase"], check=True)
        time.sleep(0.3)
        assert get_hw_brightness() == 2, f"Expected 2 at max, got {get_hw_brightness()}"

        # Test decrease -> 1
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "decrease"], check=True)
        time.sleep(0.3)
        assert get_hw_brightness() == 1, f"Expected 1, got {get_hw_brightness()}"

        # Test set 2
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "set", "2"], check=True)
        time.sleep(0.3)
        assert get_hw_brightness() == 2, f"Expected 2, got {get_hw_brightness()}"

    finally:
        # Restore original brightness
        subprocess.run(["qs", "ipc", "-c", "ghost-shell", "call", "keyboardBacklight", "set", str(orig_brightness)], check=True)

    print("PASS: quickshell IPC registration and live hardware control (set/increase/decrease)")


def main():
    print("=== Ghost Shell Keyboard Backlight Smoke Tests ===")
    try:
        test_device_detection_parsing()
        test_unsupported_device_behavior()
        test_level_clamping()
        test_integer_snapping()
        test_label_mapping()
        test_increase_decrease_boundaries()
        test_live_hardware()
        test_quickshell_ipc()
        print("\nALL KEYBOARD BACKLIGHT SMOKE TESTS PASSED!")
        return 0
    except Exception as e:
        print(f"\nFAIL: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
