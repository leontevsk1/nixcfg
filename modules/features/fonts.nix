{ ... }: {
  # Шрифты, общие для всех хостов: Inter — интерфейс, JetBrainsMono Nerd Font — терминал.
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.fontconfig.enable = true;

    fonts.packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
      # Глифы для статус-баров/интерфейсов (Noctalia, nvim, starship):
      nerd-fonts.symbols-only # Nerd Icons
      material-symbols # Material Symbols
      material-design-icons # Material Design Icons (MDI)
      font-awesome # Font Awesome 7
      corefonts # MS-метрики для веба и документов
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ "Inter" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
