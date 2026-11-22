-- ~/.config/hypr/hyprland.lua  — managed by hjem
-- Hyprland 0.56 Lua config. Loaded *instead of* hyprland.conf when present,
-- and the choice is made once at startup — you can't switch at runtime.
-- Docs: https://wiki.hypr.land/configuring/

------------------------------------------------------------------ PROGRAMS

local terminal    = "kitty"
local fileManager = "kitty -e yazi"
local menu        = "fuzzel"
local lockCmd     = "hyprlock"

-- `hl.dsp.*` returns a *description* of an action; nothing runs until it is
-- bound or passed to hl.dispatch().

------------------------------------------------------------------ MONITORS

-- One catch-all entry: every output at preferred mode, auto-placed.
-- Replace with explicit entries once you know your output names
-- (`hyprctl monitors | grep '^Monitor'`).
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
hl.monitor({
    output   = "HDMI-A-2",
    position = "auto",
    scale    = "auto",
    disabled = true,
})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Examples, commented:
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0",   scale = 1, vrr = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-right", scale = 1 })
-- hl.monitor({ output = "eDP-1", disabled = true })

------------------------------------------------------------- ENVIRONMENT

-- Set before anything else starts. Third arg `true` also pushes the variable
-- into the D-Bus activation environment, which portals and some apps need.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_SCALE", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

---------------------------------------------------------------- AUTOSTART

-- Runs once when the compositor starts. Under UWSM these inherit the
-- graphical-session environment, so portals/theme vars are already set.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- Quit helpers cleanly so the session can log out properly.
-- hl.on("hyprland.shutdown", function() hl.exec_cmd("pkill waybar") end)

------------------------------------------------------------ LOOK AND FEEL

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = -1,     -- no anime mascot wallpaper
        disable_hyprland_logo   = true,   -- no login logo either
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad     = {
            natural_scroll   = false,
            disable_while_typing = true,
        },
    },

    -- If you have an NVIDIA GPU and see cursor corruption / flicker,
    -- uncomment: hardware cursors are the usual culprit.
    -- cursor = { no_hardware_cursors = true },
})

------------------------------------------------------- CURVES & ANIMATIONS

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",       enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",       enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",      enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 4.1,  spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",       enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",      enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",         enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",       enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",   enabled = true, speed = 7,    bezier = "quick" })

----------------------------------------------------------------- GESTURES

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Three-finger swipe down for a scratchpad, uncomment if you want it:
-- hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "magic" })

--------------------------------------------------------------- KEYBINDINGS

local mainMod = "SUPER"

-- applications
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockCmd))

-- window management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- move window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- workspaces 1-10 (10 maps to key 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- cycle through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- clipboard history and screenshots (needs cliphist, fuzzel, grim, slurp)
hl.bind(mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- media and brightness keys; `locked` keeps them working over a lock screen
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------------------------------------------------- RESIZE SUBMAP

-- SUPER + R is taken by fuzzel above, so resize lives on SUPER + ALT + R.
local function resizeBinds()
    local step = 20
    hl.bind("right", hl.dsp.window.resize({ x =  step, y = 0 }))
    hl.bind("left",  hl.dsp.window.resize({ x = -step, y = 0 }))
    hl.bind("up",    hl.dsp.window.resize({ x = 0, y = -step }))
    hl.bind("down",  hl.dsp.window.resize({ x = 0, y =  step }))
    hl.bind("Return", hl.dsp.submap("default"))
    hl.bind("Escape", hl.dsp.submap("default"))
end

hl.define_submap("resize", resizeBinds)
hl.bind(mainMod .. " + ALT + R", hl.dsp.submap("resize"))

--------------------------------------------- WINDOWS, LAYERS, WORKSPACES

-- Ignore maximize requests from everything. You want this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland drag fixes.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Screenshot/colour-picker tools should open as floating dialogs.
hl.window_rule({ match = { class = "^(grim|slurp|hyprpicker|satty)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor)$" }, float = true })

-- Waybar and fuzzel are layer surfaces; blur them and keep them above fullscreen.
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.1 })
hl.layer_rule({ match = { namespace = "^(fuzzel|notifications)$" }, blur = true, ignore_alpha = 0.1 })

-- Optional: pin workspaces to specific monitors.
-- hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
-- hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true })

-- Optional: smart gaps, no gaps with a single window.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })

