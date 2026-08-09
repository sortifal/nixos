# Helper scripts used by the Hyprland keybinds and the Waybar modules.
#
# The upstream config these are modelled on (XNM1/linux-nixos-hyprland-config-dotfiles)
# keeps this logic in ~/.config/fish/functions/*.fish. Shipping them as Nix-built
# scripts instead keeps the binds working regardless of which shell is running and
# pins every tool they call to the store.
{ pkgs }:

let
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  rofi = "${pkgs.rofi}/bin/rofi";
  notify = "${pkgs.libnotify}/bin/notify-send";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pkill = "${pkgs.procps}/bin/pkill";
  rfkill = "${pkgs.util-linux}/bin/rfkill";
in
{
  screenshotToClipboard = pkgs.writeShellScriptBin "screenshot-to-clipboard" ''
    set -eu
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/screenshot-$(date +%Y-%m-%d--%H-%M-%S).png"
    ${grim} -g "$(${slurp})" "$file"
    ${wlCopy} --type image/png < "$file"
    ${notify} -i "$file" -t 2000 Screenshots "Screenshot was taken"
  '';

  # Opens the most recent screenshot in swappy for annotation.
  screenshotEdit = pkgs.writeShellScriptBin "screenshot-edit" ''
    set -eu
    dir="$HOME/Pictures/Screenshots"
    latest=$(ls -1t "$dir" 2>/dev/null | head -n1 || true)
    if [ -z "$latest" ]; then
      ${notify} -t 2000 Screenshots "No screenshot to edit"
      exit 0
    fi
    exec ${pkgs.swappy}/bin/swappy -f "$dir/$latest"
  '';

  # Both recorders are toggles: a second press SIGINTs wl-screenrec, which makes
  # it finalise the file instead of leaving a truncated one behind.
  recordScreenMp4 = pkgs.writeShellScriptBin "record-screen-mp4" ''
    set -eu
    if ${pgrep} -x wl-screenrec > /dev/null; then
      ${pkill} -INT -x wl-screenrec
      exit 0
    fi
    geometry=$(${slurp}) || exit 0
    [ -n "$geometry" ] || exit 0
    dir="$HOME/Videos/Records"
    mkdir -p "$dir"
    file="$dir/record-$(date +%Y-%m-%d--%H-%M-%S).mp4"
    ${notify} -t 2000 Recording "Started (MP4)"
    ${pkgs.wl-screenrec}/bin/wl-screenrec -g "$geometry" -f "$file"
    printf 'file://%s\n' "$file" | ${wlCopy} -t text/uri-list
    ${notify} -t 2000 Recording "Stopped (MP4)"
  '';

  recordScreenGif = pkgs.writeShellScriptBin "record-screen-gif" ''
    set -eu
    if ${pgrep} -x wl-screenrec > /dev/null; then
      ${pkill} -INT -x wl-screenrec
      exit 0
    fi
    geometry=$(${slurp}) || exit 0
    [ -n "$geometry" ] || exit 0
    dir="$HOME/Pictures/Records"
    mkdir -p "$dir"
    name="record-$(date +%Y-%m-%d--%H-%M-%S)"
    ${notify} -t 2000 Recording "Started (GIF)"
    ${pkgs.wl-screenrec}/bin/wl-screenrec -g "$geometry" \
      -f "$dir/$name.mp4" --encode-resolution 1920x1080
    ${pkgs.ffmpeg}/bin/ffmpeg -loglevel error -i "$dir/$name.mp4" "$dir/$name.gif"
    rm -f "$dir/$name.mp4"
    printf 'file://%s\n' "$dir/$name.gif" | ${wlCopy} -t text/uri-list
    ${notify} -t 2000 Recording "Stopped (GIF)"
  '';

  clipboardToType = pkgs.writeShellScriptBin "clipboard-to-type" ''
    set -eu
    ${cliphist} list | ${rofi} -dmenu -p clipboard | ${cliphist} decode | ${pkgs.wtype}/bin/wtype -
  '';

  clipboardToClipboard = pkgs.writeShellScriptBin "clipboard-to-clipboard" ''
    set -eu
    clip=$(${cliphist} list | ${rofi} -dmenu -p 'clipboard copy')
    [ -n "$clip" ] || exit 0
    printf '%s\n' "$clip" | ${cliphist} decode | ${wlCopy}
    ${notify} -t 2000 Clipboard "Clip was copied"
  '';

  clipboardDeleteItem = pkgs.writeShellScriptBin "clipboard-delete-item" ''
    set -eu
    clip=$(${cliphist} list | ${rofi} -dmenu -p 'clipboard delete item')
    [ -n "$clip" ] || exit 0
    printf '%s\n' "$clip" | ${cliphist} delete
    ${notify} -t 2000 Clipboard "Clip was deleted"
  '';

  clipboardClear = pkgs.writeShellScriptBin "clipboard-clear" ''
    set -eu
    ${cliphist} wipe
    ${notify} -t 2000 Clipboard Cleared
  '';

  # wlogout has no single-instance guard of its own, so a held keybind would
  # stack several overlays on top of each other.
  wlogoutUnique = pkgs.writeShellScriptBin "wlogout-unique" ''
    ${pgrep} -x wlogout > /dev/null || exec ${pkgs.wlogout}/bin/wlogout
  '';

  # hyprsunset keeps running once started, so toggling means killing it.
  # The chosen temperature is remembered between toggles.
  nightModeToggle = pkgs.writeShellScriptBin "night-mode-toggle" ''
    set -eu
    temp_file="$HOME/.cache/hyprsunset_temp"
    if ${pgrep} -x hyprsunset > /dev/null; then
      ${pkill} -INT -x hyprsunset
      exit 0
    fi
    mkdir -p "$(dirname "$temp_file")"
    if [ ! -f "$temp_file" ]; then
      echo 4000 > "$temp_file"
    fi
    exec ${pkgs.hyprsunset}/bin/hyprsunset -t "$(cat "$temp_file")"
  '';

  wifiToggle = pkgs.writeShellScriptBin "wifi-toggle" ''
    exec ${rfkill} toggle wlan
  '';

  bluetoothToggle = pkgs.writeShellScriptBin "bluetooth-toggle" ''
    exec ${rfkill} toggle bluetooth
  '';

  airplaneModeToggle = pkgs.writeShellScriptBin "airplane-mode-toggle" ''
    exec ${rfkill} toggle all
  '';
}
