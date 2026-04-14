{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraPackages = with pkgs; [
      gcc
      gnumake
      nodejs
      python3
      ripgrep
      fd
      nil
      nixd
      lua-language-server
      bash-language-server
      vscode-langservers-extracted
      typescript-language-server
      pyright
      gopls
      rust-analyzer
      zls
      java-language-server
      marksman
      yaml-language-server
      prettierd
      beautysh
      shellcheck
      stylua
      selene
      taplo
      nodePackages.typescript
      lazygit
      playerctl
    ];
  };

  xdg.configFile."nvim/init.lua".text = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      spec = {
        {
          "LazyVim/LazyVim",
          import = "lazyvim.plugins",
          opts = {
            colorscheme = "default",
            news = {
              lazyvim = false,
              neovim = false,
            },
          },
        },
        { import = "lazyvim.plugins.extras.editor.harpoon2" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.yaml" },
        { import = "lazyvim.plugins.extras.lang.toml" },
        { import = "lazyvim.plugins.extras.lang.docker" },
        { import = "lazyvim.plugins.extras.lang.go" },
        { import = "lazyvim.plugins.extras.lang.rust" },
        { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.nix" },
        { import = "lazyvim.plugins.extras.lang.zig" },
        { import = "lazyvim.plugins.extras.editor.navic" },
        { import = "lazyvim.plugins.extras.editor.mini-ai" },
        { import = "lazyvim.plugins.extras.util.project" },
        { import = "lazyvim.plugins.extras.coding.mini-surround" },
        { import = "lazyvim.plugins.extras.coding.minipairs" },
      },
      defaults = {
        lazy = true,
        version = "*",
      },
      performance = {
        cache = {
          enabled = true,
        },
        rtp = {
          disabled_plugins = {
            "gzip",
            "matchit",
            "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })

    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
  '';
}
