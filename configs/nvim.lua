local g = vim.g
local o = vim.opt
local vo = vim.o
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- local lazyrepo = "ssh://git@github.com/folke/lazy.nvim.git"
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
o.rtp:prepend(lazypath)

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
"expr" -- v---using-the-expression-below--v
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
vim.api.nvim_set_hl(0, "Comment", { italic = true })
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })
local function map(mode, lhs, rhs, desc, opts)
  local options = { noremap = true, silent = true, desc = desc }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end
map({ 'n', 'v' }, '<leader>q', '<cmd>q<CR>', nil, { remap = true, silent = true })
map({ 'n', 'v' }, '<leader>Q', '<cmd>qa<CR>', nil, { remap = true, silent = true })
map({ 'n', 'v' }, '<leader>w', '<cmd>w<CR>', nil, { remap = true, silent = true })
map({ 'n', 'v' }, '<leader>x', '<cmd>x<CR>', nil, { remap = true, silent = true })
map({ 'n', 'v' }, 'gh', '^', nil, { remap = true, silent = true })
map({ 'n', 'v' }, 'gl', '$', nil, { remap = true, silent = true })
map({ 'n', "v" }, '<leader>b', '<Nop>', nil, { desc = 'Buffers' })
map({ "n", "v" }, '<leader>bn', '<cmd>bnext<CR>', 'Go to next buffer', nil)
map({ "n", "v" }, '<leader>bp', '<cmd>bprevious<CR>', 'Go to previous buffer', nil)
map({ "n", "v" }, '<leader>bd', '<cmd>bdelete<CR>', 'Delete buffer', nil)
map({ "n", "v" }, '<leader>s', '<Nop>', 'Splits')
map({ "n", "v" }, '<leader>ss', '<C-w>s', 'Split horizontally', nil)
map({ "n", "v" }, '<leader>sv', '<C-w>v', 'Split vertically', nil)
map({ "n", "v" }, '<leader>sh', '<C-w>h', 'Move to left split', nil)
map({ "n", "v" }, '<leader>sj', '<C-w>j', 'Move to bottom split', nil)
map({ "n", "v" }, '<leader>sk', '<C-w>k', 'Move to top split', nil)
map({ "n", "v" }, '<leader>sl', '<C-w>l', 'Move to right split', nil)
map({ "n", "v" }, '<leader>sc', '<C-w>c', 'Close split', nil)
map({ "n", "v" }, '<leader>so', '<C-w>o', 'Close all splits except current', nil)
-- map option+shift+brackets to cycle tabs
map({ "n", "v" }, '<A-S-[>', '<cmd>tabprevious<CR>', 'Go to previous tab', nil)
map({ "n", "v" }, '<A-S-]>', '<cmd>tabnext<CR>', 'Go to next tab', nil)
map({ "n", "v" }, '<A-w>', '<cmd>tabclose<CR>', 'Close tab', nil)

-- https://github.com/pondodev/dotfiles/blob/61e476a5d6ee4d9e8d413a54778b7710e7e1aff4/nvim/init.lua#L30-L37
local shell = vim.fn.system({ "which", "zsh" })
local nullsToCull = 1
o.shell = string.sub(shell, 1, string.len(shell) - nullsToCull)
if o.shell == "" or o.shell == nil then
  shell = vim.fn.system({ "which", "bash" })
  o.shell = string.sub(shell, 1, string.len(shell) - nullsToCull)
end


