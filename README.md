# nixos

NixOS + home-manager configuration for a Hyprland (Wayland) desktop, themed
Catppuccin Macchiato throughout.

Everything is declared in this repo and pinned by `flake.lock`, so a clone
builds the same closure on any machine — no `nix-channel` setup.

## Layout

```
flake.nix                 inputs (nixpkgs 26.05, nixpkgs-unstable, home-manager)
flake.lock                exact input revisions — commit every change to it
hosts/
  nixos/
    default.nix           system config for the host named `nixos`
home-manager.nix          home-manager wiring + the list of user modules
home/                     the user environment, one file per program
wallpaper.jpg             installed to ~/Pictures and used by hyprpaper/hyprlock
```

`hosts/<hostname>/` is the only machine-specific part. Everything under
`home/` and `home-manager.nix` is shared.

## Rebuild on this machine

```sh
sudo nixos-rebuild switch --impure --flake /etc/nixos#nixos
```

`--impure` is needed because the machine's `hardware-configuration.nix` is not
in this repo; it is imported from `/etc/nixos/hardware-configuration.nix`.

The flake only sees files git knows about, so `git add` a new file *before*
rebuilding or Nix will report it as missing. The exception is the git-ignored
`hardware-configuration.nix`, which git-based flake refs skip entirely, so
build with `path:` instead (as below).

Update the pinned inputs:

```sh
nix flake update                  # all inputs
nix flake update nixpkgs-unstable # just one
sudo nixos-rebuild switch --flake path:/etc/nixos#nixos
```

## Set up on a new machine

1. Install NixOS normally (any ISO of the release in `flake.nix`).

2. Clone this repo and keep the generated hardware config:

   ```sh
   sudo mv /etc/nixos /etc/nixos.orig
   sudo git clone <this-repo> /etc/nixos
   sudo cp /etc/nixos.orig/hardware-configuration.nix /etc/nixos/
   ```

   The file is gitignored and stays local to the machine.

3. Add the new host. Pick a hostname, then:

   ```sh
   HOST=laptop2
   sudo mkdir -p /etc/nixos/hosts/$HOST
   sudo cp /etc/nixos/hosts/nixos/default.nix /etc/nixos/hosts/$HOST/
   ```

   Edit `hosts/$HOST/default.nix` and set `networking.hostName = "$HOST";`,
   then register it in `flake.nix`:

   ```nix
   nixosConfigurations = {
     nixos = mkHost { hostname = "nixos"; };
     laptop2 = mkHost { hostname = "laptop2"; };
   };
   ```

   Reusing the existing hostname instead? Skip this step.

4. Commit, since the flake reads from git (the git-ignored hardware config is
   picked up by the `path:` ref in the next step):

   ```sh
   sudo git add -A && sudo git commit -m "Add host $HOST"
   ```

5. Build. Flakes are enabled *by* this config, so the first build on a stock
   installer has to ask for them explicitly:

   ```sh
   sudo nixos-rebuild switch \
     --impure \
     --extra-experimental-features 'nix-command flakes' \
     --flake path:/etc/nixos#$HOST
   ```

   Later rebuilds need only `sudo nixos-rebuild switch --flake path:/etc/nixos#$HOST`.

6. Log in as `sorti` with the password from `initialPassword` and change it
   with `passwd`. The home-manager generation activates on first login;
   pre-existing dotfiles are moved aside as `*.hm-backup`.

## Notes

- **Unstable packages.** `hosts/nixos/default.nix` binds `unstable` to the
  `nixpkgs-unstable` input, so a single package can run ahead of the release
  (`unstable.claude-code`) while the rest of the system stays on 26.05.
- **Unfree.** Allowed by name via `allowUnfreePredicate`, not globally; add to
  that list to permit another unfree package.
- **Transparency** is terminal-only: windows are opaque by default and the
  `opacity` windowrules in `home/hyprland.nix` opt alacritty in. Waybar, rofi
  and the lock screen set their own alpha in their own CSS.
- **Display manager** is greetd + tuigreet on a plain VT; the comment in
  `hosts/nixos/default.nix` explains why not SDDM.
- **Hyprland** runs under UWSM, which is why home-manager's
  `wayland.windowManager.hyprland.systemd.enable` is off.
