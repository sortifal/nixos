{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      # Catppuccin Macchiato
      set -U fish_color_normal cad3f5
      set -U fish_color_command 8aadf4
      set -U fish_color_keyword f5bde6
      set -U fish_color_quote a6da95
      set -U fish_color_redirection f5bde6
      set -U fish_color_end f5a97f
      set -U fish_color_error ed8796
      set -U fish_color_param f4dbd6
      set -U fish_color_comment 6e738d
      set -U fish_color_selection --background=494d64
      set -U fish_color_autosuggestion 6e738d
      set -U fish_pager_color_progress 6e738d
      set -U fish_pager_color_description 8bd5ca
      set -U fish_pager_color_completion cad3f5
    '';

    shellAbbrs = {
      ll = "ls -la";
      la = "ls -a";
      l  = "ls";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      vim = "nvim";
      vi  = "nvim";
    };

    shellInit = ''
      function fish_user_key_bindings
        bind \cv 'fish_clipboard_paste'
        bind \cy 'fish_clipboard_copy'
      end
    '';
  };
}