vim.api.nvim_create_autocmd('LspAttach', {
  desc = "LSP actions",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local keyopts = { buffer = args.buf }
    if client == nil then
      return
    end
    if client.capabilities.textDocument then
      if client.capabilities.textDocument.implementation then
        map('n', 'gi', vim.lsp.buf.implementation, 'Jump to implementation', keyopts)
      end
      -- if client.supports_method('textDocument/completion') then
      --   vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true }) -- <-evil
      -- end

      -- if client.server_capabilities.documentFormattingProvider then
      --   vim.api.nvim_create_autocmd('BufWritePre', {
      --     buffer = args.buf,
      --     callback = function()
      --       vim.lsp.buf.format({ async = true, bufnr = args.buf, id = client.id })
      --     end,
      --   })
      -- end

      if client.capabilities.textDocument.definition then
        map('n', 'gd', vim.lsp.buf.definition, 'Jump to definition', keyopts)
      end
      if client.capabilities.textDocument.declaration then
        map('n', 'gD', vim.lsp.buf.declaration, 'Jump to declaration', keyopts)
      end
      if client.capabilities.textDocument.hover then
        map('n', 'K', "<cmd>lua vim.lsp.buf.hover({ border = { '╭', '─' ,'╮', '│', '╯', '─', '╰', '│' } })<CR>",
          'Show symbol info in a floating window',
          keyopts)
      end
      -- map('n', '<leader>a', "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>", "Show code actions", keyopts)
      -- map('n', 'K', "<cmd>lua vim.cmd.RustLsp({'hover', 'actions'})<CR>", "Show hover actions", keyopts)
      if client.capabilities.textDocument.references then
        map('n', 'gr', vim.lsp.buf.references, 'Find references to the symbol under the cursor', keyopts)
      end
      if client.capabilities.textDocument.rename then
        map('n', '<leader>lr', vim.lsp.buf.rename, 'Rename the symbol under the cursor', keyopts)
      end
      if client.capabilities.textDocument.signatureHelp then
        map('n', 'gs', vim.lsp.buf.signature_help, 'Show signature help in a floating window', keyopts)
      end
      if client.capabilities.textDocument.typeDefinition then
        map('n', 'go', vim.lsp.buf.type_definition, 'Jump to type definition', keyopts)
      end
      if client.capabilities.textDocument.codeAction then
        map('n', '<leader>a', vim.lsp.buf.code_action, 'Show code actions for the symbol under the cursor',
          keyopts)
      end
    end
    if client.server_capabilities then
      if client.server_capabilities.documentFormattingProvider then
        map('n', '<leader>lf', "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", 'Format the current buffer',
          keyopts)
      end
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true)
      end
    end
  end
})


vim.lsp.config('*', {
  root_markers = { '.git', '.jj', '.devenv', '.envrc' },
})
vim.lsp.config("emmylua_ls", {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.emmyrc.json',
    '.luacheckrc',
    '.git',
  },
  workspace_required = false,
})
vim.lsp.enable('emmylua_ls')
vim.lsp.config("nil_ls", {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  workspace_required = false,
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
})
vim.lsp.enable('nil_ls')
vim.lsp.config("zls", {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'zls.json', 'build.zig' },
  workspace_required = false,
  settings = {
    zls = {
      semantic_tokens = "partial",
      enable_build_on_save = true,
    },
  },
})
vim.lsp.enable('zls')
vim.lsp.config("rust_analyzer", {
  capabilities = {
    experimental = { serverStatusNotification = true },
  },
  commands = {
    ExpandMacro =
        function()
          vim.lsp.buf_request_all(0,
            "rust-analyzer/expandMacro",
            vim.lsp.util.make_position_params(0, "utf-8"),
            vim.print)
        end,
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
})
vim.lsp.enable('rust_analyzer')
if g.neovide then
  vo.guifont = "Maple Mono:h14"
  -- Helper function for transparency formatting
  -- local alpha = function()
  --   return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8)))
  -- end
  -- g:neovide_opacity should be 0 if you want to unify transparency of content and title bar.
  g.neovide_opacity = 0.8
  g.neovide_window_blurred = true
  g.transparency = 0.8
  -- vim.g.neovide_background_color = "#000000" .. alpha()
end
local ts_langs = { "regex", "rust", "zig", "go", "nix", "c", "lua", "vim", "vimdoc", "javascript", "typescript", "html",
  "julia",
  "css", "markdown", "nushell" }
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

