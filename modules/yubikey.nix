{ config, pkgs, ... }:

{
  imports = [ ./gpg.nix ];

  environment.systemPackages = with pkgs; [
    yubikey-touch-detector
    yubikey-manager
    yubioath-flutter

    pam_u2f
  ];
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # To init pam for yubikey run (nushell syntax):
  # $ mkdir ~/.config/Yubico
  # $ pamu2fcfg out> ~/.config/Yubico/u2f_keys
  # see: https://nixos.wiki/wiki/Yubikey#pam_u2f

  security.pam.services = {
    #login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  programs.ssh.startAgent = false;
  programs.yubikey-touch-detector.enable = true;

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  # Locks the screen if the yubikey is removed
  # TODO: install hyprlock as system package and use it here.
  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';
}
