{ config, hostname, user, pkgs, ... }:
{
  networking.hostName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Casper Weiss Bang";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };
}
