{ self, inputs, ... }: {

  flake.nixosModules.forgeConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.forgeHardware
      ];
      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Максимум 5 последних поколений в меню загрузки
      boot.loader.systemd-boot.configurationLimit = 5;
      # UEFI Shell — нужен для поиска device handle Windows ESP
      # (boot.loader.systemd-boot.windows.*.efiDeviceHandle)
      boot.loader.systemd-boot.edk2-uefi-shell.enable = true;

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

      # GTX 970 (Maxwell): 580 — последняя ветка с поддержкой Maxwell,
      # open-модуля у неё нет, поэтому open = false (обязательно при >= 560).
      # hardware.nvidia.enabled выводится из videoDrivers, поэтому включаем через него.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        branch = "legacy_580";
        open = false;
        modesetting.enable = true;
      };

      # Steam/Proton: 32-bit библиотеки (GTX 970, DXVK/VKD3D)
      hardware.graphics.enable32Bit = true;
      programs.steam.enable = true;

      # Дискового swap нет (см. hardware-configuration) — zram вместо него
      zramSwap.enable = true;

      networking.hostName = "forge"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Barnaul";

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

      # Диск для данных/homelab (Seagate ST1000DM010, ext4) — метка data
      # даётся на машине: e2label /dev/disk/by-partuuid/4d0b263b-01 data
      fileSystems."/data" = {
        device = "/dev/disk/by-label/data";
        fsType = "ext4";
        options = [ "noatime" ];
      };

      # Enable the X11 windowing system.
      services.xserver.enable = true;

      # Enable the XFCE Desktop Environment.
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.desktopManager.xfce.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

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

      # Enable touchpad support (enabled default in most desktopManager).
      # services.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users."leont" = {
        isNormalUser = true;
        description = "leont";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
          #  thunderbird
        ];
      };

      # Install firefox.
      programs.firefox.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        curl
        git
        btop
        chromium
        alacritty
        throne
      ];

      # OpenSSH — централизованное управление машинами из репо (ssh leont@forge)
      services.openssh.enable = true;

      # Windows: ESP на отдельном диске (sda3, PARTUUID 7b703be6-...),
      # авто-детект systemd-boot не сработает. Handle ищется в UEFI Shell:
      #   map -c  →  ls HD?c?:\EFI  →  наличие каталога Microsoft.
      # После нахождения — раскомментировать и вписать handle:
      # boot.loader.systemd-boot.windows."10".efiDeviceHandle = "HD0c3";

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/#opt-system.stateVersion .
      system.stateVersion = "26.05"; # Did you read the comment?

    };
}
