{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -U fish_color_normal c4d4b8
      set -U fish_color_command 5eead4
      set -U fish_color_keyword c084fc
      set -U fish_color_quote f0e68c
      set -U fish_color_redirection 4ade80
      set -U fish_color_end 86efac
      set -U fish_color_error e57373
      set -U fish_color_param 7dd3fc
      set -U fish_color_comment 6b7b6b
      set -U fish_color_selection --background=1a2a1a
      set -U fish_color_autosuggestion 6b7b6b
      set -U fish_pager_color_progress 6b7b6b
      set -U fish_pager_color_description 5eead4
      set -U fish_pager_color_completion c4d4b8
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
