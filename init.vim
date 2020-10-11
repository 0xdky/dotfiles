" vim:sw=4
" Usage: ln -s ~/.dotfiles/init.vim ~/.config/nvim/init.vim

set sw=8
set wrap
set smarttab
set nowrapscan
set ignorecase
set background=dark

" Get an emacs like modeline always
set laststatus=2
set statusline=%t\ %R\ %m\ %P\ %=\ [%04l/%04L,%04v]

" visual bell
set vb t_vb=""

" Handle error when opening files: https://github.com/vim/vim/issues/2049
set mmp=5000

" Setup diff mode with ignore whitespace
func! DiffSetup()
    set wrap
    set nofoldenable foldcolumn=0
    wincmd =
    wincmd w
    set nofoldenable foldcolumn=0
    set wrap
    set diffopt+=iwhite
endfunc

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'fxn/vim-monochrome'

if has('nvim-v0.5.0')
    Plug 'neovim/nvim-lsp'
endif

" Initialize plugin system
call plug#end()

" set termguicolors
colorscheme monochrome

if has('nvim')
    " lua require'nvim_lsp'.gopls.setup{}
    " lua require'nvim_lsp'.pyls.setup{}
    " lua require'nvim_lsp'.ccls.setup{}
else
    autocmd InsertEnter,InsertLeave * set cul!
endif

" Fuzzy completions
set rtp+=/usr/local/opt/fzf

" Call the customizations in diff mode
if &diff
    highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
    highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
    highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
    highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

    autocmd VimEnter * call DiffSetup()

    " Update diff on save
    autocmd BufWritePost * diffupdate
    autocmd VimResized * wincmd =
endif

hi StatusLine guifg=#333333 guibg=silver
