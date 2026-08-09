{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; };
        decorations = "full";
        dynamic_title = true;
        # Hyprland applies window opacity itself (decoration.active_opacity),
        # so the terminal stays fully opaque here.
        opacity = 1.0;
        startup_mode = "Windowed";
        dimensions = { columns = 80; lines = 24; };
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        size = 7.0;

        offset = { x = 0; y = 0; };
        glyph_offset = { x = 0; y = 0; };
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        bold_italic = { family = "JetBrainsMono Nerd Font"; style = "Bold Italic"; };
      };

      # Catppuccin Macchiato
      colors = {
        primary = { background = "#24273a"; foreground = "#cad3f5"; };
        cursor = { text = "#24273a"; cursor = "#f4dbd6"; };
        selection = { text = "#24273a"; background = "#f4dbd6"; };
        normal = {
          black = "#494d64";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#b8c0e0";
        };
        bright = {
          black = "#5b6078";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#a5adcb";
        };
        dim = {
          black = "#494d64";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#b8c0e0";
        };
      };

      bell = { animation = "EaseOutExpo"; duration = 300; color = "#f4dbd6"; };
      selection = { save_to_clipboard = true; };
      cursor = { style = "Block"; };
      mouse = { hide_when_typing = true; };

      keyboard.bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        { key = "N"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
      ];
    };
  };
}
