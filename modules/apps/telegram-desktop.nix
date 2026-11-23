{ den, ... }:
{
  den.aspects.apps.telegram-desktop = {
    meta.description = "Telegram Desktop, installed per user through hjem";

    # Per-user install: lands in hjem.users.<name>.packages
    hjem = { pkgs, ... }: {
      packages = [ pkgs.telegram-desktop ];

      # Optional: pre-create Telegram's state directory (~/.local/share/TelegramDesktop)
      # files.".local/share/TelegramDesktop".type = "directory";
    };

    # Optional: keep configs you actually want to manage declaratively
    # hjem.xdg.config.files."telegram-desktop/shortcuts" = {
    #   source = ./files/telegram-shortcuts;
    # };
  };
}
