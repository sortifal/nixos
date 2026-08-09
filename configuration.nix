# Basic NixOS configuration
# Simple setup for Hyprland, alacritty, and vim

{ config, lib, pkgs, ... }:

{
  imports =
    [ <home-manager/nixos>
      ./home-manager.nix
    ];

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

  # Display manager: SDDM reliably launches Wayland sessions, unlike lightdm.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Hyprland (Wayland)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  hardware.graphics.enable = true;

  security.polkit.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Input devices
  services.libinput.enable = true;

  # YubiKey
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  hardware.gpgSmartcards.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "plugdev" ];
    shell = pkgs.fish;
    initialPassword = "pass";
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrains Mono" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    alacritty
    git
    wget
    brightnessctl
    pamixer
    networkmanagerapplet
    blueman
    pavucontrol
    htop
    tree
    unzip
    ripgrep
    fd
    ranger
    imagemagick
    conky
    opencode
    starship
    yubikey-manager
    yubioath-flutter

    # Hyprland session support
    polkit_gnome
    qt6.qtwayland
  ];

  system.stateVersion = "25.11";
}
