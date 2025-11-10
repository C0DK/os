{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (
      with dotnetCorePackages;
      combinePackages [
        sdk_7_0
        sdk_8_0
        sdk_9_0
      ]
    )
    csharpier
  ];


  # tmp fix for dotnet 7, which some package indirectly uses
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-wrapped-7.0.410"
    "dotnet-sdk-7.0.410"
    "dotnet-core-combined"
  ];
}
