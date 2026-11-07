{ ... }:
{
  # Визуал XFCE для forge по образцу mehedirm6244/Miserable_Xfce:
  # GTK/xfwm4-темы, иконки, шрифт, picom с анимациями, docklike-панель.
  # Настройки xfconf, picom.conf и автозапуск — в ~/hyprdev (config/xfce4, apply-rice.sh).
  flake.nixosModules.xfceRice =
    { pkgs, ... }:
    let
      # Темы из репозитория-образца (в nixpkgs lavanda-gtk-theme удалён)
      miserableThemes = pkgs.stdenvNoCC.mkDerivation {
        pname = "miserable-xfce-themes";
        version = "0-unstable-2026-serenade";
        src = pkgs.fetchFromGitHub {
          owner = "mehedirm6244";
          repo = "Miserable_Xfce";
          rev = "e8c107cf46fcc271413abc006daad40e9fbcd5dc";
          sha256 = "0acjrnxk0gz50jln9icc95cr9070ca658zrg85vcf80lg38znsh8";
        };
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/themes
          cp -r home/.themes/Lavanda-Dark-Compact-Tokyonight $out/share/themes/
          cp -r home/.themes/cirkles $out/share/themes/
          mkdir -p $out/share/backgrounds/miserable
          cp home/.local/share/backgrounds/* $out/share/backgrounds/miserable/
          runHook postInstall
        '';
      };
    in
    {
      environment.systemPackages = with pkgs; [
        miserableThemes
        tokyonight-gtk-theme
        tela-circle-icon-theme
        picom-pijulius
        rofi
        bibata-cursors
        # терминальный стек как на tecno (без dev-инструментов)
        zsh
        eza
        bat
        fzf
        fd
        ripgrep
        zoxide
        starship
        fastfetch
        yazi
        # утилиты для горячих клавиш (аналоги niri-биндов)
        xdotool
        wmctrl
        xclip
        xcolor # пипетка (Mod+Shift+Alt+C в niri)
        tesseract # OCR области экрана (Mod+Shift+T в niri)
        playerctl
        brightnessctl
        xfce4-docklike-plugin
        xfce4-pulseaudio-plugin
        xfce4-notifyd
        scrot # скриншоты для проверки по ssh
        xauth
        xrdb
      ];

      # обои доступны как /run/current-system/sw/share/backgrounds/miserable/*.png
      environment.pathsToLink = [ "/share/backgrounds" ];

      # Шрифты: Inter для интерфейса, JetBrainsMono Nerd Font для терминала,
      # полный набор для веба (Firefox/Chromium): serif, CJK, emoji, MS-метрики
      fonts.packages = with pkgs; [
        inter
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        corefonts
        font-awesome
      ];
      fonts.fontconfig = {
        enable = true;
        antialias = true;
        hinting = {
          enable = true;
          style = "slight";
        };
        subpixel.lcdfilter = "default";
        defaultFonts = {
          sansSerif = [ "Inter" "Noto Sans CJK SC" ];
          serif = [ "Noto Serif" "Noto Serif CJK SC" ];
          monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      # alacritty вместо xfce4-terminal
      environment.xfce.excludePackages = [ pkgs.xfce4-terminal ];
    };
}
