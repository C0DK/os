{ pkgs, ... }:
# TODO: make more flaky
let
  nixvim = import (
    builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-25.05";
    }
  );
in
{
  inputs.nixvim = {
        url = "github:nix-community/nixvim";
        # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
        inputs.nixpkgs.follows = "nixpkgs";
    };
  # TODO:
  # - setup conform-nvim with python
  imports = [
    nixvim.nixosModules.nixvim
  ];

  environment.systemPackages = with pkgs; [
    ripgrep
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    globals.mapleader = " ";

    nixpkgs.useGlobalPackages = true;

    clipboard = {
      register = "unnamedplus";
      #providers.wl-copy.enable = true;
    };

    opts = {
      number = true; # Show line numbers
      shiftwidth = 2; # Tab width should be 2
      smartcase = true;
      expandtab = true;
    };

    colorschemes.catppuccin.enable = true;
    plugins = {
      auto-save = {
        enable = true;
        settings.write_all_buffers = true;
      };
      actions-preview.enable = true;
      trouble = {
        enable = true; # installs folke/trouble.nvim
        # optional: tweak defaults
        settings = {
          auto_open = false; # open only on command
          auto_close = false;
        };
      };
      web-devicons.enable = true;
      telescope = {
        enable = true;
      };
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            cs = [ "csharpier" ];
            nix = [ "nixfmt" ];
          };
          # this sorta breaks on auto save...
          #format_on_save = {
          #timeout_ms = 1000;
          #lsp_fallback = false;
          #};
        };
      };

      lsp = {
        enable = true;
        servers = {
          vtsls.enable = true; # typescript
          nil_ls.enable = true; # LS for Nix
          gopls.enable = true; # LS for golang

          csharp_ls.enable = true; # we are trying omnisharp instead
          #omnisharp.enable = true;
          # todo get uv working better!
          basedpyright.enable = true;

          terraformls.enable = true;
          dagger.enable = true;

          bashls.enable = true;

          nushell.enable = true;

          htmx.enable = true;
          html.enable = true;
          tailwindcss.enable = true;

          jsonls.enable = true;
          yamlls.enable = true;

          dotls.enable = true; # graphviz
        };
        onAttach = ''
          require('cmp').setup.buffer {
            sources = {
              { name = 'nvim_lsp' },
            }
          }
        '';
      };
      lualine = {

        enable = true;

        settings = {
          options = {

            sections = {
              lualine_c = [
                {
                  __unkeyed-1 = "filename";
                  path = 2;
                }
              ];
            };

          };
        };
      };
      cmp = {
        enable = true;
        # pre-select first item, show docs, etc.

        autoEnableSources = true;
        settings = {
          preselect = "Item";
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
          };
        };
      };

      noice.settings.presets."inc_rename" = true;
      inc-rename.enable = true; # Nice renaming UI
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>t";
        action = "<cmd>Trouble diagnostics toggle<CR>";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>wincmd k<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>wincmd j<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>wincmd h<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<cmd>wincmd l<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>r";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      }
      {
        #mode = "n";
        key = "<C-e>";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      }
      {
        mode = "n";
        key = "<leader>hh";
        action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>u";
        #action = "<cmd>vim.lsp.buf.references(nil, { includeDeclaration = false })<CR>";
        action = "<cmd>lua require('telescope.builtin').lsp_references()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>s";
        action = "<cmd>lua require('actions-preview').code_actions()<CR>";
      }
      {
        mode = "n";
        key = "<leader><leader>";
        action = "<cmd>lua require('telescope.builtin').git_files()<CR>";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>lua require('telescope.builtin').find_files()<CR>";
      }
      {
        mode = "n";
        key = "<leader>g";
        action = "<cmd>lua require('telescope.builtin').live_grep()<CR>";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>lua require('telescope.builtin').buffers()<CR>";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>b#<CR>"; # prior buffer
      }

      {
        mode = "i";
        key = "jj";
        action = "<Esc>";
      }

      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua vim.lsp.buf.format { async = true }<CR>";
      }
    ];
  };
}
