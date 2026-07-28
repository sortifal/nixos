{ pkgs, ... }:

let
  themeContent = ''
    * {
      bg: #0a0e0a;
      fg: #c4d4b8;
      border: #1a2a1a;
      separator: #6b7b6b;
      urgent-bg: #e57373;
      urgent-fg: #0a0e0a;
      urgent-border: #e57373;
      active-bg: #4ade80;
      active-fg: #0a0e0a;
      active-border: #4ade80;
      selected-bg: #11100f;
      selected-fg: #c4d4b8;
      selected-border: #4ade80;
      spacing: 2;
      padding: 12;
      margin: 0;
      border-radius: 12;
    }

    element-text {
      background-color: inherit;
      text-color: inherit;
    }

    element {
      padding: 8;
      border-radius: 8;
    }

    element normal {
      background-color: #11100f;
      text-color: #c4d4b8;
      border-radius: 8;
    }

    element normal urgent {
      background-color: #e57373;
      text-color: #0a0e0a;
      border-radius: 8;
    }

    element normal active {
      background-color: #4ade80;
      text-color: #0a0e0a;
      border-radius: 8;
    }

    element selected {
      background-color: #11100f;
      text-color: #4ade80;
      border-color: #4ade80;
      border-radius: 8;
    }

    element selected urgent {
      background-color: #e57373;
      text-color: #0a0e0a;
      border-color: #e57373;
      border-radius: 8;
    }

    element selected active {
      background-color: #4ade80;
      text-color: #0a0e0a;
      border-color: #4ade80;
      border-radius: 8;
    }

    element-icon {
      background-color: inherit;
      text-color: inherit;
      size: 28;
      margin: 0 8px 0 0;
    }

    element-icon urgent {
      background-color: inherit;
      text-color: #e57373;
    }

    element-icon active {
      background-color: inherit;
      text-color: #4ade80;
    }

    mode {
      background-color: #11100f;
      text-color: #4ade80;
      border-color: #4ade80;
      border-radius: 8;
      padding: 8;
    }

    button {
      background-color: #11100f;
      text-color: #c4d4b8;
      border-radius: 8;
      padding: 8;
      horizontal-align: 0.5;
    }

    button selected {
      background-color: #4ade80;
      text-color: #0a0e0a;
    }

    inputbar {
      background-color: #11100f;
      text-color: #c4d4b8;
      border-color: #1a2a1a;
      border-radius: 12;
      padding: 12;
      children: [prompt, entry];
    }

    prompt {
      background-color: inherit;
      text-color: #4ade80;
    }

    entry {
      background-color: inherit;
      text-color: #c4d4b8;
      placeholder-color: #6b7b6b;
      cursor-color: #4ade80;
      blink: true;
    }

    listview {
      background-color: inherit;
      columns: 1;
      lines: 8;
      fixed-height: true;
      fixed-columns: true;
      border: true;
      border-color: #1a2a1a;
      border-radius: 12;
      padding: 8;
      spacing: 4;
      cycle: true;
      dynamic: true;
      scrollbar: false;
    }

    scrollbar {
      background-color: #1a2a1a;
      handle-color: #6b7b6b;
      border-radius: 8;
      width: 4;
    }

    sidebar {
      background-color: #11100f;
      border-color: #1a2a1a;
      border-radius: 12;
    }

    window {
      background-color: #0a0e0a;
      text-color: #c4d4b8;
      border-color: #1a2a1a;
      border-radius: 12;
      padding: 16;
      width: 600;
      fullscreen: false;
      transparency: "real";
    }
  '';
in
{
  home.file.".config/rofi/techno-naturalism.rasi".text = themeContent;

  programs.rofi = {
    enable = true;
    terminal = "alacritty";
    theme = "techno-naturalism";
    extraConfig = {
      modi = "run,drun,window";
      font = "JetBrainsMono Nerd Font 12";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name}";
      disable-history = false;
      sort = true;
      matching = "fuzzy";
      sidebar-mode = false;
      hover-select = true;
    };
  };
}
