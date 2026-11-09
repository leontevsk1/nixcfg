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

           # Оставляем только необходимые элементы: логотип, выбор схемы
           # и кнопки питания скрыты.
           appearance.hide_logo = true;
           appearance.scheme = "Synced";
           appearance.scheme_selector_position = "hidden";
           appearance.power_buttons_position = "hidden";
           appearance.font_family = "Inter";

           # Часы крупнее значения по умолчанию (48 px).
           clock.enabled = true;
           clock.time_font_size = 72;
           clock.date_font_size = 18;

           # Пока greeter запущен, UI показывается только на дисплее ноутбука.
           # Имя подтверждено `noctalia-greeter outputs --details`.
           output.name = "eDP-1";
           output.use_synced_settings = true;

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
