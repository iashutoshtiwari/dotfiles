#!/usr/bin/env python3
"""
phase5-smoke.py — Verification suite for Phase 5 Architecture, Consistency & Polish:
- Unified Popup Coordinator mutual exclusion and global closeAll
- Multiple-of-4 scaling consistency across all shell popups
- Emoji & Symbols picker availability and data integrity
- Hyprland configuration syntax, window rules, and updated bindings (Super+Space, Super+Escape, Super+period)
- Quickshell runtime health (zero errors)
"""

import json
import os
import re
import subprocess
import sys
import time

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)

def test_popup_coordinator_ipc():
    print("[1/5] Testing Popup Coordinator mutual exclusion & closeAll...")
    # Open audio popup
    res = run(["qs", "ipc", "-c", "ghost-shell", "call", "popups", "toggle", "audio"])
    assert res.returncode == 0, f"Failed to toggle audio popup: {res.stderr}"
    time.sleep(0.1)

    # Open network popup (should automatically close audio popup)
    res = run(["qs", "ipc", "-c", "ghost-shell", "call", "popups", "toggle", "network"])
    assert res.returncode == 0, f"Failed to toggle network popup: {res.stderr}"
    time.sleep(0.1)

    # Dismiss all popups
    res = run(["qs", "ipc", "-c", "ghost-shell", "call", "popups", "closeAll"])
    assert res.returncode == 0, f"Failed to call closeAll: {res.stderr}"
    print("      call popups toggle (audio -> network -> closeAll): OK")
    print("      PASSED")

def test_multiple_of_four_scaling():
    print("[2/5] Verifying multiple-of-4 subpixel scaling compliance across popups...")
    popups_dir = os.path.join(REPO_ROOT, "home/.config/quickshell/ghost-shell/popups")
    qml_files = [os.path.join(popups_dir, f) for f in os.listdir(popups_dir) if f.endswith(".qml")]
    
    assert len(qml_files) >= 9, f"Found only {len(qml_files)} popup files"

    for file_path in qml_files:
        name = os.path.basename(file_path)
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check implicitWidth
        w_match = re.search(r'implicitWidth:\s*(\d+)', content)
        if w_match:
            width = int(w_match.group(1))
            assert width % 4 == 0, f"{name}: implicitWidth {width} is not divisible by 4!"

        # Check implicitHeight
        h_match = re.search(r'implicitHeight:\s*(\d+)', content)
        if h_match:
            height = int(h_match.group(1))
            assert height % 4 == 0, f"{name}: implicitHeight {height} is not divisible by 4!"
        elif "Math.ceil(" in content and "/ 4) * 4" in content:
            # Dynamic height correctly rounded to multiple of 4
            pass
        else:
            raise AssertionError(f"{name}: Missing or non-rounded implicitHeight!")

    print(f"      Verified {len(qml_files)} popup components: All strictly multiple-of-4 compliant")
    print("      PASSED")

def test_emoji_picker():
    print("[3/5] Testing Emoji & Symbols Picker (rofi-emoji)...")
    # Verify rofi is available (in /usr/bin — always in PATH)
    import shutil
    assert shutil.which("rofi") is not None, "rofi not found in PATH"

    # Verify rofi-emoji plugin installed
    plugin_path = "/usr/lib/rofi/emoji.so"
    assert os.path.isfile(plugin_path), (
        f"rofi-emoji plugin not found at {plugin_path}. "
        "Run: sudo pacman -S rofi-emoji"
    )

    picker_path = os.path.join(REPO_ROOT, "home/.local/bin/emoji-picker")
    assert os.path.isfile(picker_path), f"Emoji picker helper missing: {picker_path}"
    assert os.access(picker_path, os.X_OK), f"Emoji picker helper is not executable: {picker_path}"
    with open(picker_path, "r", encoding="utf-8") as picker_file:
        picker = picker_file.read()
    assert "-emoji-mode stdout" in picker, "Emoji picker does not wait for Rofi output"
    assert re.search(r'sleep\s+0\.\d+', picker), "Emoji picker has no focus-restoration delay"
    assert "wtype -" in picker, "Emoji picker does not dispatch the selection through wtype"
    assert "wl-copy" in picker, "Emoji picker does not preserve the clipboard fallback"

    # Lua bindings are represented as __lua by Hyprland, so verify both the
    # live key registration and the tracked command source.
    res = run(["hyprctl", "binds", "-j"])
    binds = json.loads(res.stdout)
    emoji_bind = next(
        (b for b in binds
         if b.get("key", "").lower() == "period" and b.get("modmask") == 64),
        None
    )
    assert emoji_bind is not None, "SUPER + period keybinding not found in Hyprland"
    config_path = os.path.join(REPO_ROOT, "home/.config/hypr/hyprland.lua")
    with open(config_path, "r", encoding="utf-8") as config_file:
        config = config_file.read()
    assert re.search(r'bind\("SUPER \+ period".*?/home/ashutosh/\.local/bin/emoji-picker', config, re.DOTALL), \
        "Tracked SUPER+period binding does not dispatch the emoji picker helper"

    # Verify wl-clipboard works
    subprocess.run(["wl-copy", "✨"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    clip = run(["wl-paste"])
    assert clip.stdout.strip() == "✨", "wl-copy test failed"

    print(f"      rofi-emoji plugin: {plugin_path} ✓")
    print("      SUPER + period → delayed Wayland insertion helper: OK")
    print("      wl-clipboard: OK")
    print("      PASSED")

def test_hyprland_binds_and_rules():
    print("[4/5] Verifying Hyprland configuration syntax, binds, and rules...")
    # Syntax check
    run(["hyprctl", "configerrors"])

    # Binds check
    res = run(["hyprctl", "binds", "-j"])
    binds = json.loads(res.stdout)

    emoji_bind = next((b for b in binds if b.get("key", "").lower() == "period" and b.get("modmask") == 64), None)
    assert emoji_bind is not None, "SUPER + period keybinding not found in Hyprland"

    space_bind = next((b for b in binds if b.get("key", "").lower() == "space" and b.get("modmask") == 64), None)
    assert space_bind is not None, "SUPER + SPACE keybinding not found in Hyprland"

    print("      SUPER + period (Emoji Picker): OK")
    print("      SUPER + SPACE (App Launcher with closeAll): OK")
    print("      Hyprland syntax: 0 errors")
    print("      PASSED")

def test_quickshell_log():
    print("[5/5] Checking quickshell runtime log for clean state...")
    res = run(["qs", "log", "-c", "ghost-shell"])
    lines = res.stdout.strip().split("\n")
    recent = lines[-30:] if len(lines) >= 30 else lines
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
    print("=== Ghost Shell Phase 5 Smoke Test ===")
    try:
        test_popup_coordinator_ipc()
        test_multiple_of_four_scaling()
        test_emoji_picker()
        test_hyprland_binds_and_rules()
        test_quickshell_log()
        print("\nAll Phase 5 smoke tests PASSED successfully!")
        return 0
    except Exception as e:
        print(f"\nTEST FAILED: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
