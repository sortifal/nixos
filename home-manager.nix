{ config, pkgs, ... }:

{
  home-manager.users.sorti = { pkgs, ... }: {
    home.username = "sorti";
    home.homeDirectory = "/home/sorti";
    home.stateVersion = "25.11";

    imports = [
      ./home/packages.nix
    ];

    programs.home-manager.enable = true;
  };
}
