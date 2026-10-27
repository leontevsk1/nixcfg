{ ... }: {
  flake.nixosModules.commonConfiguration =
    { pkgs, ... }:

    let
      plymouthLogo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png";

      plymouthTheme = pkgs.runCommand "plymouth-nixos-progress" { } ''
        mkdir -p $out/share/plymouth/themes/nixos-progress
        cp ${pkgs.plymouth}/share/plymouth/themes/script/progress_box.png $out/share/plymouth/themes/nixos-progress/
        cp ${pkgs.plymouth}/share/plymouth/themes/script/progress_bar.png $out/share/plymouth/themes/nixos-progress/
        cp ${./plymouth/nixos-progress.script} $out/share/plymouth/themes/nixos-progress/nixos-progress.script
        substitute ${./plymouth/nixos-progress.plymouth} $out/share/plymouth/themes/nixos-progress/nixos-progress.plymouth \
          --replace-fail '@themeDir@' "$out/share/plymouth/themes/nixos-progress"
      '';
    in
    {
      # systemd-boot: общая база (специфичные опции хоста дописываются поверх)
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Максимум 5 последних поколений в меню загрузки
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.loader.timeout = 0;

      # Сборка мусора: ежедневно удалять всё, кроме 5 последних поколений
      nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-generations +5";
      };
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Use latest Zen kernel.
      boot.kernelPackages = pkgs.linuxPackages_zen;

      boot.plymouth = {
        enable = true;
        theme = "nixos-progress";
        logo = plymouthLogo;
        themePackages = [ plymouthTheme ];
      };

      # Enable networking
      networking.networkmanager.enable = true;

      # IPv6 отключён на обеих машинах (политика)
      networking.enableIPv6 = false;
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "ipv6.disable=1"
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ru_RU.UTF-8";
        LC_IDENTIFICATION = "ru_RU.UTF-8";
        LC_MEASUREMENT = "ru_RU.UTF-8";
        LC_MONETARY = "ru_RU.UTF-8";
        LC_NAME = "ru_RU.UTF-8";
        LC_NUMERIC = "ru_RU.UTF-8";
        LC_PAPER = "ru_RU.UTF-8";
        LC_TELEPHONE = "ru_RU.UTF-8";
        LC_TIME = "ru_RU.UTF-8";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.leont = {
        isNormalUser = true;
        description = "leont";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };

      programs.zsh.enable = true;
      programs.zsh.shellInit = ''
        # radleylewis/zsh expects its config in XDG_CONFIG_HOME/zsh
        export ZDOTDIR="$HOME/.config/zsh"
      '';

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;
      };

      # OpenSSH — централизованное управление машинами из репо
      services.openssh.enable = true;
    };
}
