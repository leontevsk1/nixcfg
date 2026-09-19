{ self, inputs, ... }: {
    flake.nixosModules.tecnoConfiguration = { config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      self.nixosModules.tecnoHardware
      self.nixosModules.xfce
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "tecno"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Krasnoyarsk";

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

  # Создаем пользователя для греедера, если он еще не задан
  users.users.greeter = {
    isNormalUser = false;
    extraGroups = [ "seat" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command = let
          # Путь к директориям сессий (Wayland/X11), чтобы tuigreet видел ваши DE/WM
          sessionsDir = "${config.services.displayManager.sessionData.desktops}/share";
        in ''
          ${lib.getExe pkgs.tuigreet} \
            --time \
            --asterisks \
            --remember \
            --remember-user-session \
            --user-menu \
            --sessions ${sessionsDir}/wayland-sessions \
            --xsessions ${sessionsDir}/xsessions
        '';
      };
    };
  };
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
  services.libinput = {
  enable = true;
  touchpad = {
    tapping = true;          # Клик касанием (тап)
    naturalScrolling = true; # Инвертированная (природная) прокрутка
    disableWhileTyping = true; # Отключение тачпада при наборе текста
  };
};

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
  programs.throne.enable = true;
  programs.yazi.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty
    inputs.opencode-nix.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    git
  ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  environment.variables.TERMINAL = "kitty";
  
  fonts.fontconfig.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    inter
  ];

  fonts.fontconfig.defaultFonts.sansSerif = [ "Inter" ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

};
}
