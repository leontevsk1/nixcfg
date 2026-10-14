{ ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    # Thunar — второй файловый менеджер после yazi (GUI). Конфиг:
    # custom actions — hyprdev/config/Thunar/uca.xml, терминал/дефолты —
    # hyprdev/config/xfce4/helpers.rc, каналы xfconf — hyprdev/config/xfce4/xfconf.
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin # контекстное меню архивов (бэкенд — file-roller)
        thunar-volman # автомонтирование съёмных носителей
        thunar-media-tags-plugin # массовое переименование + аудиотеги
      ];
    };

    programs.xfconf.enable = true; # без xfconfd настройки Thunar не сохраняются
    services.gvfs.enable = true; # trash://, MTP, сеть, монтирование через udisks2
    services.tumbler.enable = true; # thumbnails (картинки из коробки, видео — ffmpegthumbnailer)

    environment.systemPackages = with pkgs; [
      file-roller # бэкенд thunar-archive-plugin
      ffmpegthumbnailer # video-thumbnails для tumbler
      papirus-folders # перекраска папок Papirus (уже применено: grey, локальная копия в ~/.local/share/icons)
    ];
  };
}
