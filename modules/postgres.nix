{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ pgcli ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "cwb"
      "stikl"
      "norple"
    ];
    ensureUsers = [
      {
        name = "cwb";
        ensureClauses = {
          login = true;
          superuser = true;
        };
      }
      {
        name = "stikl";
        ensureClauses = {
          login = true;
        };
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     127.0.0.1/32   trust
      host  all       all     ::1/128       trust
    '';

  };
}
