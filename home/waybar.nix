{ pkgs, ... }:

let
  theme = ''
    @define-color rosewater      #c4d4b8;
    @define-color flamingo       #e57373;
    @define-color pink           #c084fc;
    @define-color mauve          #c084fc;
    @define-color red            #e57373;
    @define-color maroon         #e57373;
    @define-color peach          #f0e68c;
    @define-color yellow         #f0e68c;
    @define-color green          #4ade80;
    @define-color teal           #5eead4;
    @define-color sky            #7dd3fc;
    @define-color sapphire       #5eead4;
    @define-color blue           #7dd3fc;
    @define-color lavender       #c084fc;
    @define-color text           #c4d4b8;
    @define-color subtext1       #6b7b6b;
    @define-color subtext0       #6b7b6b;
    @define-color overlay2       #4a5a4a;
    @define-color overlay1       #3a4a3a;
    @define-color overlay0       #2a3a2a;
    @define-color surface2       #1a2a1a;
    @define-color surface1       #151f15;
    @define-color surface0       #101a10;
    @define-color base           #0a0e0a;
    @define-color mantle         #080c08;
    @define-color crust          #060a06;

    @define-color accent         #5eead4;
    @define-color main-br        #1a2a1a;
    @define-color main-bg        #060a06;
    @define-color main-fg        #c4d4b8;
    @define-color hover-bg       #0a0e0a;
    @define-color hover-fg       rgba(196, 212, 184, 0.75);
    @define-color outline        #040804;

    @define-color workspaces     #080c08;
    @define-color temperature    #080c08;
    @define-color memory         #0a0e0a;
    @define-color cpu            #101a10;
    @define-color time           #101a10;
    @define-color date           #0a0e0a;
    @define-color tray           #080c08;
    @define-color volume         #080c08;
    @define-color backlight      #0a0e0a;
    @define-color battery        #101a10;

    @define-color warning        #f0e68c;
    @define-color critical       #e57373;
    @define-color charging       #4ade80;
  '';

  mechabar = pkgs.stdenv.mkDerivation {
    name = "mechabar";
    src = pkgs.fetchFromGitHub {
      owner = "sortifal";
      repo = "mechabar";
      rev = "fix/v0.14.0";
      sha256 = "1gxyxify15if1ibf7k3wb1vp2vcn10s664qzg9qb87ydvx1shpqb";
    };
    dontWrapQtApps = true;
    installPhase = ''
      cp -r . $out
      echo '${theme}' > $out/theme.css
      chmod +x $out/scripts/*
    '';
  };
in
{
  xdg.configFile."waybar" = {
    source = mechabar;
    recursive = true;
  };
}
