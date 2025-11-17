{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (
      with dotnetCorePackages;
      combinePackages [
        sdk_7_0
        sdk_8_0
        sdk_9_0
        sdk_10_0
      ]
    )
    csharpier
    omnisharp-roslyn
    csharp-ls
    netcoredbg
  ];
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}/share/dotnet/";
    # this seems to fuck up vim/lsp?
    DOTNET_ROLL_FORWARD = "LatestMajor";
  };

  # tmp fix for dotnet 7, which some package indirectly uses
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-wrapped-7.0.410"
    "dotnet-sdk-7.0.410"
    "dotnet-core-combined"
  ];
}
