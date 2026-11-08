{ ... }: {
  # Терминальный стек, общий для всех хостов (конфиги — в дотфайлах hyprdev).
  flake.nixosModules.cliTools = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # yazi: БЕЗ programs.yazi модуля — он всегда экспортирует YAZI_CONFIG_HOME
    # в /nix/store, из-за чего ~/.config/yazi (дотфайлы hyprdev) игнорируется.
    # Чистый пакет читает ~/.config/yazi как обычно.
    environment.systemPackages = with pkgs; [
      kitty
      yazi
      eza
      bat
      fzf
      fd
      ripgrep
      zoxide # zsh: smart cd
      starship # zsh: prompt
      fastfetch
      btop
      lazygit
      git
      yadm # менеджер дотфайлов (XDG: ~/.config/yadm)
      wget
      curl
      jq
      psmisc # killall/pstree
      dnsutils
    ];

    environment.variables.TERMINAL = "kitty";
  };
}
