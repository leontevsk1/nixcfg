{ ... }: {
  # Throne (прокси-клиент, mixed-порт 127.0.0.1:2080) и всё, что нужно для System Proxy.
  flake.nixosModules.proxy = { pkgs, ... }: {
    programs.throne = {
      enable = true;
      tunMode.enable = true;
      # Optional: enable setuid if the default capabilities method fails
      # tunMode.setuid = true;
    };

    environment.systemPackages = with pkgs; [
      glib # gsettings CLI: Throne пишет системный прокси через gsettings (org.gnome.system.proxy), Firefox его читает
      gsettings-desktop-schemas # схемы org.gnome.*: без них gsettings падает с "No schemas installed"
    ];
    environment.pathsToLink = [ "/share/glib-2.0" ];
    programs.dconf.enable = true;
  };
}
