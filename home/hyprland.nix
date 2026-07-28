{ pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://github.com/comfysage/wallpapers/raw/mega/frieren/5ce40a596e06c13cf68ef474cd06ad783d63193a.jpg";
    sha256 = "17k1cfpdhvrhxznlkybks5184bps9q6wd5g29d5xbrhwr21pv20l";
  };
in
{
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.wallpaper
    wallpaper = eDP-1,~/.wallpaper
    wallpaper = HDMI-A-1,~/.wallpaper
    wallpaper = DP-1,~/.wallpaper
    ipc = on
  '';

  home.file.".wallpaper".source = wallpaper;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "wofi --show drun";

      monitor = ",preferred,auto,1";

      exec-once = [
        "waybar"
        "hyprpaper"
        "nm-applet"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      general = {
        gaps_in = 10;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(74de80ff)";
        "col.inactive_border" = "rgba(262a26aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(0a0e0aaa)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        session_lock_xray = true;
      };

      windowrulev2 = [
        "float, title:^(pavucontrol)$"
        "float, title:^(blueman-manager)$"
        "workspace 9 silent, class:^(obsidian)$"
        "workspace 8 silent, class:^(code-url-handler)$"
        "workspace 8 silent, class:^(Code)$"
        "workspace 8 silent, class:^(code-oss)$"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"
        "$mod, D, exec, rofi -show drun"
        "$mod, P, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, L, exec, hyprlock"
        "CTRL SHIFT, L, exec, hyprlock"

        "$mod, O, workspace, 9"
        "$mod, C, workspace, 8"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, minus, splitratio, -0.1"
        "$mod, equal, splitratio, 0.1"

        "$mod CTRL, h, resizeactive, -20 0"
        "$mod CTRL, l, resizeactive, 20 0"
        "$mod CTRL, k, resizeactive, 0 -20"
        "$mod CTRL, j, resizeactive, 0 20"

        "$mod, left, workspace, e-1"
        "$mod, right, workspace, e+1"

        "$mod SHIFT, left, movetoworkspace, e-1"
        "$mod SHIFT, right, movetoworkspace, e+1"

        ", XF86AudioRaiseVolume, exec, pamixer -u -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -u -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", switch:Lid Switch on, exec, hyprlock"
        ", switch:Lid Switch off, exec, hyprlock"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = hyprctl setcursor ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic/index.theme
  '';
}
