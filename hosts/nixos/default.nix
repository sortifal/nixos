# System configuration for the `nixos` host: a Hyprland (Wayland) desktop on an
# AMD laptop. Everything host-specific lives here and in
# ./hardware-configuration.nix; the user environment is in ../../home.
# See ../../README.md for how to build this on a new machine.

{ config, lib, pkgs, inputs, ... }:

let
  # Pull individual packages from nixpkgs-unstable while the rest of the
  # system stays on the stable release. The unstable tree is a flake input
  # (see flake.nix), so a fresh clone needs no `nix-channel` setup at all.
  # allowUnfree is inherited so unfree packages (claude-code) resolve here too.
  unstable = import inputs.nixpkgs-unstable {
    inherit (config.nixpkgs) config;
    inherit (pkgs) system;
  };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.forticlient-nixos.nixosModules.forticlient
    ../../home-manager.nix
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

  # Networking. The hostname is what selects this host out of flake.nix:
  #   sudo nixos-rebuild switch --flake /etc/nixos#nixos
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # This configuration is a flake, so the nix that rebuilds it needs the flake
  # commands available. Without this the very first build on a new machine has
  # to pass --extra-experimental-features by hand (see README).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # FortiClient VPN. The gnome-keyring is unlocked at login through PAM; this
  # host logs in via greetd, so that is the PAM service to hook.
  services.forticlient.enable = true;
  services.forticlient.gnomeKeyring.pamServices = [ "login" "greetd" ];

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
  #
  # It deliberately points at sessionData.desktops rather than at
  # /run/current-system/sw/share/wayland-sessions. With withUWSM enabled,
  # nixpkgs puts only the UWSM entry in sessionPackages, but the *plain*
  # hyprland.desktop still shows up under /run/current-system/sw because the
  # Hyprland package is in systemPackages. Listing that directory would offer
  # a non-UWSM session and bring the "not started with UWSM" warning back.
  #
  # --cmd is the fallback when nothing has been remembered yet; without it
  # tuigreet authenticates fine and then fails with "no command configured".
  # It mirrors the Exec line of hyprland-uwsm.desktop. A selected session
  # still takes priority over it.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = lib.concatStringsSep " " [
        "${pkgs.greetd.tuigreet}/bin/tuigreet"
        "--time"
        "--remember"
        "--remember-session"
        "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        "--cmd 'uwsm start -F -- /run/current-system/sw/bin/Hyprland'"
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

    # Hyprland warns on startup when it is not launched under UWSM. UWSM wraps
    # the compositor in systemd units and starts graphical-session-pre.target,
    # graphical-session.target and xdg-desktop-autostart.target itself, which
    # Hyprland does not do on its own.
    #
    # This pairs with wayland.windowManager.hyprland.systemd.enable = false in
    # home/hyprland.nix - both of them activating the session would be a
    # double-activation. See the comment there.
    withUWSM = true;
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
    # WLR_NO_HARDWARE_CURSORS used to be set here. It is a wlroots variable and
    # Hyprland has not used wlroots since 0.42 (it renders through aquamarine
    # now), so it was a no-op. If software cursors are ever needed on this iGPU
    # the current equivalent is `cursor { no_hardware_cursors = true }` in the
    # Hyprland config.
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

  # The ALC257's `Capture` switch comes up off after boot. The card's UCM
  # profile ("HiFi (Mic1, Mic2, Speaker)") never enables it, and WirePlumber
  # won't either — its saved Mic1 route already reads mute:false / vol 1.0,
  # so wpctl, pamixer and the waybar module all report an unmuted mic while
  # the hardware switch underneath is cutting the signal. Force it on at boot.
  # Card index/id both shuffle, so match on the control instead.
  systemd.services.alsa-capture-unmute = {
    description = "Enable the ALSA capture switch on the analog mic";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for c in /proc/asound/card[0-9]*; do
        n=''${c#/proc/asound/card}
        ${pkgs.alsa-utils}/bin/amixer -c "$n" sset Capture 75% cap 2>/dev/null || true
        ${pkgs.alsa-utils}/bin/amixer -c "$n" sset "Mic Boost" 1 2>/dev/null || true
      done
    '';
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
    # Only applied when the account is first created, i.e. on a fresh install.
    # Change it with `passwd` after the first login - this repo is public.
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

  # claude-code and forticlient are unfree. Allow them by name rather than
  # setting allowUnfree globally, so anything else unfree still has to be
  # opted in. This predicate is shared with the unstable import above via
  # config.nixpkgs.
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [ "claude-code" "forticlient" ];

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
    bluetuith    # TUI bluetooth manager
    alsa-utils   # amixer/arecord — the layer pamixer and wpctl can't see
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
    unstable.claude-code # latest version from nixpkgs-unstable
    starship
    yubikey-manager
    yubioath-flutter
    teams-for-linux # unofficial Microsoft Teams client (Electron wrapper)

    # WireGuard: the kernel module ships with the kernel, so only the
    # userspace tooling (wg, wg-quick) is needed. Tunnels are managed either
    # through NetworkManager (import a .conf via nmcli/the applet) or with
    # `sudo wg-quick up <conf>` for a plain config file.
    wireguard-tools

    # Hyprland session support
    polkit_gnome
    qt6.qtwayland
  ];

  system.stateVersion = "25.11";
}
