{ lib, pkgs, ... }:

let
  scripts = import ./hypr-scripts.nix { inherit pkgs; };

  # Catppuccin Macchiato, mirrored from the upstream hypr/macchiato.conf.
  # Every colour is exposed twice: `$teal` as an rgb() literal for the normal
  # settings, and `$tealAlpha` as a bare hex string for the places that build
  # their own 0xAARRGGBB values (shadows, hyprlock markup).
  palette = {
    rosewater = "f4dbd6";
    flamingo = "f0c6c6";
    pink = "f5bde6";
    mauve = "c6a0f6";
    red = "ed8796";
    maroon = "ee99a0";
    peach = "f5a97f";
    yellow = "eed49f";
    green = "a6da95";
    teal = "8bd5ca";
    sky = "91d7e3";
    sapphire = "7dc4e4";
    blue = "8aadf4";
    lavender = "b7bdf8";
    text = "cad3f5";
    subtext1 = "b8c0e0";
    subtext0 = "a5adcb";
    overlay2 = "939ab7";
    overlay1 = "8087a2";
    overlay0 = "6e738d";
    surface2 = "5b6078";
    surface1 = "494d64";
    surface0 = "363a4f";
    base = "24273a";
    mantle = "1e2030";
    crust = "181926";
  };

  colorVariables = lib.concatMapAttrs (name: hex: {
    "\$${name}" = "rgb(${hex})";
    "\$${name}Alpha" = hex;
  }) palette;

  pypr = "${pkgs.pyprland}/bin/pypr";
