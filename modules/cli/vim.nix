{ den, ... }:
{
  den.aspects.cli.vim = {
    meta.description = "Vim, installed per user with an hjem-managed vimrc";

    hjem = { pkgs, ... }: {
      # vim-full has the feature-rich build (clipboard, python, etc.) enabled;
      # plain `pkgs.vim` ships with most optional deps disabled.
      packages = [ pkgs.vim-full ];

      # Relative to the user's home directory
      files.".vimrc".text = ''
        set nocompatible
        set number relativenumber
        set expandtab shiftwidth=2 softtabstop=2 tabstop=2
        set ignorecase smartcase incsearch hlsearch
        set undofile undodir=~/.vim/undo//
        set wildmenu wildmode=longest:full,full
        syntax enable
        filetype plugin indent on
      '';

      # ~/.vim for colours, spellfiles, snippets…
      # files.".vim/colors/mytheme.vim".source = ./files/mytheme.vim;
      # files.".vim/undo".type = "directory";
    };
  };
}
