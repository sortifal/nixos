# home-manager wiring. The NixOS module itself is imported in
# hosts/nixos/default.nix; this file only says what the user's environment is,
# so it stays shared between hosts.
{ config, pkgs, ... }:

{
  # Build the user environment from the system's nixpkgs (the flake input)
  # rather than from a separate channel, and install user packages into the
  # system profile. Both are what you want when home-manager runs as a NixOS
  # module, and they keep a fresh clone from needing any channel at all.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Rename pre-existing dotfiles instead of failing the activation. Without
  # this, the first rebuild on a machine that already has e.g. ~/.config/fish
  # aborts partway through.
  home-manager.backupFileExtension = "hm-backup";

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
