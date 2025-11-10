{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
    python313
    virtualenv
    pdm
    pipenv
    black
    ruff

    uv

    python313Packages.numpy
    python313Packages.pip
    python313Packages.jupyterlab
    python313Packages.jupyterlab-server
    python313Packages.hatchling
    python313Packages.pip-system-certs
    python313Packages.certifi

    openssl
  ];

}