in
{
  imports = [ ./hyprland-services.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";

    settings = colorVariables // {
      "$mainMod" = "SUPER";
      "$terminal" = "alacritty";
      "$launcher" = "rofi -show drun";
      "$browser" = "firefox";
      "$fileManager" = "alacritty -e ranger";

      # Upstream pins workspaces 1-10 to eDP-1 and 11-20 to HDMI-A-1. That only
      # works on their laptop, so this stays on autodetection - the SUPER+ALT
      # binds below still address workspaces 11-20, they just land wherever
      # Hyprland puts them.
      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "waybar"
        "${pypr}"
        "${pkgs.avizo}/bin/avizo-service"
        "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular"
        "nm-applet --indicator"
        "blueman-applet"
        "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1"
      ];

      env = [
        "XCURSOR_THEME,catppuccin-macchiato-teal-cursors"
        "XCURSOR_SIZE,24"
      ];

      input = {
        # Upstream cycles us/ua/ru with SUPER+Space; only US is configured here.
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-and-drag = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "$teal";
        "col.inactive_border" = "$surface1";
        "col.nogroup_border_active" = "$teal";
        "col.nogroup_border" = "$surface1";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
        };

        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
          offset = "0, 0";
          color = "$teal";
          color_inactive = "0xff\$baseAlpha";
        };

        active_opacity = 0.7;
        inactive_opacity = 0.7;
        fullscreen_opacity = 0.7;
      };

      layerrule = [
        "blur on, match:namespace logout_dialog"
      ];

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 2, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "windowsMove, 1, 2, myBezier, slide"
          "border, 1, 3, default"
          "fade, 1, 2, default"
          "workspaces, 1, 1, default"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = true;
      };

      master = {
        new_status = "master";
      };

      gesture = [ "3, horizontal, workspace" ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "0x24273a";
      };

      binds = {
        workspace_back_and_forth = true;
      };

      windowrule = [
        "float on, match:title .*mpv$"
        "opaque on, match:title .*mpv$"
        "size 50% 50%, match:title .*mpv$"
        "float on, match:content 2"
        "opaque on, match:content 2"
        "size 50% 50%, match:content 2"

        "float on, match:title .*imv.*"
        "opaque on, match:title .*imv.*"
        "size 70% 70%, match:title .*imv.*"
        "float on, match:content 1"
        "opaque on, match:content 1"
        "size 70% 70%, match:content 1"

        "float on, match:title .*\\.pdf$"
        "opaque on, match:title .*\\.pdf$"
        "maximize on, match:title .*\\.pdf$"

        "opaque on, match:title swappy"
        "center on, match:title swappy"
        "stay_focused on, match:title swappy"

        # pyprland scratchpads
        "float on, match:class ^terminal-dropterm$"
        "pin on, match:class ^terminal-dropterm$"
        "float on, match:class ^org.pulseaudio.pavucontrol$"
        "pin on, match:class ^org.pulseaudio.pavucontrol$"
      ];

      bind = [
        # Submaps (defined in extraConfig, since hyprlang needs them ordered)
        "$mainMod ALT, R, submap, resize"
        "$mainMod ALT, M, submap, move"

        # Scratchpads / pyprland
        "$mainMod CTRL, T, exec, ${pypr} toggle term"
        "$mainMod CTRL, V, exec, ${pypr} toggle volume"
        "$mainMod CTRL, M, togglespecialworkspace, minimized"
        "$mainMod, M, exec, ${pypr} toggle_special minimized"
        "$mainMod CTRL, E, exec, ${pypr} expose"
        "$mainMod, Z, exec, ${pypr} zoom"
        "$mainMod SHIFT, C, exec, ${pypr} menu \"Color picker\""

        # Applications
        "$mainMod, Return, exec, $terminal"
        "$mainMod, T, exec, $terminal"
        "$mainMod, B, exec, $browser"
        "$mainMod, F, exec, $fileManager"
        "$mainMod, D, exec, $launcher"
        "$mainMod, ESCAPE, exec, ${scripts.wlogoutUnique}/bin/wlogout-unique"
        "$mainMod SHIFT, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

        # Screenshots, recording, colour picking
        "$mainMod SHIFT, S, exec, ${scripts.screenshotToClipboard}/bin/screenshot-to-clipboard"
        "$mainMod, E, exec, ${scripts.screenshotEdit}/bin/screenshot-edit"
        "$mainMod SHIFT, R, exec, ${scripts.recordScreenGif}/bin/record-screen-gif"
        "$mainMod, R, exec, ${scripts.recordScreenMp4}/bin/record-screen-mp4"
        "$mainMod, C, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a"

        # Clipboard history
        "$mainMod, V, exec, ${scripts.clipboardToType}/bin/clipboard-to-type"
        "$mainMod SHIFT, V, exec, ${scripts.clipboardToClipboard}/bin/clipboard-to-clipboard"
        "$mainMod, X, exec, ${scripts.clipboardDeleteItem}/bin/clipboard-delete-item"
        "$mainMod SHIFT, X, exec, ${scripts.clipboardClear}/bin/clipboard-clear"

        # Window management
        "$mainMod SHIFT, Q, killactive"
        "$mainMod SHIFT, F, togglefloating,"
        "$mainMod CTRL, F, fullscreen, 0"
        "$mainMod SHIFT, P, pseudo,"
        "$mainMod SHIFT, O, layoutmsg, togglesplit"
        "$mainMod ALT, Q, exit,"

        # Toggles
        "$mainMod SHIFT, A, exec, ${scripts.airplaneModeToggle}/bin/airplane-mode-toggle"
        "$mainMod SHIFT, N, exec, ${pkgs.dunst}/bin/dunstctl set-paused toggle"
        "$mainMod SHIFT, Y, exec, ${scripts.bluetoothToggle}/bin/bluetooth-toggle"
        "$mainMod SHIFT, W, exec, ${scripts.wifiToggle}/bin/wifi-toggle"
        "$mainMod SHIFT, G, exec, ${scripts.nightModeToggle}/bin/night-mode-toggle"

        # Media
        "$mainMod, P, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        "$mainMod, bracketright, exec, ${pkgs.playerctl}/bin/playerctl next"
        "$mainMod, bracketleft, exec, ${pkgs.playerctl}/bin/playerctl previous"

        # Focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod, Tab, cyclenext,"
        "$mainMod, Tab, bringactivetotop,"

        # Workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ]
      ++ (
        # 1-10 on SUPER, 11-20 on SUPER+ALT, moving a window adds SHIFT.
        builtins.concatMap
          (i:
            let
              key = toString (lib.mod i 10);
            in
            [
              "$mainMod, ${key}, workspace, ${toString i}"
              "$mainMod SHIFT, ${key}, movetoworkspace, ${toString i}"
              "$mainMod ALT, ${key}, workspace, ${toString (i + 10)}"
              "$mainMod ALT SHIFT, ${key}, movetoworkspace, ${toString (i + 10)}"
            ])
          (lib.range 1 10)
      );

      bindel = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.avizo}/bin/volumectl -u up"
        ", XF86AudioLowerVolume, exec, ${pkgs.avizo}/bin/volumectl -u down"
        ", XF86MonBrightnessUp, exec, ${pkgs.avizo}/bin/lightctl up"
        ", XF86MonBrightnessDown, exec, ${pkgs.avizo}/bin/lightctl down"
      ];

      bindl = [
        ", XF86AudioMute, exec, ${pkgs.avizo}/bin/volumectl toggle-mute"
        ", XF86AudioMicMute, exec, ${pkgs.avizo}/bin/volumectl -m toggle-mute"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };

    # Submaps are order-dependent in hyprlang (everything between `submap = x`
    # and `submap = reset` belongs to that submap), which an attribute set
    # cannot express - so they go in verbatim at the end of the file.
    extraConfig = ''
      submap = resize

      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10

      binde = , l, resizeactive, 10 0
      binde = , h, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10

      bind = , escape, submap, reset
      submap = reset

      submap = move

      bind = , right, movewindow, r
      bind = , left, movewindow, l
      bind = , up, movewindow, u
      bind = , down, movewindow, d

      bind = , l, movewindow, r
      bind = , h, movewindow, l
      bind = , k, movewindow, u
      bind = , j, movewindow, d

      bind = , escape, submap, reset
      submap = reset
    '';
  };

  # pyprland: dropdown terminal + pavucontrol side panel, plus the expose,
  # magnify and colour-picker menu plugins the keybinds above call into.
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
      "magnify",
      "expose",
      "shortcuts_menu",
      "toggle_special",
    ]

    [scratchpads.term]
    command = "alacritty --class terminal-dropterm"
    class = "terminal-dropterm"
    animation = "fromTop"
    unfocus = "hide"
    excludes = ["volume"]
    lazy = true
    multi = false
    size = "75% 60%"
    max_size = "1920px 100%"
    margin = 50

    [scratchpads.volume]
    command = "pavucontrol"
    animation = "fromLeft"
    class = "org.pulseaudio.pavucontrol"
    size = "40% 70%"
    unfocus = "hide"
    excludes = ["term"]
    lazy = true
    margin = 90
    multi = false

    [shortcuts_menu.entries]

    "Color picker" = [
        {name="format", options=["hex", "rgb", "hsv", "hsl", "cmyk"]},
        "sleep 0.2; ${pkgs.hyprpicker}/bin/hyprpicker --format [format] -a"
    ]
  '';

  home.packages = with pkgs; [
    # Hyprland ecosystem
    hyprpicker
    hyprsunset
    pyprland

    # Launcher / logout / notifications are configured in their own modules
    wl-clipboard
    wl-clip-persist
    cliphist
    wtype

    # Screenshots and screen recording
    grim
    slurp
    swappy
    wl-screenrec
    ffmpeg

    # Media / OSD
    playerctl
    avizo

    # Viewers the window rules above are written for
    mpv
    imv
  ]
  ++ builtins.attrValues scripts;
}
