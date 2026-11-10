# Neovim set up as a lightweight VS Code replacement, mainly for Ansible and
# Jinja2 work, with git integration. Plugins come from nixpkgs (no plugin
# manager, nothing fetched at runtime) and language servers are put on
# neovim's PATH only, so they don't leak into the rest of the user environment.
{ pkgs, ... }:

{
  # Opened from neovim with <leader>gg. The nvim-remote preset makes "edit
  # file" in lazygit open it in the surrounding neovim rather than a nested one.
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim-remote";
      gui.theme.selectedLineBgColor = [ "reverse" ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # LSPs / linters available to neovim only.
    extraPackages = with pkgs; [
      ansible-language-server
      ansible-lint # picked up by ansible-language-server for diagnostics
      yaml-language-server
      nil # nix
    ];

    plugins = with pkgs.vimPlugins; [
      # Look
      catppuccin-nvim # macchiato, matching the rest of the desktop
      lualine-nvim
      nvim-web-devicons
      which-key-nvim # shows available keybindings, like the VS Code palette

      # Syntax: yaml, jinja, ansible-ish filetypes, nix, ...
      nvim-treesitter.withAllGrammars

      # LSP + completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets

      # Navigation (explorer, Ctrl+P / Ctrl+Shift+F equivalents)
      plenary-nvim
      telescope-nvim
      nvim-tree-lua

      # Git
      gitsigns-nvim # gutter signs, hunk stage/reset/blame
      vim-fugitive # :Git status/commit/push/blame
      diffview-nvim # side-by-side diffs and file history
      lazygit-nvim # lazygit in a floating window

      # Editing
      comment-nvim
      nvim-autopairs
    ];

    initLua = ''
      vim.g.mapleader = " "

      local o = vim.opt
      o.number = true
      o.relativenumber = true
      o.mouse = "a"
      o.clipboard = "unnamedplus"
      o.termguicolors = true
      o.signcolumn = "yes"
      o.cursorline = true
      o.expandtab = true
      o.shiftwidth = 2
      o.tabstop = 2
      o.ignorecase = true
      o.smartcase = true
      o.splitright = true
      o.splitbelow = true
      o.undofile = true
      o.updatetime = 250

      -- Swiss QWERTZ: [ and ] need AltGr, so ö/ä stand in for them everywhere
      -- (öh/äh = prev/next hunk, öx/äx = conflicts, ...). remap so they reach
      -- plugin and buffer-local ]/[ mappings too.
      vim.keymap.set({ "n", "x", "o" }, "ö", "[", { remap = true })
      vim.keymap.set({ "n", "x", "o" }, "ä", "]", { remap = true })
      -- Better aligned diffs (histogram + line matching), char-level inline changes
      o.diffopt = "internal,filler,closeoff,indent-heuristic,inline:char,linematch:60,algorithm:histogram"

      require("catppuccin").setup({ flavour = "macchiato" })
      vim.cmd.colorscheme("catppuccin")
      require("lualine").setup({
        options = { theme = "catppuccin-macchiato" },
        sections = {
          lualine_b = {
            "branch",
            {
              "diff",
              -- reuse gitsigns' counts instead of lualine running git itself
              source = function()
                local s = vim.b.gitsigns_status_dict
                if s then
                  return { added = s.added, modified = s.changed, removed = s.removed }
                end
              end,
            },
            "diagnostics",
          },
        },
      })
      require("which-key").setup({})
      require("which-key").add({
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks" },
      })
      require("nvim-autopairs").setup({})
      require("Comment").setup({})

      -- Filetypes: Ansible files get their own type so ansible-language-server
      -- attaches to them (and not to every yaml file); *.j2 is Jinja2.
      vim.filetype.add({
        extension = { j2 = "jinja", jinja = "jinja", jinja2 = "jinja" },
        pattern = {
          [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
          [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
          [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
          [".*/roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
          [".*/roles/.*/vars/.*%.ya?ml"] = "yaml.ansible",
          [".*/group_vars/.*"] = "yaml.ansible",
          [".*/host_vars/.*"] = "yaml.ansible",
          [".*/playbook[^/]*%.ya?ml"] = "yaml.ansible",
        },
      })
      -- yaml.ansible has no grammar of its own; reuse the yaml one.
      vim.treesitter.language.register("yaml", "yaml.ansible")

      -- Treesitter highlighting (grammars are provided by nix)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "path" }, { name = "buffer" } }
        ),
      })

      -- LSP (neovim 0.11+ API; server defaults come from nvim-lspconfig)
      local caps = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = caps })
      vim.lsp.config("ansiblels", {
        filetypes = { "yaml.ansible" },
        settings = {
          ansible = {
            validation = { lint = { enabled = true, path = "ansible-lint" } },
          },
        },
      })
      vim.lsp.config("yamlls", {
        -- ansible files are handled by ansiblels
        filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
      })
      vim.lsp.enable({ "ansiblels", "yamlls", "nil_ls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
        end,
      })
      vim.diagnostic.config({ virtual_text = true, severity_sort = true })

      -- Explorer + fuzzy finding (VS Code: Ctrl+B, Ctrl+P, Ctrl+Shift+F)
      -- Changed files are coloured and get git icons; parent folders of changed
      -- files are highlighted too. Press C in the tree to show only changed files.
      require("nvim-tree").setup({
        on_attach = function(buf)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(buf)
          -- + enters a folder (pairs with - to go up); Ctrl+] is hard on QWERTZ
          vim.keymap.set("n", "+", api.tree.change_root_to_node,
            { buffer = buf, desc = "nvim-tree: Enter folder" })
        end,
        git = { enable = true, show_on_dirs = true, show_on_open_dirs = true },
        renderer = {
          highlight_git = "name",
          icons = { show = { git = true }, git_placement = "after" },
        },
      })
      local tb = require("telescope.builtin")
      local km = vim.keymap.set
      km("n", "<C-b>", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })
      km("n", "<C-p>", tb.find_files, { desc = "Find files" })
      km("n", "<C-S-f>", tb.live_grep, { desc = "Search in files" })
      km("n", "<leader>ff", tb.find_files, { desc = "Find files" })
      km("n", "<leader>fg", tb.live_grep, { desc = "Grep" })
      km("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
      km("n", "<leader>fd", tb.diagnostics, { desc = "Diagnostics" })

      -- Git
      require("gitsigns").setup({
        current_line_blame = true, -- faint "author, date - message" after the line
        current_line_blame_opts = { delay = 500 },
        on_attach = function(buf)
          local gs = require("gitsigns")
          local function m(keys, fn, desc, mode)
            km(mode or "n", keys, fn, { buffer = buf, desc = desc })
          end
          m("]h", function() gs.nav_hunk("next") end, "Next hunk")
          m("[h", function() gs.nav_hunk("prev") end, "Previous hunk")
          -- stage_hunk on an already staged hunk unstages it
          m("<leader>hs", gs.stage_hunk, "Stage/unstage hunk")
          m("<leader>hr", gs.reset_hunk, "Reset hunk")
          m("<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection", "v")
          m("<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection", "v")
          m("<leader>hS", gs.stage_buffer, "Stage file")
          m("<leader>hR", gs.reset_buffer, "Reset file")
          m("<leader>hp", gs.preview_hunk, "Preview hunk (popup)")
          m("<leader>hi", gs.preview_hunk_inline, "Preview hunk (inline)")
          m("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
          m("<leader>hB", gs.blame, "Blame file")
          m("<leader>hd", gs.diffthis, "Diff file against index")
          m("<leader>hw", gs.toggle_word_diff, "Toggle word diff")
          m("<leader>hl", gs.toggle_linehl, "Toggle line highlight")
          m("<leader>ht", gs.toggle_current_line_blame, "Toggle inline blame")
          m("ih", gs.select_hunk, "Select hunk", { "o", "x" })
        end,
      })

      -- Merge conflicts: during a merge/rebase <leader>gd opens a 3-way view
      -- (ours | result | theirs). In it: ]x/[x = next/prev conflict,
      -- <leader>co/ct/cb/ca = take ours/theirs/base/all, dx = drop the conflict.
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = { merge_tool = { layout = "diff3_mixed" } },
      })

      local function diffview_toggle(args)
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen " .. (args or ""))
        end
      end
      km("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
      km("n", "<leader>gf", tb.git_status, { desc = "Changed files" })
      km("n", "<leader>gb", tb.git_branches, { desc = "Branches" })
      km("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status (fugitive)" })
      km("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
      km("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
      km("n", "<leader>gd", function() diffview_toggle() end, { desc = "Toggle diff view (uncommitted)" })
      km("n", "<leader>gm", function() diffview_toggle("origin/main...HEAD") end, { desc = "Toggle diff vs main" })
      km("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
      km("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo history" })
      km("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" })
    '';
  };
}
