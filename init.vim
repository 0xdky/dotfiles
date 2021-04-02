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

" Maximize current window
func! Maximize()
    if winnr() != winnr('$')|resize|endif
endfunc
nnoremap <silent> ww :call Maximize() <CR>

" Close other window
func! CloseOther()
    if winnr() != winnr('$')|close|endif
endfunc
nnoremap <silent> qq :call CloseOther() <CR>

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

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

Plug 'fxn/vim-monochrome'

if has("nvim-0.5.0")
    " Instructions from: https://sharksforarms.dev/posts/neovim-rust/

    " Collection of common configurations for the Nvim LSP client
    Plug 'neovim/nvim-lspconfig'

    " Extensions to built-in LSP, for example, providing type inlay hints
    Plug 'tjdevries/lsp_extensions.nvim'

    " Autocompletion framework for built-in LSP
    Plug 'nvim-lua/completion-nvim'

    " Diagnostic navigation and settings for built-in LSP
    Plug 'nvim-lua/diagnostic-nvim'

    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
else
    " Use release branch (recommend)
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
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

" neovim lsp configuration
if has("nvim-0.5.0")
    " Instructions from: https://sharksforarms.dev/posts/neovim-rust/
    " Configure LSP
    " https://github.com/neovim/nvim-lspconfig#rust_analyzer
 
lua <<EOF

    -- nvim_lsp object
local nvim_lsp = require'lspconfig'

-- function to attach completion and diagnostics
-- when setting up lsp
local on_attach = function(client)
    require'completion'.on_attach(client)
    require'diagnostic'.on_attach(client)
end

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({ on_attach=on_attach })

-- Enable ccls
nvim_lsp.ccls.setup({cmd={"ccls"}})

-- Enable gopls
nvim_lsp.gopls.setup {
    cmd = {"gopls", "serve"},
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
}

EOF

    " Trigger completion with <Tab>
    inoremap <silent><expr> <TAB>
		\ pumvisible() ? "\<C-n>" :
		\ <SID>check_back_space() ? "\<TAB>" :
		\ completion#trigger_completion()

    function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

    " Code navigation shortcuts
    nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
    nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
    nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
    nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
    nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
    nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
    nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
    nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
    nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
endif

set rtp+=/usr/local/opt/fzf
