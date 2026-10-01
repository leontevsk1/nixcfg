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
        self.nixosModules.commonConfiguration
        self.nixosModules.forgeHardware
      ];
      # UEFI Shell — нужен для поиска device handle Windows ESP
      # (boot.loader.systemd-boot.windows.*.efiDeviceHandle)
      boot.loader.systemd-boot.edk2-uefi-shell.enable = true;

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

      # Set your time zone.
      time.timeZone = "Asia/Barnaul";

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

      # Enable touchpad support (enabled default in most desktopManager).
      # services.libinput.enable = true;

      programs.firefox.enable = true;
      programs.throne.enable = true;

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
      ];

      # Windows: ESP на отдельном диске (sda3, PARTUUID 7b703be6-...),
      # авто-детект systemd-boot не сработает. Handle ищется в UEFI Shell:
      #   map -c  →  ls HD?c?:\EFI  →  наличие каталога Microsoft.
      # После нахождения — раскомментировать и вписать handle:
      # boot.loader.systemd-boot.windows."10".efiDeviceHandle = "HD0c3";

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # НЕ менять после установки — см. https://nixos.org/manual/nixos/stable/#sec-upgrading
      system.stateVersion = "26.05";

    };
}
