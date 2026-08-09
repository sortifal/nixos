# Basic NixOS configuration
# Simple setup for Hyprland, alacritty, and vim

{ config, lib, pkgs, ... }:

{
  imports =
    [ <home-manager/nixos>
      ./home-manager.nix
      ./hardware-configuration.nix
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
  # This machine only has one GPU (AMD iGPU, no discrete GPU). Running the
  # SDDM *greeter* on Xorg (wayland.enable = false) was tried as a
  # workaround for a black screen, but on single-GPU hardware an Xorg
  # greeter frequently fails to release DRM master cleanly when handing off
  # to a Wayland session (Hyprland) - it worked fine when launched manually
  # from a TTY, which confirmed the driver/compositor were never the
  # problem. Keep the greeter itself on Wayland so DRM master hands off
  # cleanly to the Hyprland session. services.xserver.enable stays on since
  # SDDM/Xwayland still rely on it for Xkb config.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # AMD iGPU (e.g. Ryzen 4000/5000 "Renoir/Cezanne" Vega graphics): load
  # amdgpu during initrd so KMS is active before the display manager starts,
  # avoiding a boot/login handoff race that can show up as a black screen.
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

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
    # Common fix for "Hyprland starts but nothing draws" on AMD iGPUs where
    # the hardware cursor plane doesn't composite correctly.
    WLR_NO_HARDWARE_CURSORS = "1";
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
