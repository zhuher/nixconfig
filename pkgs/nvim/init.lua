-- hi!
-- lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo,
    lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" },
      { "\nPress any key to exit..." }
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
-- lazy.nvim }}}
-- basic options {{{
local g = vim.g
local o = vim.opt
local vo = vim.o

g.mapleader = ' ' -- i'm stuff
g.maplocalleader = ' ' -- i'm stuff
o.completeopt = "fuzzy,menuone,noselect,noinsert,popup"
o.confirm = false -- just fail without asking
o.formatoptions = "jcoqlnt" -- i'm stuff
o.swapfile = false -- DO NOT create swap files
o.laststatus = 1 -- make last window always have a statusline
o.encoding = "utf-8" -- self-explainatory
o.showmatch = true -- briefly jump to matching symbol within a pair when another is inserted, beep otherwise
o.ignorecase = true -- case-insensitive search
o.smartcase = true -- make search case-sensitive on differing cases in search pattern
o.incsearch = true -- show searchmatches
o.clipboard = "unnamedplus" -- put stuff in the '+' register
o.list = true -- show chars for each whitespace char
-- o.listchars:append "tab:» ,space:·,trail:·,eol:↴" -- chars to show for whitespace charss
o.listchars:append "tab:» ,space: ,trail: ,eol:↴" -- chars to show for whitespace charss
o.number = true -- number lines
o.smarttab = true -- uhhh
o.tabstop = 2 -- a single tab's value in spaces
o.softtabstop = 2 -- spaces to insert on tab
o.shiftwidth = 2 -- indentation width
o.expandtab = true -- convert tabs into spaces
o.wrap = true -- self-explainatory
o.scrolloff = 3 -- minimum lines to keep around the cursor
o.updatetime = 50 -- milliseconds of inactivity before swap is written
o.hidden = true -- hide instead of abandoning files
-- o.signcolumn = "yes" -- ???
o.cursorline = true -- self-explainatory
o.cursorlineopt = 'line,number' -- self-explainatory
o.cursorcolumn = true -- highlight cursor column
o.mouse = "a" -- enable mouse for [a]ll modes
o.shortmess = "aoOtIF" -- short messaging such as changed([+]) etc.
o.relativenumber = true -- display relative line numbers
o.splitbelow = true -- split below current window
o.splitright = true -- split right of current window
-- o.showmode = false  -- if in insert, replace or visual modes, DON'T put a message on the last line
o.undofile = true -- keep a file with undo information
o.undolevels = 10000 -- amount of changes to keep
g.loaded_perl_provider = 0
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
vo.hlsearch = true -- highlight all search matches
-- vo.omnifunc = [[vim.lsp.omnifunc]]
o.guicursor =      -- gui cursor settings
[[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175]]
o.foldmethod =
"marker" -- using '{{{' & '}}}' foldmarkers
-- "expr" -- v---using-the-expression-below--v
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
local symbols = { ERROR = "󰅙", INFO = "󰋼", HINT = "󰌵", WARN = "" }
local diag_opts = {
  update_in_insert = true,
  virtual_text = {
    prefix = '●',
  },
  severity_sort = true,
  underline = true,
  signs = { text = {} },
  float = {
    border = "rounded",
    format = function(d)
      return ("%s (%s) [%s]"):format(d.message, d.source, d.code or d.user_data.lsp.code)
    end,
  },
  jump = {
    float = true,
  },
}
for type, symbol in pairs(symbols) do
  diag_opts.signs.text[vim.diagnostic.severity[type]] = symbol
end
vim.diagnostic.config(diag_opts)
vim.api.nvim_set_hl(0, "CursorColumn", { reverse = true })
vim.api.nvim_set_hl(0, "CursorLineNr", { reverse = true })
vim.api.nvim_set_hl(0, "CursorLine", { reverse = true })
-- local a
-- ===
-- sussex
-- basic options }}}
-- keys {{{
vim.keymap.set({ 'n', 'v' }, '<leader>q', '<cmd>q<CR>', { remap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>Q', '<cmd>qa<CR>', { remap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>w', '<cmd>w<CR>', { remap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>x', '<cmd>x<CR>', { remap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'gh', '^', { remap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'gl', '$', { remap = true, silent = true })
vim.keymap.set({ 'n', "v" }, '<leader>b', '<Nop>', { desc = 'Buffers' })
vim.keymap.set({ "n", "v" }, '<leader>bn', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set({ "n", "v" }, '<leader>bp', '<cmd>bprevious<CR>',
  { desc = 'Go to previous buffer' })
vim.keymap.set({ "n", "v" }, '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })
vim.keymap.set({ "n", "v" }, '<leader>s', '<Nop>', { desc = 'Splits' })
vim.keymap.set({ "n", "v" }, '<leader>ss', '<C-w>s', { desc = 'Split horizontally' })
vim.keymap.set({ "n", "v" }, '<leader>sv', '<C-w>v', { desc = 'Split vertically' })
vim.keymap.set({ "n", "v" }, '<leader>sh', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set({ "n", "v" }, '<leader>sj', '<C-w>j', { desc = 'Move to bottom split' })
vim.keymap.set({ "n", "v" }, '<leader>sk', '<C-w>k', { desc = 'Move to top split' })
vim.keymap.set({ "n", "v" }, '<leader>sl', '<C-w>l', { desc = 'Move to right split' })
vim.keymap.set({ "n", "v" }, '<leader>sc', '<C-w>c', { desc = 'Close split' })
vim.keymap.set({ "n", "v" }, '<leader>so', '<C-w>o', { desc = 'Close all splits except current' })
-- map option+shift+brackets to cycle tabs
vim.keymap.set({ "n", "v" }, '<A-S-[>', '<cmd>tabprevious<CR>', { desc = 'Go to previous tab' })
vim.keymap.set({ "n", "v" }, '<A-S-]>', '<cmd>tabnext<CR>', { desc = 'Go to next tab' })
vim.keymap.set({ "n", "v" }, '<A-w>', '<cmd>tabclose<CR>', { desc = 'Close tab' })
-- keys }}}
-- shell {{{ -- https://github.com/pondodev/dotfiles/blob/61e476a5d6ee4d9e8d413a54778b7710e7e1aff4/nvim/init.lua#L30-L37
local shell = vim.fn.system({ "which", "zsh" })
local nullsToCull = 1
vim.opt.shell = string.sub(shell, 1, string.len(shell) - nullsToCull)
if vim.opt.shell == "" or vim.opt.shell == nil then
  shell = vim.fn.system({ "which", "bash" })
  vim.opt.shell = string.sub(shell, 1, string.len(shell) - nullsToCull)
end
-- shell }}}
-- Per-capability lsp config {{{
local bufkey = function(mode, key, cmd, desc, extraopts)
  local keymap_opts = vim.tbl_deep_extend("force", { desc = desc }, extraopts)
  vim.keymap.set(mode, key, cmd, keymap_opts)
end
vim.api.nvim_create_autocmd('LspAttach', {
  desc = "LSP actions",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local keyopts = { buffer = args.buf }
    if client == nil then
      return
    end
    if client.capabilities.textDocument.implementation then
      bufkey('n', 'gi', vim.lsp.buf.implementation, 'Jump to implementation', keyopts)
    end
    -- if client.supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true }) -- <-evil
    -- end
    -- -- formatting on save {{{
    -- if client.server_capabilities.documentFormattingProvider then
    --   vim.api.nvim_create_autocmd('BufWritePre', {
    --     buffer = args.buf,
    --     callback = function()
    --       vim.lsp.buf.format({ async = true, bufnr = args.buf, id = client.id })
    --     end,
    --   })
    -- end
    -- -- formatting on save }}}
    if client.server_capabilities.documentFormattingProvider then
      bufkey('n', '<leader>lf', "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", 'Format the current buffer',
        keyopts)
    end
    if client.capabilities.textDocument.definition then
      bufkey('n', 'gd', vim.lsp.buf.definition, 'Jump to definition', keyopts)
    end
    if client.capabilities.textDocument.declaration then
      bufkey('n', 'gD', vim.lsp.buf.declaration, 'Jump to declaration', keyopts)
    end
    -- if client.capabilities.textDocument.hover then
    --   bufkey('n', 'K', "<cmd>lua vim.lsp.buf.hover({ border = { '╭', '─' ,'╮', '│', '╯', '─', '╰', '│' } })<CR>",
    --     'Show symbol info in a floating window',
    --     keyopts)
    -- end
    if client.capabilities.textDocument.references then
      bufkey('n', 'gr', vim.lsp.buf.references, 'Find references to the symbol under the cursor', keyopts)
    end
    if client.capabilities.textDocument.rename then
      bufkey('n', '<leader>lr', vim.lsp.buf.rename, 'Rename the symbol under the cursor', keyopts)
    end
    if client.capabilities.textDocument.signatureHelp then
      bufkey('n', 'gs', vim.lsp.buf.signature_help, 'Show signature help in a floating window', keyopts)
    end
    if client.capabilities.textDocument.typeDefinition then
      bufkey('n', 'go', vim.lsp.buf.type_definition, 'Jump to type definition', keyopts)
    end
    if client.capabilities.textDocument.codeAction then
      bufkey('n', '<leader>la', vim.lsp.buf.code_action, 'Show code actions for the symbol under the cursor',
        keyopts)
    end
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end
})
-- conditional lsp config }}}
-- vim.lsp {{{
vim.lsp.config('*', { -- {{{
  root_markers = { '.git', '.jj', '.devenv', '.envrc' },
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      },
      rename = {
        dynamicRegistration = true,
        prepareSupport = true,
        -- honorsChangeAnnotations = true,
      },
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  }
})                        -- }}}
vim.lsp.config.lua_ls = { -- {{{
  cmd = { 'lua-language-server' },
  root_markers = { 'init.lua' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      hint = {
        enable = true,
        arrIndex = "Enable",
        setType = true,
        await = true,
        paramName = "All",
        paramType = true,
        semicolon = "All",
        viewString = true,
      },
      hover = {
        enable = true,
        enumsLimit = 1337,
        expandAlias = true,
        viewNumber = true,
      },
      diagnostics = {
        disable = { "incomplete-signature-doc" },
      },
    },
  },
}
vim.lsp.enable('lua_ls')  -- }}}
vim.lsp.config.clangd = { -- {{{
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  capabilities = {
    offsetEncoding = { "utf-8", "utf-16" },
    textDocument = {
      completion = {
        editsNearCursor = true
      }
    }
  }
}
vim.lsp.enable('clangd')  -- }}}
vim.lsp.config.nil_ls = { -- {{{
  cmd = { 'nil' },
  filetypes = { 'nix' },
  single_file_support = true,
  root_markers = { 'flake.nix', 'flake.lock' },
  settings = {
    ['nil'] = {
      formatting = {
        command = { 'alejandra' },
      },
      nix = {
        flake = {
          autoArchive = true,
        },
      },
    },
  }
}
vim.lsp.enable('nil_ls') -- }}}
vim.lsp.config.gopls = { -- {{{
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.mod', 'go.work' },
  single_file_support = true,
}
vim.lsp.enable('gopls') -- }}}
vim.lsp.config.zls = {  -- {{{
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'build.zig', 'build.zig.zon' },
  single_file_support = true,
  settings = {
    zls = {
      semantic_tokens = "partial",
      enable_build_on_save = true,
    },
  },
}
vim.lsp.enable('zls')            -- }}}
vim.lsp.config.rust_analyzer = { -- {{{
  capabilities = {
    experimental = { serverStatusNotification = true },
  },
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  single_file_support = true,
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = "clippy",
      },
    },
  }
}
vim.lsp.enable('rust_analyzer') -- }}}
vim.lsp.config.bashls = {       -- {{{
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh', 'zsh', 'command' },
  -- root_markers = { '.git' },
  single_file_support = true,
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)"
    },
  },
}
vim.lsp.enable('bashls') -- }}}
-- vim.lsp }}}
-- neovide-specific {{{
if vim.g.neovide then
  vim.o.guifont = "Maple Mono:h14"
  -- Helper function for transparency formatting
  -- local alpha = function()
  --   return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8)))
  -- end
  -- g:neovide_opacity should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_window_blurred = true
  vim.g.transparency = 0.8
  -- vim.g.neovide_background_color = "#000000" .. alpha()
