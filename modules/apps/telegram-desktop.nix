{ den, ... }:
{
  den.aspects.apps.telegram-desktop = {
    meta.description = "Telegram Desktop, installed system wide";

    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.telegram-desktop ];

      # Optional: pre-create Telegram's state directory (~/.local/share/TelegramDesktop)
      # files.".local/share/TelegramDesktop".type = "directory";
    };

    # Optional: keep configs you actually want to manage declaratively
    # hjem.xdg.config.files."telegram-desktop/shortcuts" = {
    #   source = ./files/telegram-shortcuts;
    # };
  };
}
