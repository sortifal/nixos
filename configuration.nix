# Basic NixOS configuration
# Hyprland setup with Home Manager

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  networking.extraHosts = ''
    127.0.0.1 sos-ch-dk-2.example.com
  '';

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

  # Power management
  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # YubiKey
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="dialout"
  '';
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
     extraGroups = [ "networkmanager" "wheel" "audio" "video" "plugdev" "docker" "dialout" ];
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

	environment.variables = {
	  CGO_CFLAGS = "-I${pkgs.foundationdb.dev}/include";
	  CGO_LDFLAGS = "-L${pkgs.foundationdb.lib}/lib";
	};

  # System packages
  environment.systemPackages = with pkgs; [
    (pkgs.stdenv.mkDerivation {
      name = "pixie-sddm";
      src = pkgs.fetchFromGitHub {
        owner = "xCaptaiN09";
        repo = "pixie-sddm";
        rev = "main";
        sha256 = "sha256-1PDWX8bJfc0HYMW9MsxWwDXDoYy5aaehUWr7FW3yR9U=";
      };
      buildInputs = [ pkgs.qt6.qtdeclarative pkgs.qt6.qtsvg ];
      dontWrapQtApps = true;
      installPhase = ''
        mkdir -p $out/share/sddm/themes/pixie
        cp -r * $out/share/sddm/themes/pixie/
      '';
    })
    (pkgs.stdenv.mkDerivation {
  	name = "exoscale-cli-1.95.1";
	src = pkgs.fetchurl {
	    url = "https://github.com/exoscale/cli/releases/download/v1.95.1/exoscale-cli_1.95.1_linux_amd64.tar.gz";
	    sha256 = "16cd973d5baa90894f038bb53e42c0b026b047fd59ed98fd59a57f948a277e87";
	  };
	  sourceRoot = ".";
	  installPhase = "mkdir -p $out/bin && mv exo $out/bin/";
    })
    orca-slicer
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
    claude-code
    google-chrome
    spotify
    go
    gcc
    foundationdb
    foundationdb.dev
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
    podman
    awscli2
    jq
    gh	
    platformio
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;
  system.stateVersion = "25.11";
}
