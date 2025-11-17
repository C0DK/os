{
  config,
  hostname,
  fullName,
  user,
  pkgs,
  ...
}:
{
  networking.hostName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };
}
