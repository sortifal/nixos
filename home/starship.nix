{ pkgs, ... }:

{
  home.packages = [ pkgs.starship ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nodejs$python$rust$nix_shell$cmd_duration$line_break$character";
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = { format = "[$symbol$branch]($style) "; style = "bold purple"; };
      git_status = { style = "bold red"; };
      cmd_duration = { min_time = 2000; format = "took [$duration](bold yellow) "; };
      nix_shell = { symbol = "❄ "; format = "[$symbol$state]($style) "; };
      palette = "macchiato";
      palettes.macchiato = {
        cyan = "#8bd5ca";
        green = "#a6da95";
        red = "#ed8796";
        yellow = "#eed49f";
        purple = "#c6a0f6";
      };
    };
  };
}
