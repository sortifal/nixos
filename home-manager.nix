{ config, pkgs, ... }:

{
  home-manager.users.sorti = { pkgs, ... }: {
    home.username = "sorti";
    home.homeDirectory = "/home/sorti";
    home.stateVersion = "25.11";

    imports = [
      ./home/firefox.nix
      ./home/alacritty.nix
      ./home/starship.nix
      ./home/fish.nix
      ./home/theme.nix
      ./home/hyprland.nix
      ./home/waybar.nix
      ./home/rofi.nix
      ./home/notifications.nix
      ./home/wlogout.nix
    ];

    programs.home-manager.enable = true;
  };
}
