{ lib, pkgs, config, ...}:
let
  inherit (lib) attrValues mkIf;
  inherit (lib.cauldron) hasProfile;
in {
  config = mkIf (hasProfile "graphical" config) {
    fonts.packages = attrValues {
      inherit (pkgs)
        corefonts
        
        source-sans
        source-serif
        
        dejavu_fonts
        inter
        
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        
        # Emoji
        noto-fonts-color-emoji
        material-icons
        material-design-icons
        ;
      inherit (pkgs.nerd-fonts) symbols-only;
    };
  };
}
