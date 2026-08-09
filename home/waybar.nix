{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = false;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M   %a %d %b}";
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pamixer -t";
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ifname}";
          format-disconnected = "⚠ disconnected";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          states = {
            warning = 30;
            critical = 15;
          };
        };

        tray = {
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background-color: #0a0e0a;
        color: #c4d4b8;
      }

      #workspaces button {
        padding: 0 8px;
        color: #6b7b6b;
        background-color: transparent;
      }

      #workspaces button.active {
        color: #4ade80;
        border-bottom: 2px solid #4ade80;
      }

      #clock,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
        color: #c4d4b8;
      }

      #battery.warning {
        color: #f0e68c;
      }

      #battery.critical {
        color: #e57373;
      }
    '';
  };
}
