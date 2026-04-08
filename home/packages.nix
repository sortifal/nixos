{ pkgs, ... }:

{
  home.packages = with pkgs; [
  ];

  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox.override {
        cfg = {
          smartcardSupport = true;
        };
      };
    };
  };
}
