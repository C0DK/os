{
  user,
  pkgs,
  ...
}:
{
  home-manager.users.${user}.xdg.configFile."television/cable/dotnet-projects.toml" = {
    force = true;
    source = (pkgs.formats.toml { }).generate "dotnet-projects.toml" {
      metadata = {
        name = "dotnet-projects";
        requirements = [ ];
        description = "A channel to select from .NET projects (.csproj) on your local machine.";
      };
      source = {
        command = "glob **/*.csproj -d 5 | where {|file| let doc = try { open $file | from xml } catch { {} }; let sdk = try { $doc.attributes.Sdk? } catch { \"\" }; let outType = try { (($doc.content | where {|e| $e.tag == 'PropertyGroup'} | first).content | where {|e| $e.tag == 'OutputType'}).content | each {|e| $e.content} | first | first } catch { \"\" }; (($sdk | str contains 'Web') or (($sdk | str contains 'Microsoft.NET.Sdk') and ($outType | str contains 'Exe'))) } | each { |f| $\"($f | path parse | get stem)|($f)\" } | str join (char newline)";
        shell = "nu";
        display = "{split:|:0}";
        output = "{split:|:1}";
      };
      preview = {
        command = "bat --color=always {split:|:1}";
      };
      keybindings = {
        ctrl-e = "actions:edit";
      };
      actions = {
        edit = {
          description = "Open the project file in editor";
          command = "hx {split:|:1}";
          mode = "execute";
        };
      };
    };
  };
}