local rustaceanvim = {
  'mrcjkb/rustaceanvim',
  version = '^8', -- Recommended
  lazy = false,   -- This plugin is already lazy
}
local vcsigns = {
  'algmyr/vcsigns.nvim',
  config = function()
    require('vcsigns').setup {
      target_commit = 1, -- Nice default for jj with new+squash flow.
    }
    map('n', '[r', function() require('vcsigns.actions').target_older_commit(0, vim.v.count1) end,
      'Move diff target back')
    map('n', ']r', function() require('vcsigns.actions').target_newer_commit(0, vim.v.count1) end,
      'Move diff target forward')
    map('n', '[c', function() require('vcsigns.actions').hunk_prev(0, vim.v.count1) end, 'Go to previous hunk')
    map('n', ']c', function() require('vcsigns.actions').hunk_next(0, vim.v.count1) end, 'Go to next hunk')
    map('n', '[C', function() require('vcsigns.actions').hunk_prev(0, 9999) end, 'Go to first hunk')
    map('n', ']C', function() require('vcsigns.actions').hunk_next(0, 9999) end, 'Go to last hunk')
    map('n', '<leader>su', function() require('vcsigns.actions').hunk_undo(0) end, 'Undo hunks under cursor')
    map('v', '<leader>su', function() require('vcsigns.actions').hunk_undo(0) end, 'Undo hunks in range')
    map('n', '<leader>sd', function() require('vcsigns.actions').toggle_hunk_diff(0) end,
      'Show hunk diffs inline in the current buffer')
    map('n', '<leader>sf', function() require('vcsigns.fold').toggle(0) end, 'Fold outside hunks')
  end,
}
local nvim_ufo = {
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
    vo.foldcolumn = '1' -- '0' is not bad
    vo.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
    vo.foldlevelstart = -1
    vo.foldenable = true
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
}
local vim_dim = {
  'jeffkreeftmeijer/vim-dim',
  -- event = 'VeryLazy',
  -- cond = not doWhistles,
  lazy = false,
  config = function()
    vo.termguicolors = false -- enable 24-bit color support
    vim.cmd.colorscheme = 'dim'
  end,
}
local blink = {
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
  -- build = 'nix run --accept-flake-config .#build-plugin',

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
}
local copilot = {
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
}
local codecompanion = {
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
}
local lazy = {
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
}
local catppuccin = {
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
    transparent_background = g.neovide and false or true,
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
}
local fzf_lua = {
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
}
local crates = {
  "saecki/crates.nvim",
  ft = { "rust", "toml" },
  config = function()
    require("crates").setup({
      popup = {
        border = "rounded",
      },
    })
  end,
}
local which_key = {
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
}
local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  ft = ts_langs,
  config = function()
    local configs = require("nvim-treesitter")
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
}
local noice = {
  "folke/noice.nvim",
  event = "VeryLazy",
  cond = function(_LazyPlugin)
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
}
local lualine = {
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
}
local neotree = {
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
}
local compile_mode = {
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
    g.compile_mode = {
      -- The string to show in the compile prompt as a default.
      -- For an empty prompt, you can use:
      -- default_command = "",
      -- To use different defaults based on filetype, you can use a table:
      -- :h compile_mode.default_command
      default_command = {
        --   python = "python %",
        --   lua = "lua %",
        --   javascript = "bun %",
        --   typescript = "bun %",
        c = "zig cc -o %:r % && ./%:r",
        --   cpp = "cc -std=c++23 -o %:r % && ./%:r",
        --   java = "javac % && java %:r",
        --   go = "go run %",
        rust = "cargo build",
        zig = "zig build",
      },
      -- A function which returns the default command string is also supported:
      -- default_command = function()
      --   local filetype = vim.bo.filetype
      --   if filetype == "python" then
      --     return "python %"
      --   else
      --     return "make -k "
      --   end
      -- end,
      -- Use `baleia` for parsing ANSI escape codes in the output.
      -- :h compile_mode.baleia_setup
      baleia_setup = false,
      -- Expand commands, like `:!` (e.g. `:Compile echo %`)
      -- :h compile_mode.bang_expansion
      bang_expansion = true,
      -- Configure additional error regexes.
      -- :h compile-mode-errors
      error_regexp_table = {},
      -- List of filename regexes to ignore errors from.
      -- :h compile-mode.error_ignore_file_list
      error_ignore_file_list = {},
      -- The minimum error level to jump to.
      -- :h compile-mode.error_threshold
      error_threshold = require("compile-mode").level.WARNING,
      -- Automatically jump to the first error.
      -- :h compile-mode.auto_jump_to_first_error
      auto_jump_to_first_error = false,
      -- How long to highlight an error's location when jumping to it.
      -- :h compile-mode.error_locus_highlight
      error_locus_highlight = 500,
      -- Use Neovim diagnostics instead of opening the compilation buffer.
      -- :h compile-mode.use_diagnostics
      use_diagnostics = true,
      -- Default to calling `:Compile` for `:Recompile`
      -- when there's no previous command.
      -- :h compile-mode.recompile_no_fail
      recompile_no_fail = false,
      -- Ask to save unsaved buffers before compiling.
      -- :h compile-mode.ask_about_save
      ask_about_save = true,
      -- Ask to interrupt already running commands.
      -- :h compile-mode.ask_to_interrupt
      ask_to_interrupt = true,
      -- The name for the compilation buffer.
      -- :h compile-mode.buffer_name
      buffer_name = "*compilation*",
      -- The format for the time information
      -- at the top of the compilation buffer
      -- :h compile-mode.time_format
      time_format = "%a %b %e %H:%M:%S",
      -- List of regexes to hide from the output.
      -- :h compile-mode.hidden_output
      hidden_output = {},
      -- A table of environment variables to pass to commands.
      -- :h compile-mode.environment
      environment = nil,
      -- Clear all environment variables for each command.
      -- :h compile-mode.clear_environment
      clear_environment = false,
      -- Fix compilation for plugins like `nvim-cmp`.
      -- :h compile-mode.input_word_completion
      input_word_completion = false,
      -- Hide the compliation buffer.
      -- :h compile-mode.hidden_buffer
      hidden_buffer = false,
      -- Automatically focus the compilation buffer.
      -- :h compile-mode.focus_compilation_buffer
      focus_compilation_buffer = false,
      -- Automatically move the cursor to the end of the compilation buffer.
      -- :h compile-mode.auto_scroll
      auto_scroll = true,
      -- Jump back past the end/beginning of the errors
      -- with `:NextError`/`:PrevError`
      -- :h compile-mode.use_circular_error_navigation
      use_circular_error_navigation = false,
      -- Print debug information.
      -- :h compile-mode.debug
      debug = false,
      -- Use a pseudo terminal for command execution.
      -- :h compile-mode.use_pseudo_terminal
      use_pseudo_terminal = false,
    }
  end
}
local hardtime = {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  enabled = false,
  opts = {}
}
local precognition = {
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
}
local hunk = {
  "julienvincent/hunk.nvim",
  cmd = { "DiffEditor" },
  config = function()
    require("hunk").setup()
  end,
}
local auto_dark_mode = {
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
}
require("lazy").setup(
  {
    auto_dark_mode,
    blink,
    catppuccin,
    -- codecompanion,
    compile_mode,
    -- copilot,
    crates,
    fzf_lua,
    hardtime,
    hunk,
    lazy,
    lualine,
    neotree,
    noice,
    -- nvim_ufo,
    precognition,
    -- rustaceanvim,
    treesitter,
    -- vcsigns,
    vim_dim,
    which_key,
  },
  {
    -- Configure any other settings here. See the documentation for more details.
    -- automatically check for plugin updates
    checker = {
      enabled = true,
      notify = true,
      frequency = 3600,
    },
    git = {
      timeout = 480,
      -- url_format = "ssh://git@github.com/%s.git",
      url_format = "https://github.com/%s.git",
    },
    change_detection = {
      enabled = true,
      notify = true,
    },
  })
