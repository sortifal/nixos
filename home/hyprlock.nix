{ pkgs, ... }:

let
  c = {
    fg = "rgba(196, 212, 184, 0.80)";
    surface = "rgba(196, 212, 184, 0.1)";
    input_bg = "rgba(196, 212, 184, 0.1)";
    font_color = "rgba(196, 212, 184, 1.0)";
  };
in
{
  xdg.configFile."hypr/vivek.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/main/Style-4/vivek.png";
    sha256 = "0k0qj237cjhsxf807ajp089k4dyq9v7r0f5lxzbj1r4jbi975glf";
  };

  xdg.configFile."hypr/wallpaper.jpg".source = pkgs.fetchurl {
    url = "https://github.com/comfysage/wallpapers/raw/mega/frieren/5ce40a596e06c13cf68ef474cd06ad783d63193a.jpg";
    sha256 = "17k1cfpdhvrhxznlkybks5184bps9q6wd5g29d5xbrhwr21pv20l";
  };

  xdg.configFile."hypr/wonder-egg-priority.jpg".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sortifal/ProfilePictures/main/wonder-egg-priority.jpg";
    sha256 = "1f2ziz2jw1agw1i9v61d7bbyc6289a3zb1f2h6x6k3vlpcc9hp4f";
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = false;
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "/home/sorti/.config/hypr/wallpaper.jpg";
          blur_passes = 0;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.8916;
          vibrancy_darkness = 0.0;
        }
      ];

      image = {
        monitor = "";
        path = "/home/sorti/.config/hypr/wonder-egg-priority.jpg";
        border_size = 2;
        border_color = "rgba(74, 222, 128, 0.80)";
        size = 100;
        rounding = -1;
        rotate = 0;
        reload_time = -1;
        reload_cmd = "";
        position = "25, 200";
        halign = "center";
        valign = "center";
      };

      label = [
        {
          monitor = "";
          text = "$DESC";
          color = c.fg;
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "25, 110";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span>$(date +\"%I:%M\")</span>\"";
          color = "rgba(94, 234, 212, 0.80)";
          font_size = 60;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "30, -8";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] date +\"%A, %B %d\"";
          color = c.fg;
          font_size = 19;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "35, -60";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "  $USER";
          color = c.fg;
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "38, -190";
          halign = "center";
          valign = "center";
        }
      ];

      shape = {
        rectangle = [
          {
            monitor = "";
            size = "320, 55";
            color = c.surface;
            rounding = -1;
            border_size = 0;
            border_color = "rgba(74, 222, 128, 1)";
            rotate = 0;
            xray = false;
            position = "34, -190";
            halign = "center";
            valign = "center";
          }
        ];
      };

      input-field = {
        monitor = "";
        size = "320, 55";
        outline_thickness = 0;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(255, 255, 255, 0)";
        inner_color = c.input_bg;
        font_color = c.font_color;
        fade_on_empty = false;
        font_family = "JetBrainsMono Nerd Font Bold";
        placeholder_text = "<i><span foreground=\"##c4d4b899\">  Enter Pass</span></i>";
        hide_input = false;
        position = "34, -268";
        halign = "center";
        valign = "center";
      };
    };
  };
}
