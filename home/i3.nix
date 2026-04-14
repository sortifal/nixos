{ pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/whoisYoges/lwalpapers/PicturesOnly/wallpapers/b-002.jpg";
    sha256 = "1g7nv6d28kvi4p3gq71jshdzaa24ainbjhcvbpsfm5winrq5sr9l";
  };
in
{
  home.file.".wallpaper".source = wallpaper;

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "rofi -show drun";

      startup = [
        { command = "feh --bg-fill ~/.wallpaper"; always = true; notification = false; }
        { command = "picom"; notification = false; }
        { command = "nm-applet"; notification = false; }
      ];

      keybindings = let mod = "Mod4"; in {
        "${mod}+Return" = "exec alacritty";
        "${mod}+d" = "exec rofi -show drun";
        "${mod}+q" = "kill";
        "${mod}+Shift+q" = "exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'";
        "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+v" = "split v";
        "${mod}+h" = "split h";
        "${mod}+j" = "focus left";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus up";
        "${mod}+semicolon" = "focus right";
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+semicolon" = "move right";
        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";
        "${mod}+0" = "workspace 10";
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+r" = "mode resize";
      };

      colors = {
        focused = {
          background = "#0a0e0a";
          border = "#4ade80";
          childBorder = "#4ade80";
          indicator = "#4ade80";
          text = "#c4d4b8";
        };
        focusedInactive = {
          background = "#0a0e0a";
          border = "#1a2a1a";
          childBorder = "#1a2a1a";
          indicator = "#1a2a1a";
          text = "#6b7b6b";
        };
        unfocused = {
          background = "#0a0e0a";
          border = "#0a0e0a";
          childBorder = "#0a0e0a";
          indicator = "#0a0e0a";
          text = "#6b7b6b";
        };
        urgent = {
          background = "#e57373";
          border = "#e57373";
          childBorder = "#e57373";
          indicator = "#e57373";
          text = "#0a0e0a";
        };
      };

      bars = [{
        position = "top";
        statusCommand = "i3status";
        colors = {
          background = "#0a0e0a";
          separator = "#1a2a1a";
          focusedWorkspace = { border = "#4ade80"; background = "#1a2a1a"; text = "#c4d4b8"; };
          activeWorkspace = { border = "#1a2a1a"; background = "#1a2a1a"; text = "#6b7b6b"; };
          inactiveWorkspace = { border = "#0a0e0a"; background = "#0a0e0a"; text = "#6b7b6b"; };
          urgentWorkspace = { border = "#e57373"; background = "#e57373"; text = "#0a0e0a"; };
        };
      }];

      gaps = {
        inner = 10;
        outer = 5;
      };
    };
  };
}
