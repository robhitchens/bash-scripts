syntax on
set showmatch
set number
"set tabstop=4
set ts=4 sw=4
set expandtab
set ruler
set updatetime=100
colorscheme elflord

"TODO may just get rid of this plugin, not really using"
call plug#begin()

"Japanese input method plugin"
"Plug 'tyru/eskk.vim'
"Material color themes"
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
"Rainbow Parentheses"
Plug 'junegunn/rainbow_parentheses.vim'
"Git gutter"
Plug 'airblade/vim-gitgutter', { 'branch': 'main' }
call plug#end()

let g:material_theme_style = 'ocean'
"colorscheme material"

let g:gitgutter_highlight_lines = 0
let g:gitgutter_highlight_linenrs = 0
let g:gitgutter_realtime = 1
let g:gitgutter_live_mode = 1

augroup restore_cursor_on_write_after_format
  autocmd! 
  autocmd BufWritePre *.go call FormatGoCode()
  autocmd BufWritePre *.sh call FormatShellCode()
augroup END

function! FormatGoCode()
  let l:saved_view = winsaveview() " Save the current view (including cursor position)
  " Execute your desired command here. For example, to run an external command:
  silent! %!gofmt
  " Or, to run a Vim command:
  " normal G
  call winrestview(l:saved_view) " Restore the saved view
endfunction

function! FormatShellCode()
    let l:saved_view = winsaveview()
    silent! %!shfmt
    call winrestview(l:saved_view)
endfunction

" TODO add a script to bash scripts for installing vim plugin if not
" installed.
" vim-plug: Vim plugin manager
" ============================
"
" 1. Download plug.vim and put it in 'autoload' directory
"
"   # Vim
"   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
"   # Neovim
"   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
