# GTK / Qt / cursor theming to match the Catppuccin Macchiato + teal accent the
# upstream config uses everywhere.
{ pkgs, ... }:

let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ "teal" ];
    size = "standard";
    variant = "macchiato";
  };
in
{
  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-macchiato-teal-standard";
      package = catppuccinGtk;
    };

    # Numix-Circle is what rofi's `icon-theme` and Waybar's taskbar ask for.
    iconTheme = {
      name = "Numix-Circle";
      package = pkgs.numix-icon-theme-circle;
    };

    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  # catppuccin-cursors ships XCursor data only, so HYPRCURSOR_* is left unset
  # and Hyprland falls back to the XCursor theme.
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.macchiatoTeal;
    name = "catppuccin-macchiato-teal-cursors";
    size = 24;
    gtk.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.packages = [ pkgs.catppuccin-kvantum ];
}