end
-- neovide-specific }}}
local ts_langs = { "regex", "rust", "zig", "go", "nix", "c", "lua", "vim", "vimdoc", "javascript", "typescript", "html",
  "julia",
  "css", "markdown" }
local function checkExts()
  local uis = vim.api.nvim_list_uis()
  local ok = true
  for _, ui in ipairs(uis) do
    for _, ext in ipairs({ "ext_cmdline", "ext_popupmenu", "ext_messages" }) do
      if ui[ext] then
        ok = false
      end
    end
  end
  return ok
end
local hmmm = checkExts()
local function extraPlugFunc()
  return os.getenv("E") ~= nil
end
local doWhistles = extraPlugFunc()
local plugins = {
  -- nvim-ufo {{{
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      { 'kevinhwang91/promise-async', lazy = true }
    },
    event = "BufReadPost",
    keys = {
      {
        'zR',
        '<cmd>lua require("ufo").openAllFolds()<CR>',
        mode = { 'n' },
        desc = 'Open all folds'
      },
      {
        'zM',
        '<cmd>lua require("ufo").closeAllFolds()<CR>',
        mode = { 'n' },
        desc = 'Close all folds'
      },
      {
        'zr',
        '<cmd>lua require("ufo").openFoldsExceptKinds()<CR>',
        mode = { 'n' },
        desc = 'Open folds except certain kinds'
      },
      {
        'zm',
        '<cmd>lua require("ufo").closeFoldsWithKinds()<CR>',
        mode = { 'n' },
        desc = 'Close folds with certain kinds'
      },
      {
        'K',
        function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover({ border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } })
          end
        end,
        mode = { 'n' },
        desc = 'Peek folded lines under cursor'
      },
    },
    config = function()
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = -1
      vim.o.foldenable = true
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        close_fold_kinds_for_ft = {
          default = { "imports", "marker", "comment" },
        },
        close_fold_current_line_for_ft = {
          default = true,
        },
        preview = {
          win_config = {
            border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
            winhighlight = 'Normal:Folded',
            winblend = 0
          },
          mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            jumpTop = '[',
            jumpBot = ']'
          }
        },
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, 'MoreMsg' })
          return newVirtText
        end,
      })
    end
  },
  -- nvim-ufo }}}
  -- vim-dim {{{
  {
    'jeffkreeftmeijer/vim-dim',
    -- event = 'VeryLazy',
    -- cond = not doWhistles,
    lazy = false,
    config = function()
      vo.termguicolors = false -- enable 24-bit color support
      vim.cmd.colorscheme = 'dim'
    end,
  },
  -- vim-dim }}}
  -- blink.cmp {{{
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      { 'rafamadriz/friendly-snippets', lazy = true, module = true, },
      -- and mini.icons
      { 'echasnovski/mini.icons',       lazy = true, module = true, },
    },
    event = "InsertEnter",

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = true, window = { border = 'rounded' } },
        menu = {
          border = 'rounded',
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              }
            }
          }
        }
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'omni', 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" },
    keys = --[[ tab in command mode, or InsertEnter ]]
    {
      { "<Tab>", "<cmd>lua require('blink.cmp')['show']()<CR>", mode = { "c" } },
    },
  },
  -- blink.cmp }}}
  -- copilot.lua {{{
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    cond = doWhistles,
    build = ':Copilot auth',
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          hide_during_completion = false,
          auto_trigger = true,
          debounce = 100,
          keymap = {
            accept = "<M-l>",
            accept_word = "<M-w>",
          },
        }
      })
    end
  },
  -- copilot.lua }}}
  -- CodeCompanion.nvim {{{
  {
    "olimorris/codecompanion.nvim",
    -- lazy = true,
    cmd = "CodeCompanion",
    cond = doWhistles,
    config = true,
    dependencies = {
      { "nvim-lua/plenary.nvim",           lazy = true },
      { "nvim-treesitter/nvim-treesitter", lazy = true },
      { "echasnovski/mini.diff",           lazy = true },
    },
    keys = {
      {
        "<leader>cp",
        ":CodeCompanionChat<CR>",
        mode = { "n" },
        desc = "Code Companion",
      },
      {
        "<leader>cp",
        ":'<,'>CodeCompanion<CR>",
        mode = { "v" },
        desc = "Code Companion",
      },
    },
    opts = {
      strategies = {
        -- Change the default chat adapter
        chat = {
          adapter = "copilot",
        },
        inline = {
          -- Change the default inline adapter
          adapter = "copilot",
        },
      },
      display = {
        chat = {},
        diff = {
          enabled = true,
          -- close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "vertical",    -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
      },
      opts = {
        -- Set debug logging
        log_level = "DEBUG",
      },
    },
  },
  -- CodeCompanion.nvim }}}
  -- lazydev.nvim {{{
  {
    "folke/lazydev.nvim",
    ft = { "lua" }, -- only load on lua files
    event = "BufReadPre",
    lazy = true,
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- lazydev.nvim }}}
  -- catppuccin {{{
  {
    "catppuccin/nvim",
    enabled = false,
    name = "catppuccin",
    cond = doWhistles,
    build = ":CatppuccinCompile",
    priority = 1000,
    -- event = "VeryLazy",
    opts = {
      float = {
      },
      transparent_background = vim.g.neovide and false or true,
      term_colors = true,
      default_integrations = false,
      dim_inactive = {
        enabled = true,    -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
      integrations = {
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" }
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" }
          },
          inlay_hints = { background = true }
        },
        -- telescope = true,
        which_key = true,
        fidget = true,
        neotree = true,
        -- cmp = true,
        treesitter = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme = "catppuccin-latte"
    end,
  },
  -- catppuccin }}}
  -- fzf-lua {{{
  {
    "ibhagwan/fzf-lua",
    dependencies = { { "echasnovski/mini.icons", lazy = true, module = true },
    },
    opts = {},
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<Nop>", desc = "Fzf" },
      {
        "<leader><Space>",
        "<cmd>FzfLua files<CR>",
        desc = "Fuzzy find files",
        mode = { "n", "v" },
      },
      {
        "<leader>g",
        "<cmd>FzfLua grep<CR>",
        desc = "Fuzzy find in files",
        mode = { "n", "v" },
      },
      {
        "<leader>fb",
        "<cmd>FzfLua buffers<CR>",
        desc = "Fuzzy find buffers",
        mode = { "n", "v" },
      },
      {
        "<leader>fh",
        "<cmd>FzfLua help_tags<CR>",
        desc = "Fuzzy find help tags",
        mode = { "n", "v" },
      },
      {
        "t",
        "<cmd>FzfLua tabs<CR>",
        desc = "Fuzzy find tabs",
        mode = { "n", "v" },
      },
      {
        "<leader>fl",
        "<cmd>FzfLua blines<CR>",
        desc = "Fuzzy find current line buffers",
        mode = { "n", "v" },
      },
      {
        "<leader>b",
        "<Nop>",
        desc = "Buffers",
        mode = { "n", "v" },
      },
      {
        "<leader>bc",
        "<cmd>FzfLua lsp_document_diagnostics<CR>",
        desc = "Fuzzy find current buffer diagnostics",
        mode = { "n", "v" },
      },
      {
        "<leader>r",
        "<cmd>FzfLua oldfiles<CR>",
        desc = "Fuzzy find recent files",
        mode = { "n", "v" },
      },
      {
        "<leader>ts",
        "<cmd>FzfLua lsp_workspace_symbols<CR>",
        desc = "Fuzzy find workspace symbols",
        mode = { "n", "v" },
      },
      {
        "<leader>fwd",
        "<cmd>FzfLua diagnostics_workspace<CR>",
        desc = "Fuzzy find diagnostics",
        mode = { "n", "v" },
      },
    },
  },
  -- fzf-lua }}}
  -- crates.nvim {{{
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function()
      require("crates").setup({
        popup = {
          border = "rounded",
        },
      })
    end,
  },
  -- crates.nvim }}}
  -- which-key {{{
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below

      defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
          i = {
            -- map actions.which_key to <C-h> (default: <C-/>)
            -- actions.which_key shows the mappings for your picker,
            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
            ["<C-h>"] = "which_key"
          }
        }
      },
      pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
      },
      extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
      }
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)"
      }
    }
  },
  -- telescope }}}
  -- nvim-treesitter {{{
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    ft = ts_langs,
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = ts_langs,
        sync_install = false,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        ignore_install = {},
        modules = {},
        auto_install = true,
        incremental_selection = { enable = true, },
        textobjects = { enable = true, },

      })
    end
  },
  -- nvim-treesitter }}}
  -- noice.nvim {{{
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    cond = function(LazyPlugin)
      local uis = vim.api.nvim_list_uis()
      for _, ui in ipairs(uis) do
        for _, ext in ipairs({ "ext_cmdline", "ext_popupmenu", "ext_messages" }) do
          if ui[ext] then
            return false
          end
        end
      end
      return true
    end,

    opts = {
      -- add any options here
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = false, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
      -- views = {
      --   mini = {
      --     position = {
      --       row = -2,
      --       col = "100%",
      --     },
      --   },
      -- },
    },
    dependencies = {
      { "MunifTanjim/nui.nvim", lazy = true, module = true },
      { "folke/snacks.nvim",    lazy = true, module = true }
    }
  },
  -- noice.nvim }}}
  -- lualine.nvim {{{
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    cond = hmmm,
    config = function()
      require('lualine').setup({
        options = {
          theme = "auto",
          --        
          -- section_separators = { left = "", right = "" },
          -- │ ┊     •
          -- component_separators = { left = "", right = "" },
          component_separators = { left = "::", right = "::" },
          globalstatus = true,
          -- disabled_filetypes = { statusline = { "dashboard", "alpha", "starter", "snacks_dashboard" } },
          refresh = {
            statusline = 300,
          },
        }
      })
    end,
  },
  -- lualine.nvim }}}
  -- neo-tree {{{
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      { "echasnovski/mini.icons", lazy = true, module = true, opts = {} }, -- add mini.icons
      { "MunifTanjim/nui.nvim",   lazy = true, module = true },
      { "nvim-lua/plenary.nvim",  lazy = true, module = true },
    },
    lazy = true,
    keys = {
      {
        "=",
        "<cmd>Neotree toggle float<CR>",
        desc = "Toggle NeoTree",
        mode = { "n" },
      },
    },
    opts = {
      popup_border_style = "rounded",
      default_component_configs = {
        icon = {
          provider = function(icon, node) -- setup a custom icon provider
            local text, hl
            local mini_icons = require("mini.icons")
            if node.type == "file" then          -- if it's a file, set the text/hl
              text, hl = mini_icons.get("file", node.name)
            elseif node.type == "directory" then -- get directory icons
              text, hl = mini_icons.get("directory", node.name)
              -- only set the icon text if it is not expanded
              if node:is_expanded() then
                text = nil
              end
            end
            -- set the icon text/highlight only if it exists
            if text then
              icon.text = text
            end
            if hl then
              icon.highlight = hl
            end
          end,
        },
        kind_icon = {
          provider = function(icon, node)
            local mini_icons = require("mini.icons")
            icon.text, icon.highlight = mini_icons.get("lsp", node.extra.kind.name)
          end,
        },
      },
    },
  },
  -- neo-tree }}}
  -- compile-mode.nvim {{{
  {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    -- you can just use the latest version:
    -- branch = "latest",
    -- or the most up-to-date updates:
    cmd = "Compile",
    branch = "nightly",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- if you want to enable coloring of ANSI escape codes in
      -- compilation output, add:
      -- { "m00qek/baleia.nvim", tag = "v1.3.0" },
    },
    config = function()
      ---@type CompileModeOpts
      vim.g.compile_mode = {
        -- to add ANSI escape code support, add:
        baleia_setup = true,

        -- to make `:Compile` replace special characters (e.g. `%`) in
        -- the command (and behave more like `:!`), add:
        bang_expansion = true,
      }
    end
  },
  -- compile-mode.nvim }}}
  -- hardtime.nvim {{{
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    enabled = false,
    opts = {}
  },
  -- hardtime.nvim }}}
  -- precognition.nvim {{{
  {
    "tris203/precognition.nvim",
    cmd = "Precognition",
    event = "BufReadPre",
    enabled = false,
    opts = {
      startVisible = true,
      showBlankVirtLine = true,
      highlightColor = { link = "Comment" },
      hints = {
        Caret = { text = "^", prio = 2 },
        Dollar = { text = "$", prio = 1 },
        MatchingPair = { text = "%", prio = 5 },
        Zero = { text = "0", prio = 1 },
        w = { text = "w", prio = 10 },
        b = { text = "b", prio = 9 },
        e = { text = "e", prio = 8 },
        W = { text = "W", prio = 7 },
        B = { text = "B", prio = 6 },
        E = { text = "E", prio = 5 },
      },
      gutterHints = {
        G = { text = "G", prio = 10 },
        gg = { text = "gg", prio = 9 },
        PrevParagraph = { text = "{", prio = 8 },
        NextParagraph = { text = "}", prio = 8 },
      },
      -- disabled_fts = {
      --   -- "startify",
      -- },
    },
  },
  -- precognition.nvim }}}
  -- hunk.nvim {{{
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    config = function()
      require("hunk").setup()
    end,
  },
  -- hunk.nvim }}}
  -- Comment.nvim {{{
  {
    'numToStr/Comment.nvim',
    -- event = "VeryLazy",
    lazy = true,
    keys = {
      {
        "gcc",
        "gcc",
        desc = "Toggle line comment under cursor",
        mode = { "n" },
      },
      {
        "gbc",
        "gbc",
        desc = "Toggle block line comment under cursor",
        mode = { "n" },
      },
      {
        "gb",
        "gb",
        desc = "Toggle block comment of selection",
        mode = { "v" },
      },
    },
    opts = {
      ---Add a space b/w comment and the line
      padding = true,
      ---Whether the cursor should stay at its position
      sticky = false,
      ---Lines to be ignored while (un)comment
      ignore = nil,
      ---LHS of toggle mappings in NORMAL mode
      toggler = {
        ---Line-comment toggle keymap
        line = 'gcc',
        ---Block-comment toggle keymap
        block = 'gbc',
      },
      ---LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        ---Line-comment keymap
        line = 'gc',
        ---Block-comment keymap
        block = 'gb',
      },
      ---LHS of extra mappings
      extra = {
        ---Add comment on the line above
        above = 'gcO',
        ---Add comment on the line below
        below = 'gco',
        ---Add comment at the end of line
        eol = 'gcA',
      },
      ---Enable keybindings
      ---NOTE: If given `false` then the plugin won't create any mappings
      mappings = {
        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        ---Extra mapping; `gco`, `gcO`, `gcA`
        extra = true,
      },
      ---Function to call before (un)comment
      pre_hook = nil,
      ---Function to call after (un)comment
      post_hook = nil,
    }
  },
  -- Comment.nvim }}}
  -- auto-dark-mode.nvim {{{
  {
    "f-person/auto-dark-mode.nvim",
    event = "VeryLazy",
    cond = doWhistles,
    enabled = false,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", nil, {})
        vim.cmd.colorscheme = "catppuccin-macchiato"
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", nil, {})
        vim.cmd.colorscheme = "catppuccin-latte"
      end,
    },
  },
  -- auto-dark-mode.nvim }}}
}
require("lazy").setup({
  spec = plugins,
  -- Configure any other settings here. See the documentation for more details.
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
  change_detection = { notify = true },
})
