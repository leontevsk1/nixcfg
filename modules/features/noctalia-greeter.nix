{
  flake.nixosModules.noctaliaGreeter =
    { pkgs, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        # Обои, палитру, шрифт и раскладку мониторов greeter берёт у Noctalia
        # (Settings → Security → Noctalia Greeter, Auto-Sync включён).
        # Без этого списка каждая синхронизация просит пароль через polkit
        passwordlessSyncUsers = [ "leont" ];

        settings = {
          # Сразу шаг ввода пароля, без выбора пользователя и сессии
          user.default = "leont";
          session.default = "Niri";
          cursor.size = 16;
          keyboard.layout = "us";
        };

        cursorTheme = {
          package = pkgs.kdePackages.breeze;
          name = "breeze_cursors";
        };
      };
    };
}
