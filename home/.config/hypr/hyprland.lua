local colors = require("themes.catppuccin-mocha")

-- Monitor
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1.46"
})

-- Environment

-- Core compositor appearance
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border = colors.lavender,
            inactive_border = colors.surface1
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle"
    },

    decoration = {
        rounding = 0,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 6,
            render_power = 2,
            color = "rgba(" .. colors.crustAlpha .. "66)"
        },

        blur = {
            enabled = false
        }
    },

    animations = {
        enabled = true
    },

    input = {
        kb_layout = "us",

        follow_mouse = 1,

        touchpad = {
            natural_scroll = true
        }
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0
    },

    dwindle = {
        preserve_split = true
    }
})

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

-- Three curves cover entrance, exit, and directional movement. Durations are
-- deciseconds; transforms stay deliberately small so motion reads as feedback.
hl.curve("predatorEnter", {
    type = "bezier",
    points = {{0.16, 1.0}, {0.3, 1.0}}
})
hl.curve("predatorExit", {
    type = "bezier",
    points = {{0.4, 0.0}, {1.0, 1.0}}
})
hl.curve("predatorSpatial", {
    type = "bezier",
    points = {{0.22, 0.72}, {0.2, 1.0}}
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 1.9,
    bezier = "predatorEnter",
    style = "popin 98%"
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 1.9,
    bezier = "predatorEnter",
    style = "popin 98%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.3,
    bezier = "predatorExit",
    style = "popin 99%"
})
hl.animation({
    leaf = "windowsMove",
    enabled = false
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 2.3,
    bezier = "predatorSpatial",
    style = "slidefade 10%"
})
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 1.8,
    bezier = "predatorEnter",
    style = "fade"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 1.6,
    bezier = "predatorEnter",
    style = "fade"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 1.0,
    bezier = "predatorExit",
    style = "fade"
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 1.3,
    bezier = "predatorEnter"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.0,
    bezier = "predatorExit"
})
hl.animation({
    leaf = "fadeSwitch",
    enabled = true,
    speed = 1.1,
    bezier = "predatorEnter"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 1.5,
    bezier = "predatorEnter"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 1.0,
    bezier = "predatorExit"
})
hl.animation({
    leaf = "fadePopupsIn",
    enabled = true,
    speed = 1.0,
    bezier = "predatorEnter"
})
hl.animation({
    leaf = "fadePopupsOut",
    enabled = true,
    speed = 0.8,
    bezier = "predatorExit"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 1.2,
    bezier = "predatorEnter"
})

-- Shell surfaces own their internal transitions. Disabling compositor motion
-- here prevents the bar, OSD, notification cards, and action center from
-- animating twice. The action center owns its own horizontal slide via QML.
hl.layer_rule({
    name = "predator-shell-motion-owned-by-qml",
    match = { namespace = "^(quickshell|predator-notifications|predator-osd|predator-action-center)$" },
    no_anim = true
})
hl.layer_rule({
    name = "wallpaper-never-animates",
    match = { namespace = "^hyprpaper$" },
    no_anim = true
})
-- Both the application launcher and emoji picker expose the observed `rofi`
-- namespace. They appear in place with the short global layer fade.
hl.layer_rule({
    name = "rofi-fades-in-place",
    match = { namespace = "^rofi$" },
    animation = "fade"
})

-- Five persistent workspaces
for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        persistent = true
    })
end

-- Laptop workspace gesture
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Window rules
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize"
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },
    no_focus = true
})

hl.window_rule({
    name = "dialogs-float",
    match = {
        title = "^(Open Files?|Save File|Choose Files?|Confirm to replace files|File Operation Progress)$"
    },
    float = true
})

hl.window_rule({
    name = "pip-float",
    match = {
        title = "^(Picture-in-Picture)$"
    },
    float = true,
    pin = true
})

hl.window_rule({
    name = "portal-float",
    match = {
        class = "^(xdg-desktop-portal.*)$"
    },
    float = true
})

hl.window_rule({
    name = "utilities-float",
    match = {
        class = "^(pavucontrol|nm-connection-editor|blueman-manager)$"
    },
    float = true
})

hl.window_rule({
    name = "scratchpad-terminal",
    match = { class = "^predator-scratchpad$" },
    workspace = "special:scratchpad",
    float = true,
    center = true,
    size = { "monitor_w * 0.70", "monitor_h * 0.62" },
    stay_focused = true,
    animation = "popin 98%"
})

local mod = "SUPER"

-- Applications
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- kitty"))

-- A single persistent terminal follows the special-workspace toggle. The
-- process guard prevents Super+grave from spawning duplicates.
hl.bind(mod .. " + grave", hl.dsp.exec_cmd(
    "pgrep -u \"$USER\" -f 'kitty --class predator-scratchpad' >/dev/null || " ..
    "uwsm app -- kitty --class predator-scratchpad; " ..
    "hyprctl dispatch togglespecialworkspace scratchpad"
), {
    description = "Toggle terminal scratchpad"
})

