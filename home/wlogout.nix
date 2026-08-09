# Logout overlay bound to SUPER+Escape (and the Waybar power button).
{ pkgs, ... }:

let
  icons = "${pkgs.wlogout}/share/wlogout/icons";
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      { label = "lock"; action = "hyprlock"; text = "Lock"; keybind = "l"; }
      { label = "hibernate"; action = "systemctl hibernate"; text = "Hibernate"; keybind = "h"; }
      { label = "logout"; action = "loginctl terminate-user $USER"; text = "Logout"; keybind = "e"; }
      { label = "shutdown"; action = "systemctl poweroff"; text = "Shutdown"; keybind = "s"; }
      { label = "suspend"; action = "systemctl suspend"; text = "Suspend"; keybind = "u"; }
      { label = "reboot"; action = "systemctl reboot"; text = "Reboot"; keybind = "r"; }
    ];

    # Upstream ships its own PNGs under ~/.config/wlogout/icons; these are the
    # equivalents from the wlogout package itself.
    style = ''
      * {
        background-image: none;
      }

      window {
        background-color: rgba(36, 39, 58, 0.7);
      }

      button {
        margin: 8px;
        color: #cad3f5;
        background-color: #363a4f;
        border-radius: 20px;
        border-style: solid;
        border-width: 2px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }

      button:active,
      button:focus,
      button:hover {
        color: #8bd5ca;
        background-color: #24273a;
        outline-style: none;
      }

      #lock {
        background-image: image(url("${icons}/lock.png"));
      }

      #logout {
        background-image: image(url("${icons}/logout.png"));
      }

      #suspend {
        background-image: image(url("${icons}/suspend.png"));
      }

      #hibernate {
        background-image: image(url("${icons}/hibernate.png"));
      }

      #shutdown {
        background-image: image(url("${icons}/shutdown.png"));
      }

      #reboot {
        background-image: image(url("${icons}/reboot.png"));
      }
    '';
  };
}
