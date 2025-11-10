{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    preferences = {
      "layout.css.light-dark.enabled" = true;
    };

    policies = {
      DisableFirefoxAccounts = true;
      DisableTelemetry = true;
      SearchBar = "unified";
      DisableAccounts = true;
      ExtensionSettings =
        with builtins;
        let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
        in
        listToAttrs [
          (extension "proton-pass" "78272b6fa58f4a1abaac99321d503a20@proton.me")
          (extension "kagi-search-for-firefox" "search@kagi.com")
          # TODO: doesnt seem to be installed. + configure it in code to use catpuccin
          (extension "firefox-color" "me@lmorchard.com")
          (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
          #(extension "ctrl-number-to-switch-tabs" "84601290-bec9-494a-b11c-1baa897a9683")
          # TODO add bitwarden
        ];
      # To add additional extensions, find it on addons.mozilla.org, find
      # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
      # Then, download the XPI by filling it in to the install_url template, unzip it,
      # run `jq .browser_specific_settings.gecko.id manifest.json` or
      # `jq .applications.gecko.id manifest.json` to get the UUID
    };
  };
}