-- Window management
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.window.float({
    action = "toggle"
}))

-- Focus
hl.bind(mod .. " + left", hl.dsp.focus({
    direction = "left"
}))
hl.bind(mod .. " + right", hl.dsp.focus({
    direction = "right"
}))
hl.bind(mod .. " + up", hl.dsp.focus({
    direction = "up"
}))
hl.bind(mod .. " + down", hl.dsp.focus({
    direction = "down"
}))

hl.bind(mod .. " + H", hl.dsp.focus({
    direction = "left"
}))
hl.bind(mod .. " + L", hl.dsp.focus({
    direction = "right"
}))
hl.bind(mod .. " + K", hl.dsp.focus({
    direction = "up"
}))
hl.bind(mod .. " + J", hl.dsp.focus({
    direction = "down"
}))

-- Workspaces
for i = 1, 5 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({
        workspace = i
    }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({
        workspace = i
    }))
end

-- Workspace switching with mouse wheel
hl.bind(mod .. " + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}))

-- Mouse move / resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})

hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})

-- Modal resize mode: arrows and vim keys use a 16px increment, then remain
-- available until Escape or Enter returns to the normal keymap.
hl.bind(mod .. " + R", hl.dsp.submap("resize"), {
    description = "Enter resize mode"
})

hl.define_submap("resize", function()
    hl.bind("h", hl.dsp.window.resize({ x = -16, y = 0, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -16, y = 0, relative = true }), { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 16, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 16, y = 0, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -16, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -16, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 16, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 16, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    locked = true,
    repeating = true
})

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true
})

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true
})

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true
})

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc -c predator-shell call brightness increase || brightnessctl -e4 -n2 set 5%+"), {
    locked = true,
    repeating = true
})

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc -c predator-shell call brightness decrease || brightnessctl -e4 -n2 set 5%-"), {
    locked = true,
    repeating = true
})

-- Lock Keys OSD
hl.bind("Caps_Lock", hl.dsp.exec_cmd("qs ipc -c predator-shell call osd updateCapsLock"), {
    locked = true,
    non_consuming = true
})

hl.bind("Num_Lock", hl.dsp.exec_cmd("qs ipc -c predator-shell call osd updateNumLock"), {
    locked = true,
    non_consuming = true
})

hl.bind("Scroll_Lock", hl.dsp.exec_cmd("qs ipc -c predator-shell call osd toggleScrollLock"), {
    locked = true,
    non_consuming = true
})

-- Airplane Mode (Fn + F3) — Query hardware rfkill state after kernel settles
hl.bind("XF86RFKill", hl.dsp.exec_cmd("qs ipc -c predator-shell call osd updateAirplaneMode"), {
    locked = true
})

hl.bind("XF86WLAN", hl.dsp.exec_cmd("qs ipc -c predator-shell call osd updateAirplaneMode"), {
    locked = true
})


-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true
})

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true
})

hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("uwsm stop"), {
    description = "End graphical session"
})

hl.bind("SUPER + Escape", hl.dsp.exec_cmd("qs ipc -c predator-shell call popups closeAll; loginctl lock-session"))

hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("qs ipc -c predator-shell call powermenu toggle"), {
    description = "Toggle session power menu"
})

-- Action Center: Super+N toggles the right-side Action Center drawer.
-- The IPC call reaches the ActionCenter IpcHandler (target: "actionCenter").
-- Closes drawer if open; opens on the current monitor's action center if closed.
-- Super+Space and Super+period already call popups closeAll which closes the
-- action center via its dismiss() path in Bar's closeAllPopups().
hl.bind("SUPER + N", hl.dsp.exec_cmd("qs ipc -c predator-shell call actionCenter toggle"), {
    description = "Toggle Action Center"
})

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("qs ipc -c predator-shell call popups closeAll; rofi -show drun"), {
    description = "Launch application menu"
})

hl.bind("SUPER + period", hl.dsp.exec_cmd("qs ipc -c predator-shell call popups closeAll; /home/ashutosh/.local/bin/emoji-picker"), {
    description = "Launch emoji and symbol picker"
})

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("/home/ashutosh/.local/bin/screenshot area"), {
    description = "Capture selected area to clipboard and file"
})

hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("/home/ashutosh/.local/bin/screenshot area"), {
    description = "Capture selected area to clipboard and file"
})

hl.bind("SHIFT + Print", hl.dsp.exec_cmd("/home/ashutosh/.local/bin/screenshot screen"), {
    description = "Capture full screen to clipboard and file"
})

hl.bind("CTRL + Print", hl.dsp.exec_cmd("/home/ashutosh/.local/bin/screenshot window"), {
    description = "Capture active window to clipboard and file"
})

-- Wallpaper Gallery
hl.bind("SUPER + W", hl.dsp.exec_cmd("qs ipc -c predator-shell call wallpaper toggle"), {
    description = "Toggle wallpaper gallery picker"
})
