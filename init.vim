" vim:sw=4
set sw=8
set wrap
set smarttab
set nowrapscan
set ignorecase
set background=light

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
    " set diffopt+=iwhite
endfunc

" Call the customizations in diff mode
if &diff
    autocmd VimEnter * call DiffSetup()
    " Update diff on save
    autocmd BufWritePost * diffupdate
    autocmd VimResized * wincmd =
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

Plug 'fxn/vim-monochrome'

if has('nvim-v0.5.0')
    Plug 'neovim/nvim-lsp'
endif

" Initialize plugin system
call plug#end()

if has('nvim')
    " lua require'nvim_lsp'.gopls.setup{}
    " lua require'nvim_lsp'.pyls.setup{}
    " lua require'nvim_lsp'.ccls.setup{}
else
    autocmd InsertEnter,InsertLeave * set cul!
endif

" Fuzzy completions
set rtp+=/usr/local/opt/fzf

set termguicolors
" colorscheme monochrome

" hi Normal guifg=#212121 guibg=white
hi StatusLine guifg=#333333 guibg=silver
