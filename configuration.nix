# Basic NixOS configuration
# Simple setup for i3, Hyprland, alacritty, and vim
#
# This repo intentionally omits hardware-configuration.nix, since it is
# machine-specific and generated locally. Run `nixos-generate-config` on
# the target machine to produce one, then import it above.

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

  # X11 and i3
  services.xserver.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    configFile = /etc/nixos/i3.conf;
  };

  # Display manager: SDDM shows both the X11 (i3) and Wayland (Hyprland)
  # sessions, unlike lightdm which does not reliably launch Wayland sessions.
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
    i3
    i3status
    i3lock
    dmenu
    picom
    rofi
    nitrogen
    feh
    scrot
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
