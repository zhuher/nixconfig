{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (!config.zhuk.nvim.own) {
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = {
      vim = {
        keymaps = [
          {
            key = "<leader>q";
            mode = ["n"];
            silent = true;
            action = "<cmd>q<CR>";
          }
          {
            key = "<leader>x";
            mode = ["n"];
            silent = true;
            action = "<cmd>x<CR>";
          }
          {
            key = "<leader>w";
            mode = ["n"];
            silent = true;
            action = "<cmd>w<CR>";
          }
          {
            key = "<leader>fl";
            desc = "Telescope fuzzy find this buffer";
            mode = ["n"];
            silent = true;
            nowait = true;
            action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
          }
        ];
        autocomplete = {
          blink-cmp = {
            enable = true;
          };
        };
        treesitter = {
          fold = true;
          highlight.enable = true;
          indent.enable = true;
          context.enable = true;
        };
        telescope = {
          enable = true;
          extensions = [
            {
              name = "fzf";
              packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
              setup = {
                fzf = {
                  fuzzy = true;
                };
              };
            }
          ];
          mappings = {
            findFiles = "<leader><leader>";
            diagnostics = "<leader>fwd";
            lspDocumentSymbols = "<leader>fds";
            lspReferences = "<leader>fdr";
            lspTypeDefinitions = "<leader>fdt";
            lspWorkspaceSymbols = "<leader>fws";
            liveGrep = "<leader>g";
          };
        };
        mini.icons.enable = true;
        visuals = {
          blink-indent.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          rainbow-delimiters.enable = true;
        };
        bell = "visual";
        utility.sleuth.enable = true;
        ui = {
          colorful-menu-nvim.enable = true;
          borders.enable = true;
          colorizer = {
            enable = true;
            setupOpts.filetypes."*" = {
              RRGGBB = true;
            };
          };
          fastaction.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
          noice = {
            enable = true;
          };
          nvim-ufo.enable = true;
          smartcolumn = {
            enable = true;
            setupOpts.colorcolumn = [
              "80"
              "120"
            ];
          };
        };
        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          # hardtime-nvim.enable = true;
        };
        formatter.conform-nvim.enable = true;
        lsp = {
          enable = true;
          inlayHints.enable = true;
          mappings = {
            codeAction = "<leader>a";
          };
        };
        languages = {
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          nix.enable = true;
          zig.enable = true;
          rust.enable = true;
          nu.enable = true;
        };
        options = {
          termguicolors = false;
          foldlevel = 69420;
          cursorline = true;
        };
      };
    };
  };
}
