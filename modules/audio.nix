{ pkgs, ... }:
{
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;

  environment.systemPackages = with pkgs; [

    pavucontrol
    # Control mediaplayers (spotify)
    playerctl
    ];
}
