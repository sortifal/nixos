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
  # Newest mainline is a recurring source of amdgpu hangs on iGPUs. Less
  # likely now that the fault is known to be login-time only, but if the
  # black screen somehow survives the greetd change, swap this for the
  # default LTS kernel as the next single-variable test:
  #   boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Amsterdam";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Display manager: greetd + tuigreet.
  #
  # SDDM was tried with both greeter backends and black-screened either way.
  # The failure is specifically the DRM master handoff at login: the greeter's
  # compositor holds master and Hyprland cannot take it. Confirmed by the fact
  # that the black screen only ever happens *after* login, and that launching
  # Hyprland by hand from a TTY works every time - so the driver, the kernel
  # and the compositor are all fine.
  #
  # tuigreet removes the whole class of problem: it is a terminal UI on a
  # plain VT, so it never becomes DRM master and there is nothing to hand
  # over. Hyprland is the first and only thing to touch the display.
  #
  # --sessions is required on NixOS: tuigreet's built-in defaults point at
  # /usr/share/{wayland-sessions,xsessions}, which do not exist here.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = lib.concatStringsSep " " [
        "${pkgs.greetd.tuigreet}/bin/tuigreet"
        "--time"
        "--remember"
        "--remember-session"
        "--sessions /run/current-system/sw/share/wayland-sessions"
      ];
      user = "greeter";
    };
  };

  # No X server at all now that SDDM is gone. Hyprland's Xwayland does not
  # need services.xserver.enable, and keeping an unused X server around only
  # adds another process that can contend for the GPU.

  # AMD iGPU (e.g. Ryzen 4000/5000 "Renoir/Cezanne" Vega graphics): load
  # amdgpu during initrd so KMS is active before anything tries to draw.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Hyprland (Wayland)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;

    # UWSM puts the session under systemd and is what the upstream config
    # this repo tracks uses. Deliberately left off for now so that greetd is
    # the only change being tested. To turn it on later: set this to true and
    # set wayland.windowManager.hyprland.systemd.enable = false in
    # home/hyprland.nix (UWSM manages the session target itself, so both
    # doing it would double-activate). tuigreet will then offer
    # "hyprland-uwsm" alongside "hyprland" in its session list.
    # withUWSM = true;
  };

  # hyprlock authenticates against PAM, which needs a system-level service
  # entry; the lock screen itself is configured in home/hyprland-services.nix.
  programs.hyprlock.enable = true;

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
    # NOTE: this is a wlroots variable and Hyprland has not used wlroots
    # since 0.42 (it renders through aquamarine now), so it is a no-op here
    # and never had anything to do with the black screen. Kept only because
    # it is harmless; the current equivalent, if software cursors are ever
    # needed on this iGPU, is `cursor { no_hardware_cursors = true }` in the
    # Hyprland config.
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

  # Bluetooth - the Waybar bluetooth module, the blueman applet and the
  # SUPER+SHIFT+Y toggle all need the stack actually running.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  # Catppuccin Macchiato in the TTY, to match the desktop theme.
  console = {
    earlySetup = true;
    colors = [
      "24273a"
      "ed8796"
      "a6da95"
      "eed49f"
      "8aadf4"
      "f5bde6"
      "8bd5ca"
      "cad3f5"
      "5b6078"
      "ed8796"
      "a6da95"
      "eed49f"
      "8aadf4"
      "f5bde6"
      "8bd5ca"
      "a5adcb"
    ];
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      # Waybar's CSS falls back to these for the glyphs and emoji in its
      # module formats.
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
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
