{ pkgs, ... }:

{
  home.packages = with pkgs; [
  ];

  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox.override {
        cfg = {
          smartcardSupport = true;
        };
      };
    };

    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = { x = 10; y = 10; };
          decorations = "full";
          dynamic_title = true;
          opacity = 0.95;
          startup_mode = "Windowed";
          dimensions = { columns = 80; lines = 24; };
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        font = {
          size = 7.0;
          use_thin_strokes = true;
          offset = { x = 0; y = 0; };
          glyph_offset = { x = 0; y = 0; };
          normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
          bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
          italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
          bold_italic = { family = "JetBrainsMono Nerd Font"; style = "Bold Italic"; };
        };

        colors = {
          primary = { background = "#0a0e0a"; foreground = "#c4d4b8"; };
          cursor = { text = "#0a0e0a"; cursor = "#4ade80"; };
          normal = {
            black = "#0a0e0a";
            red = "#e57373";
            green = "#4ade80";
            yellow = "#f0e68c";
            blue = "#7dd3fc";
            magenta = "#c084fc";
            cyan = "#5eead4";
            white = "#c4d4b8";
          };
          bright = {
            black = "#1a2a1a";
            red = "#f87171";
            green = "#86efac";
            yellow = "#fef08a";
            blue = "#a5f3fc";
            magenta = "#d8b4fe";
            cyan = "#99f6e4";
            white = "#f0fdf4";
          };
          dim = {
            black = "#0a0e0a";
            red = "#e57373";
            green = "#4ade80";
            yellow = "#f0e68c";
            blue = "#7dd3fc";
            magenta = "#c084fc";
            cyan = "#5eead4";
            white = "#6b7b6b";
          };
        };

        bell = { animation = "EaseOutExpo"; duration = 300; color = "#ffffff"; };
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
  };
}
