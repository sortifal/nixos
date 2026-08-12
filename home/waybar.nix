# Single top-bar Waybar layout: workspaces/taskbar and system meters live in
# one bar instead of being split across separate top/bottom/left bars.
{ pkgs, ... }:

let
  scripts = import ./hypr-scripts.nix { inherit pkgs; };
in
{
  programs.waybar = {
    enable = true;
    # Started from Hyprland's exec-once rather than a systemd unit, so it comes
    # up with the compositor even outside a systemd-managed session.
    systemd.enable = false;

    settings = [
      {
        name = "top_bar";
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/submap" "wlr/taskbar" ];
        modules-center = [
          "clock#time"
          "custom/separator"
          "clock#week"
          "custom/separator_dot"
          "clock#month"
          "custom/separator"
          "clock#calendar"
        ];
        modules-right = [
          "cpu"
          "memory"
          "disk"
          "temperature"
          "battery"
          "backlight"
          "pulseaudio"
          "systemd-failed-units"
          "bluetooth"
          "network"
          "group/misc"
          "tray"
          "custom/logout_menu"
        ];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "10" = "󰿬";
            special = "";
          };
          show-special = true;
          persistent-workspaces = { "*" = 10; };
        };

        "hyprland/submap" = {
          format = "<span color='#a6da95'>Mode:</span> {}";
          tooltip = false;
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-right = "close";
          on-click-middle = "fullscreen";
        };

        "clock#time" = {
          format = "{:%H:%M}";
        };

        "custom/separator" = {
          format = "|";
          tooltip = false;
        };

        "custom/separator_dot" = {
          format = "•";
          tooltip = false;
        };

        "clock#week" = { format = "{:%a}"; };
        "clock#month" = { format = "{:%h}"; };

        "clock#calendar" = {
          format = "{:%F}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          actions = { on-click-right = "mode"; };
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#f4dbd6'><b>{}</b></span>";
              days = "<span color='#cad3f5'><b>{}</b></span>";
              weeks = "<span color='#c6a0f6'><b>W{}</b></span>";
              weekdays = "<span color='#a6da95'><b>{}</b></span>";
              today = "<span color='#8bd5ca'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = "󰻠 {usage}%";
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          on-click = "alacritty -e htop";
        };

        memory = {
          format = "󰍛 {percentage}%";
          tooltip-format = "Main: ({used} GiB/{total} GiB)({percentage}%), available {avail} GiB\nSwap: ({swapUsed} GiB/{swapTotal} GiB)({swapPercentage}%), available {swapAvail} GiB";
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          on-click = "alacritty -e htop";
        };

        disk = {
          format = "󰋊 {percentage_used}%";
          tooltip-format = "({used}/{total})({percentage_used}%) in '{path}', available {free}({percentage_free}%)";
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          on-click = "alacritty -e htop";
        };

        # Upstream pins thermal-zone 8, which is laptop-specific; leaving it
        # out lets waybar pick the default zone.
        temperature = {
          tooltip = false;
          critical-threshold = 80;
          format = "{icon} {temperatureC}󰔄";
          format-critical = "🔥 {icon} {temperatureC}󰔄";
          format-icons = [ "" "" "" "" "" ];
        };

        battery = {
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          format = "{icon} {capacity}%";
          format-charging = "󱐋 {icon} {capacity}%";
          format-plugged = "󰚥 {icon} {capacity}%";
          format-time = "{H} h {M} min";
          format-icons = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format = "{timeTo}";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [
            "󰌶"
            "󱩎"
            "󱩏"
            "󱩐"
            "󱩑"
            "󱩒"
            "󱩓"
            "󱩔"
            "󱩕"
            "󱩖"
            "󰛨"
          ];
          tooltip = false;
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          reverse-scrolling = true;
          reverse-mouse-scrolling = true;
        };

        pulseaudio = {
          states = {
            high = 90;
            upper-medium = 70;
            medium = 50;
            lower-medium = 30;
            low = 10;
          };
          tooltip-format = "{desc}";
          format = "{icon} {volume}%\n{format_source}";
          format-bluetooth = "󰂱 {icon} {volume}%\n{format_source}";
          format-bluetooth-muted = "󰂱 󰝟 {volume}%\n{format_source}";
          format-muted = "󰝟 {volume}%\n{format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭 {volume}%";
          format-icons = {
            headphone = "󰋋";
            hands-free = "";
            headset = "󰋎";
            phone = "󰄜";
            portable = "󰦧";
            car = "󰄋";
            speaker = "󰓃";
            hdmi = "󰡁";
            hifi = "󰋌";
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          reverse-scrolling = true;
          reverse-mouse-scrolling = true;
          on-click = "pavucontrol";
        };

        systemd-failed-units = {
          format = "✗ {nr_failed}";
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} (󰥉 {device_battery_percentage}%)";
          tooltip-format = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected";
          tooltip-format-disabled = "bluetooth off";
          tooltip-format-connected = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t({device_battery_percentage}%)";
          max-length = 35;
          on-click = "${scripts.bluetoothToggle}/bin/bluetooth-toggle";
          on-click-right = "blueman-manager";
        };

        network = {
          format = "󰤭";
          format-wifi = "{icon}({signalStrength}%){essid}";
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format-disconnected = "󰤫 Disconnected";
          tooltip-format = "wifi <span color='#ee99a0'>off</span>";
          tooltip-format-wifi = "SSID: {essid}({signalStrength}%), {frequency} MHz\nInterface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
          tooltip-format-disconnected = "<span color='#ed8796'>disconnected</span>";
          max-length = 35;
          on-click = "${scripts.wifiToggle}/bin/wifi-toggle";
          on-click-right = "nm-connection-editor";
        };

        "group/misc" = {
          orientation = "horizontal";
          modules = [ "privacy" "mpris" "idle_inhibitor" ];
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 12;
          transition-duration = 250;
          modules = [
            { type = "audio-in"; }
            { type = "screenshare"; }
          ];
        };

        # Upstream drives this from a fish script around playerctl; waybar's
        # built-in mpris module covers the same ground without the helper.
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          player-icons = { default = ""; };
          status-icons = { paused = ""; };
          dynamic-len = 35;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰛐";
            deactivated = "󰛑";
          };
          tooltip-format-activated = "idle-inhibitor <span color='#a6da95'>on</span>";
          tooltip-format-deactivated = "idle-inhibitor <span color='#ee99a0'>off</span>";
          start-activated = true;
        };

        tray = {
          icon-size = 20;
          spacing = 2;
        };

        "custom/logout_menu" = {
          return-type = "json";
          exec = "echo '{ \"text\":\"󰐥\", \"tooltip\": \"logout menu\" }'";
          interval = "once";
          on-click = "${scripts.wlogoutUnique}/bin/wlogout-unique";
        };
      }
    ];

    style = ''
      /* Catppuccin Macchiato palette */
      @define-color base   #24273a;
      @define-color mantle #1e2030;
      @define-color crust  #181926;

      @define-color text     #cad3f5;
      @define-color subtext0 #a5adcb;
      @define-color subtext1 #b8c0e0;

      @define-color surface0 #363a4f;
      @define-color surface1 #494d64;
      @define-color surface2 #5b6078;

      @define-color overlay0 #6e738d;
      @define-color overlay1 #8087a2;
      @define-color overlay2 #939ab7;

      @define-color blue      #8aadf4;
      @define-color lavender  #b7bdf8;
      @define-color sapphire  #7dc4e4;
      @define-color sky       #91d7e3;
      @define-color teal      #8bd5ca;
      @define-color green     #a6da95;
      @define-color yellow    #eed49f;
      @define-color peach     #f5a97f;
      @define-color maroon    #ee99a0;
      @define-color red       #ed8796;
      @define-color mauve     #c6a0f6;
      @define-color pink      #f5bde6;
      @define-color flamingo  #f0c6c6;
      @define-color rosewater #f4dbd6;

      * {
        border: none;
        font-family: "JetBrains Mono", "Symbols Nerd Font", "Noto Color Emoji";
      }

      window.top_bar#waybar {
        background-color: alpha(@base, 0.7);
        border-bottom: solid alpha(@surface1, 0.7) 2px;
      }

      #workspaces {
        margin-left: 10px;
      }

      #workspaces button {
        color: @text;
        font-size: 1.25rem;
      }

      #workspaces button.empty {
        color: @overlay0;
      }

      #workspaces button.active {
        color: @peach;
      }

      #submap {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15px;
        padding-left: 15px;
        padding-right: 15px;
        margin-left: 20px;
        margin-right: 20px;
        margin-top: 5px;
        margin-bottom: 5px;
      }

      #taskbar {
        margin-left: 10px;
      }

      #taskbar button.active {
        background-color: alpha(@surface1, 0.7);
        border-radius: 10px;
      }

      window.top_bar .modules-center {
        font-weight: bold;
        background-color: alpha(@surface1, 0.7);
        color: @peach;
        border-radius: 15px;
        padding-left: 20px;
        padding-right: 20px;
        margin-top: 5px;
        margin-bottom: 5px;
      }

      #custom-separator,
      #custom-separator_dot {
        color: @green;
      }

      #clock.time {
        color: @flamingo;
      }

      #clock.week,
      #clock.month {
        color: @sapphire;
      }

      #clock.calendar {
        color: @mauve;
      }

      #cpu,
      #memory,
      #disk {
        color: @sapphire;
      }

      #cpu.low,
      #memory.low,
      #disk.low {
        color: @rosewater;
      }

      #cpu.lower-medium,
      #memory.lower-medium,
      #disk.lower-medium {
        color: @yellow;
      }

      #cpu.medium,
      #memory.medium,
      #disk.medium {
        color: @peach;
      }

      #cpu.upper-medium,
      #memory.upper-medium,
      #disk.upper-medium {
        color: @maroon;
      }

      #cpu.high,
      #memory.high,
      #disk.high {
        color: @red;
      }

      #temperature {
        color: @green;
      }

      #temperature.critical {
        color: @red;
      }

      #battery {
        color: @teal;
      }

      #battery.low {
        color: @red;
      }

      #battery.lower-medium {
        color: @maroon;
      }

      #battery.medium {
        color: @peach;
      }

      #battery.upper-medium {
        color: @flamingo;
      }

      #battery.high {
        color: @rosewater;
      }

      #backlight {
        color: @overlay0;
      }

      #backlight.low {
        color: @overlay1;
      }

      #backlight.lower-medium {
        color: @overlay2;
      }

      #backlight.medium {
        color: @subtext0;
      }

      #backlight.upper-medium {
        color: @subtext1;
      }

      #backlight.high {
        color: @text;
      }

      #pulseaudio {
        color: @text;
      }

      #pulseaudio.bluetooth {
        color: @sapphire;
      }

      #pulseaudio.muted {
        color: @surface2;
      }

      #pulseaudio.low {
        color: @overlay0;
      }

      #pulseaudio.lower-medium {
        color: @overlay1;
      }

      #pulseaudio.medium {
        color: @overlay2;
      }

      #pulseaudio.upper-medium {
        color: @subtext0;
      }

      #pulseaudio.high {
        color: @subtext1;
      }

      #systemd-failed-units {
        color: @red;
      }

      #bluetooth {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15px;
        padding-left: 15px;
        padding-right: 15px;
        margin-top: 5px;
        margin-bottom: 5px;
      }

      #bluetooth.disabled {
        background-color: alpha(@surface0, 0.7);
        color: @subtext0;
      }

      #bluetooth.on {
        color: @blue;
      }

      #bluetooth.connected {
        color: @sapphire;
      }

      #network {
        background-color: alpha(@surface1, 0.7);
        border-radius: 15px;
        padding-left: 15px;
        padding-right: 15px;
        margin-left: 2px;
        margin-right: 2px;
        margin-top: 5px;
        margin-bottom: 5px;
      }

      #network.disabled {
        background-color: alpha(@surface0, 0.7);
        color: @subtext0;
      }

      #network.disconnected {
        color: @red;
      }

      #network.wifi {
        color: @teal;
      }

      #idle_inhibitor {
        margin-right: 6px;
      }

      #idle_inhibitor.deactivated {
        color: @subtext0;
      }

      #mpris {
        margin-right: 6px;
      }

      #mpris.paused {
        color: @subtext0;
      }

      #privacy-item.screenshare {
        color: @peach;
        margin-right: 6px;
      }

      #privacy-item.audio-in {
        color: @pink;
        margin-right: 6px;
      }

      #tray {
        margin-left: 10px;
        margin-right: 6px;
      }

      #tray > .needs-attention {
        background-color: alpha(@maroon, 0.7);
        border-radius: 10px;
      }

      #custom-logout_menu {
        color: @red;
        background-color: alpha(@surface1, 0.7);
        border-radius: 15px 0 0 15px;
        padding-left: 10px;
        padding-right: 5px;
        margin-top: 5px;
        margin-bottom: 5px;
      }
    '';
  };
}
