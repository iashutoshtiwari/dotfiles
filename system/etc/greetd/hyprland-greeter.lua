-- ---------------------------------------------------------------------------
-- Cursor
-- ---------------------------------------------------------------------------
-- greetd is independent of the logged-in user's environment, so select the
-- system-installed Predator Shell cursor before the compositor initializes.
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
    },

    decoration = {
        rounding = 0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = false,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 0,

        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        -- The packaged Bibata theme provides XCursor assets, not Hyprcursor.
        enable_hyprcursor = false,
        sync_gsettings_theme = false,
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        disable_splash_rendering = true,
    },
})

-- This compositor exists only long enough to host the layer-shell greeter.
-- The real desktop is started by greetd through the UWSM session wrapper.
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/local/libexec/predator-greeter")
end)
