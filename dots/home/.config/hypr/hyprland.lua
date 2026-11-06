-- Migrated from hyprland.conf for Hyprland 0.57 (Lua config).
-- Original config: minimal, clean, functional config made by Archebus.

-----------------
---- PROGRAMS ---
-----------------

local mainMod  = "SUPER"
local terminal = "kitty"
local menu     = "rofi -show drun"

----------------
---- COLORS ----
----------------

local colors = {
    surface     = "rgba(252525ff)",
    surface_alt = "rgba(2d2d2dff)",
    highlight   = "rgba(cdd6f4ff)",
}

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-1",     mode = "1920x1080@240", position = "0x0",     scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "-1920x0", scale = 1 })

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end

---------------------
---- ENVIRONMENT ----
---------------------

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- pass the Wayland environment to systemd/dbus, otherwise xdg-desktop-portal-hyprland crashes at login
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/black.jpg")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "hypr-dots-black"')
    hl.exec_cmd("gsettings set org.gtk.Settings.FileChooser sort-directories-first true")
    hl.exec_cmd('gsettings set org.gnome.desktop.wm.preferences theme "hypr-dots-black"')
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("otd-daemon")
end)

----------------
---- CONFIG ----
----------------

hl.config({
    input = {
        kb_layout     = "us,ru",
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "grp:alt_shift_toggle",
        kb_rules      = "",
        accel_profile = "flat",
        follow_mouse  = 1,
        sensitivity   = 0,
        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        border_size      = 2,
        gaps_out         = 10,
        resize_on_border = true,
        col = {
            inactive_border = colors.surface_alt,
            active_border   = colors.highlight,
            nogroup_border  = colors.surface,
        },
    },

    decoration = {
        rounding = 4,
        -- Use a minimal wallpaper with transparent term.
        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo        = true,
        disable_splash_rendering     = true,
        force_default_wallpaper      = 0,
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,
        middle_click_paste           = false,
        animate_manual_resizes       = true,
        animate_mouse_windowdragging = true,
        enable_swallow               = true,
        swallow_regex                = "^(kitty)$",
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })

hl.device({
    name   = "opentabletdriver-virtual-artist-tablet",
    output = "DP-1",
})

---------------
---- BINDS ----
---------------

local function exec(keys, cmd)
    hl.bind(keys, hl.dsp.exec_cmd(cmd))
end

-- Standard binds
exec(mainMod .. " + Return", "kitty")
exec(mainMod .. " + SHIFT + Return", 'kitty --class="kitty-window"')
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind("ALT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
exec(mainMod .. " + D", "wofi -show")
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())
exec(mainMod .. " + P", 'grim -g "$(slurp)" - | wl-copy')
exec(mainMod .. " + SHIFT + Print", "grim - | wl-copy")
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exit())
exec(mainMod .. " + E", "thunar")
exec("ALT + X", menu)
exec(mainMod .. " + Q", terminal)
exec(mainMod .. " + v", "hyprshot -m region --clipboard-only")
exec(mainMod .. " + L", "hyprlock")

-- Move focus / move window / resize window with the arrow keys
for key, resize in pairs({
    left  = { x = -20, y = 0 },
    right = { x = 20,  y = 0 },
    up    = { x = 0,   y = -20 },
    down  = { x = 0,   y = 20 },
}) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = key }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = key }))
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.resize({ x = resize.x, y = resize.y, relative = true }))
end

-- Switch workspaces: ALT + 1-5 for DP-1 (1-5), SUPER + 1-5 for HDMI-A-1 (6-10)
for i = 1, 5 do
    hl.bind("ALT + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i + 5 }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Ignore maximize requests from apps (kitty kept maximizing itself)
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})
