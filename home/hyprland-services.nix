# hyprpaper / hypridle / hyprlock - the companion daemons the upstream config
# runs alongside Hyprland. They are wired up through home-manager's modules, so
# each one gets a user service bound to graphical-session.target.
{ config, pkgs, ... }:

let
  # hypridle runs as a systemd user unit with a minimal PATH, so everything it
  # shells out to is addressed absolutely. loginctl/systemctl come from the
  # running system rather than a pinned systemd closure.
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "/run/current-system/sw/bin/loginctl";
  systemctl = "/run/current-system/sw/bin/systemctl";

  # Upstream commits its wallpaper to the dotfiles repo and points hyprpaper
  # and hyprlock at ~/background. This does the same with ./wallpaper.jpg at
  # the repo root, installed to ~/Pictures/wallpaper.jpg below.
  #
  # The configs deliberately name that stable path rather than interpolating
  # the store path directly. Both work, but a raw /nix/store/... string baked
  # into hyprpaper.conf is opaque - you cannot tell by looking whether it
  # still resolves, and a stale generation or an interrupted GC shows up as a
  # silently missing wallpaper. ~/Pictures/wallpaper.jpg is a home-manager
  # symlink into the store, so it stays declarative but can be checked with ls.
  wallpaperPath = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
in
{
  home.file."Pictures/wallpaper.jpg".source = ../wallpaper.jpg;

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      splash = false;
      preload = [ wallpaperPath ];
      wallpaper = [ ",${wallpaperPath}" ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Guard against stacking hyprlock instances on repeated lock events.
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${hyprctl} dispatch exec hyprlock";
        before_sleep_cmd = "${loginctl} lock-session";
        # Without this the display needs two keypresses to come back after resume.
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
      };

      # Upstream hardcodes `intel_backlight`; letting brightnessctl pick the
      # device keeps this working on the AMD iGPU in this machine.
      listener = [
        {
          timeout = 180; # 3 min - dim, but never to 0.
          on-timeout = "${brightnessctl} -s set 15%";
          on-resume = "${brightnessctl} -r";
        }
        {
          timeout = 300; # 5 min - lock.
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 350; # screen off.
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 420; # 7 min - suspend.
          on-timeout = "${systemctl} suspend";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;

      background = [{
        monitor = "";
        path = wallpaperPath;
        blur_passes = 2;
        color = "rgb(24273a)";
      }];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:30000] echo "$(date +"%I:%M %p")"'';
          color = "rgb(cad3f5)";
          font_size = 90;
          font_family = "JetBrains Mono Regular";
          position = "-130, -100";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"'';
          color = "rgb(cad3f5)";
          font_size = 25;
          font_family = "JetBrains Mono Regular";
          position = "-130, -250";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
        # Keyboard layout
        {
          monitor = "";
          text = "$LAYOUT";
          color = "rgb(cad3f5)";
          font_size = 20;
          font_family = "JetBrains Mono Regular";
          position = "-130, -310";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
        }
      ];

      input-field = [{
        monitor = "";
        size = "400, 70";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(8bd5cab3)";
        inner_color = "rgb(363a4f)";
        font_color = "rgb(cad3f5)";
        fade_on_empty = false;
        # `##` is hyprlang's escape for a literal `#`, which pango needs here.
        placeholder_text = ''<span foreground="##cad3f5"><i>󰌾 Logged in as </i><span foreground="##8bd5ca">$USER</span></span>'';
        hide_input = false;
        check_color = "rgb(91d7e3)";
        fail_color = "rgb(ed8796)";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "rgb(eed49f)";
        position = "0, -185";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
      }];
    };
  };

  home.packages = [ pkgs.brightnessctl ];
}
