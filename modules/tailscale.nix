{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    # i assume this makes it possible to choose.
    useRoutingFeatures = "both";
  };
}
