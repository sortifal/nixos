{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$launcher" = "wofi --show drun";
      "$browser" = "firefox";
      "$fileManager" = "alacritty -e ranger";

      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "waybar"
        "mako"
        "swaybg -c '#0a0e0a'"
        "nm-applet --indicator"
        "blueman-applet"
        "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1"
      ];

      env = [
        "XCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(4ade80)";
        "col.inactive_border" = "rgb(1a2a1a)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;

        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };

        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
          color = "rgba(0a0e0aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 5, default, popin 80%"
          "border, 1, 8, default"
          "fade, 1, 5, default"
          "workspaces, 1, 5, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      bind =
        [
          "$mod, Return, exec, $terminal"
          "$mod, Q, killactive,"
          "$mod SHIFT, Q, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, D, exec, $launcher"
          "$mod, F, fullscreen,"
          "$mod, B, exec, $browser"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"
          "$mod, L, exec, swaylock"
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

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
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  home.packages = with pkgs; [
    wofi
    swaybg
    mako
    grim
    slurp
    wl-clipboard
    swaylock
    swayidle
  ];

  xdg.configFile."mako/config".text = ''
    background-color=#0a0e0aee
    text-color=#c4d4b8
    border-color=#4ade80
    border-size=2
    border-radius=8
    default-timeout=5000
    font=JetBrainsMono Nerd Font 10
    padding=10
    margin=8
    anchor=top-right
  '';

  xdg.configFile."wofi/config".text = ''
    width=600
    height=340
    location=center
    show=drun
    prompt=Search
    allow_markup=true
    insensitive=true
    term=alacritty
  '';

  xdg.configFile."wofi/style.css".text = ''
    window {
      background-color: #0a0e0a;
      color: #c4d4b8;
      border: 2px solid #4ade80;
      border-radius: 8px;
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
    }

    #input {
      margin: 8px;
      padding: 6px;
      background-color: #1a2a1a;
      color: #c4d4b8;
      border: none;
      border-radius: 6px;
    }

    #entry:selected {
      background-color: #1a2a1a;
      color: #4ade80;
    }
  '';
}
