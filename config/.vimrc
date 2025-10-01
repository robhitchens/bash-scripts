syntax on
set showmatch
set number
"set tabstop=4
set ts=4 sw=4
set expandtab
set ruler
colorscheme elflord

"TODO may just get rid of this plugin, not really using"
call plug#begin()

"Japanese input method plugin"
"Plug 'tyru/eskk.vim'
"Material color themes"
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
call plug#end()

let g:material_theme_style = 'ocean'
"colorscheme material"

augroup restore_cursor_on_write_after_format
  autocmd! 
  autocmd BufWritePre *.go call FormatGoCode()
augroup END

function! FormatGoCode()
  let l:saved_view = winsaveview() " Save the current view (including cursor position)
  " Execute your desired command here. For example, to run an external command:
  silent! %!gofmt
  " Or, to run a Vim command:
  " normal G
  call winrestview(l:saved_view) " Restore the saved view
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
