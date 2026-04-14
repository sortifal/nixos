# Basic NixOS configuration
# Hyprland setup with Home Manager

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include results of hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
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

  # Display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "pixie";
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
    (pkgs.stdenv.mkDerivation {
      name = "pixie-sddm";
      src = pkgs.fetchFromGitHub {
        owner = "xCaptaiN09";
        repo = "pixie-sddm";
        rev = "main";
        sha256 = "09aixg5xphjfrdbh3ifqfp3wrmlxgdwsy5ndc1iv945pzhzxcj1n";
      };
      buildInputs = [ pkgs.qt6.qtdeclarative pkgs.qt6.qtsvg ];
      dontWrapQtApps = true;
      installPhase = ''
        mkdir -p $out/share/sddm/themes/pixie
        cp -r * $out/share/sddm/themes/pixie/
      '';
    })
    vim
    neovim
    vscode
    wireguard-tools
    gnumake
    clojure
    leiningen
    clj-kondo
    obsidian
    bluez
    bluetuith
    alacritty
    git
    wget
    dmenu
    ansible
    hyprland
    waybar
    wofi
    hyprpaper
    pamixer
    grim
    slurp
    swappy
    wl-clipboard
    brightnessctl
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
    neofetch
    opencode
    starship
    yubikey-manager
    yubioath-flutter
    docker
    podman
 ];

  system.stateVersion = "25.11";
}
