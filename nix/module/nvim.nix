{
  lib,
  config,
  ...
}:
lib.mkIf (!config.zhuk.nvim.own) {
  zhuk.nvim.package = config.programs.nvf.settings.vim.build.finalPackage;
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = {
      vim = {
        keymaps =
          [
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
              key = "<leader>b";
              action = "<Nop>";
              desc = "Buffers";
              mode = [
                "n"
                "v"
              ];
            }
            {
              mode = [
                "n"
                "v"
              ];
              key = "<leader>bn";
              action = "<cmd>bnext<CR>";
              desc = "Go to next buffer";
            }
            {
              mode = [
                "n"
                "v"
              ];
              key = "<leader>bp";
              action = "<cmd>bprevious<CR>";
              desc = "Go to previous buffer";
            }
            {
              mode = [
                "n"
                "v"
              ];
              key = "<leader>bd";
              action = "<cmd>bdelete<CR>";
              desc = "Delete buffer";
            }
          ]
          ++ lib.optionals config.programs.nvf.settings.vim.fzf-lua.enable [
            {
              key = "<leader>f";
              action = "<Nop>";
              desc = "Fzf";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader><leader>";
              action = "<cmd>FzfLua files<CR>";
              desc = "Fuzzy find files";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>g";
              action = "<cmd>FzfLua live_grep<CR>";
              desc = "Live grep in files";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>fb";
              action = "<cmd>FzfLua buffers<CR>";
              desc = "Fuzzy find buffers";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>fh";
              action = "<cmd>FzfLua help_tags<CR>";
              desc = "Fuzzy find help tags";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "t";
              action = "<cmd>FzfLua tabs<CR>";
              desc = "Fuzzy find tabs";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>fl";
              action = "<cmd>FzfLua blines<CR>";
              desc = "Fuzzy find current line buffers";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>bc";
              action = "<cmd>FzfLua lsp_document_diagnostics<CR>";
              desc = "Fuzzy find current buffer diagnostics";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>r";
              action = "<cmd>FzfLua oldfiles<CR>";
              desc = "Fuzzy find recent files";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>ts";
              action = "<cmd>FzfLua lsp_workspace_symbols<CR>";
              desc = "Fuzzy find workspace symbols";
              mode = [
                "n"
                "v"
              ];
            }
            {
              key = "<leader>fwd";
              action = "<cmd>FzfLua diagnostics_workspace<CR>";
              desc = "Fuzzy find diagnostics";
              mode = [
                "n"
                "v"
              ];
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
        fzf-lua = {
          enable = true;
          profile = "max-perf";
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
          modes-nvim = {
            enable = true;
            setupOpts = {
              setCursorline = true;
            };
          };
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
          termguicolors = true;
          foldlevel = 69420;
        };
      };
    };
  };
}
