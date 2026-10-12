{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    # Keep the legacy path; the new XDG default needs a manual profile move.
    configPath = ".mozilla/firefox";
    package = pkgs.firefox.override {
      cfg = {
        smartcardSupport = true;
      };
    };
  };
}
