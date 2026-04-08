# Basic NixOS configuration
# Simple setup for Hyprland, alacritty, and vim

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include results of hardware scan.
      ./hardware-configuration.nix
	<home-manager/nixos>
    ];
  
  # Home Manager setup
  home-manager = {
    users.sorti = { pkgs, ... }: {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$terminal" = "alacritty";
        };
      };
      home.stateVersion = "25.11";
    };
  };

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Amsterdam";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Hyprland (Wayland)
  programs.hyprland.enable = true;
  services.displayManager.gdm.enable = true;

  # Input devices
  services.libinput.enable = true;

  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Fish shell
  programs.fish.enable = true;

  # User account
  users.users.sorti = {
     description = "Sorti-";
     isNormalUser = true;
     extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
     shell = pkgs.fish;
     initialPassword = "pass";
   };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    alacritty
    git
    wget
    firefox
    hyprland
    waybar
    rofi
    wlogout
    swww
    slurp
    grim
    brightnessctl
    pamixer
    networkmanagerapplet
    blueman
    htop
    tree
    unzip
    ripgrep
    fd
    ranger
    imagemagick
    conky
    opencode
    libfido2
    yubikey-manager
  ];
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  system.stateVersion = "25.11";
}
