{ pkgs, user, ... }:
{

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
  environment.systemPackages = with pkgs; [
    nil # nix language server
    vscode-langservers-extracted
    yaml-language-server
    pgformatter
  ];
  home-manager.users.${user} = {

    # TODO: make work for all string types.
    xdg.configFile."helix/runtime/queries/c-sharp/injections.scm".text = ''
      (
        (comment) @_comment
        .
        (argument
          (raw_string_literal
            (raw_string_content) @injection.content))
        (#match? @_comment "language=sql")
        (#set! injection.language "sql")
      )

      (
        (comment) @_comment
        .
        (argument
          (interpolated_string_expression
            (string_content) @injection.content))
        (#match? @_comment "language=sql")
        (#set! injection.language "sql")
      )

      (
        (comment) @_comment
        .
        (argument
          (raw_string_literal
            (raw_string_content) @injection.content))
        (#match? @_comment "language=html")
        (#set! injection.language "html")
      )

      (
        (comment) @_comment
        .
        (argument
          (interpolated_string_expression
            (string_content) @injection.content))
        (#match? @_comment "language=html")
        (#set! injection.language "html")
      )
    '';
    xdg.configFile."helix/runtime/queries/c-sharp/indents.scm".text = ''
      ; Bracket-delimited blocks
      (_ "{" "}" ) @indent
      (_ "[" "]" ) @indent
      (_ "(" ")" ) @indent

      [
        "}"
        "]"
        ")"
      ] @outdent

      ; Bracketless single-statement bodies
      (if_statement
        consequence: (_) @indent
        (#not-kind-eq? @indent "block")
        (#set! "scope" "all"))
      (else_clause
        (_) @indent
        (#not-kind-eq? @indent "block")
        (#not-kind-eq? @indent "if_statement")
        (#set! "scope" "all"))
      (for_statement
        body: (_) @indent
        (#not-kind-eq? @indent "block")
        (#set! "scope" "all"))
      (foreach_statement
        body: (_) @indent
        (#not-kind-eq? @indent "block")
        (#set! "scope" "all"))
      (while_statement
        body: (_) @indent
        (#not-kind-eq? @indent "block")
        (#set! "scope" "all"))
      (do_statement
        body: (_) @indent
        (#not-kind-eq? @indent "block")
        (#set! "scope" "all"))

      ; Expression/method-chain continuations
      (member_access_expression
        (#set! "scope" "tail")) @anchor @align
      (invocation_expression
        (#set! "scope" "tail")) @anchor @align
    '';

    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_macchiato";

        keys.normal = {
          space."=" = ":format";
          space.space = "file_picker";
          space.L = [
            ":reload-all"
            ":lsp-restart"
          ];
        };
        editor = {
          # Enable cursorline highlighting
          cursorline = true;
          # I want to see hidden files in repos
          file-picker.hidden = false;

          # Show color indication for modes
          color-modes = true;

          default-yank-register = "+";
          editor-config = true;
          # Auto-save when focus is lost
          auto-save = {
            focus-lost = true;
            after-delay = {
              enable = true;
              timeout = 500; # milliseconds, default is 3000
            };
          };
          # Cursor shapes for different modes
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          lsp = {
            enable = true;
          };

          # Show indentation guides
          indent-guides = {
            render = true;
          };
        };
      };

      languages = {
        language-server = {
          # dotnet tool install --global roslyn-language-server --prerelease
          roslyn-language-server = {
            command = "roslyn-language-server";
            args = [
              "--stdio"
              "--autoLoadProjects"
            ];
          };
        };

        debugger = [
          {
            name = "netcoredbg";
            transport = "tcp";
            command = "netcoredbg";
            args = [ "--interpreter=vscode" ];
            port-arg = "--server={}";
            templates = [
              {
                name = "launch";
                request = "launch";
                completion = [
                  {
                    name = "binary";
                    completion = "filename";
                  }
                ];
                args = {
                  type = "coreclr";
                  request = "launch";
                  program = "{0}";
                };
              }
              {
                name = "attach";
                request = "attach";
                completion = [
                  {
                    name = "pid";
                    completion = "pid";
                  }
                ];
                args = {
                  type = "coreclr";
                  request = "attach";
                  processId = "{0}";
                };
              }
            ];
          }
        ];
        language = [
          {
            name = "sql";
            formatter = {
              command = "pg_format";
              args = [ "-" ];
            };
          }
          {
            name = "c-sharp";
            language-servers = [
              { name = "roslyn-language-server"; }
              {
                name = "csharp-ls";
                only-features = [ "diagnostics" ];
              }
            ];
            formatter = {
              command = "csharpier";
              args = [
                "format"
                "--write-stdout"
              ];
            };
          }
        ];
      };
    };
  };
}
