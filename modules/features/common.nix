{ ... }: {
  flake.nixosModules.commonConfiguration =
    { pkgs, ... }:

    {
      # systemd-boot: общая база (специфичные опции хоста дописываются поверх)
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Максимум 5 последних поколений в меню загрузки
      boot.loader.systemd-boot.configurationLimit = 5;

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

      # Enable networking
      networking.networkmanager.enable = true;

      # IPv6 отключён на обеих машинах (политика)
      networking.enableIPv6 = false;
      boot.kernelParams = [ "ipv6.disable=1" ];

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
