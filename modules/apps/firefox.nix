# modules/apps/firefox.nix
{ den, ... }:

let
  # id -> AMO slug.  Take the IDs from your old module (`about:addons` shows
  # them) or from the AMO listing URL.
  addons = {
    "support@lastpass.com" = "force_installed";
    "search@kagi.com" = "force_installed";
    "jid1-MnnxcxisBPnSXQ@jetpack" = "force_installed";
    "enhancerforyoutube@maximerf.addons.mozilla.org" = "force_installed";
  };

  prefs = {
    "browser.aboutwelcome.enabled"                     = false;
    "browser.aboutConfig.showWarning"                  = false;
    "browser.meta_refresh_when_inactive.disabled"      = true;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored"    = false;
    "browser.bookmarks.showMobileBookmarks"            = true;
    "browser.ssb.enabled"                              = true;
    # needed or userChrome.css is silently ignored
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "widget.use-xdg-desktop-portal.file-picker"        = 1;
  };
in
{
  den.aspects.apps.firefox.nixos = { pkgs, ... }: {
    programs.firefox = {
      enable  = true;
      package = pkgs.firefox;          # or pkgs.firefox-esr — see note 4

      # prefs are written to an autoconfig file instead of policies.Preferences,
      # so they apply to every profile and are locked against about:config edits
      preferencesStatus = "locked";
      preferences = prefs;

      # browserpass manifest, installed system-wide; no ~/.mozilla files needed
      nativeMessagingHosts.packages = [ pkgs.browserpass ];

      policies = {
        DisableTelemetry        = true;
        DisableFirefoxStudies   = true;
        DisablePocket           = true;
        DisableFormHistory      = true;
        DontCheckDefaultBrowser = true;
        DisplayMenuBar          = "never";
        OfferToSaveLogins       = false;
        PasswordManagerEnabled  = false;

        SearchEngines = {
          Default = "Kagi";
          Add = [{
            Name        = "Kagi";
            Alias       = "@kagi";
            URLTemplate = "https://kagi.com/search?q={searchTerms}";
            IconURL     = "https://kagi.com/favicon.ico";
          }];
        };

      ExtensionSettings =
      { "*" = {
          installation_mode = "blocked";
          blocked_install_message = "Extension not in the system config — add it to modules/apps/firefox.nix.";
        };
      }
      // builtins.mapAttrs (_: mode: { installation_mode = mode; }) addons;
      };
    };
  };
}
