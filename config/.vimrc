set number
set tabstop=4
set expandtab
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
"autocmd BufWritePost *.go silent! %!gofmt"

"TODO need to figure out how to run a function on the buffer before writing to
"file.
augroup restore_cursor_on_write_after_format
  autocmd! 
  autocmd BufWritePost *.go call FormatGoCode()
augroup END

function! FormatGoCode()
  let l:saved_view = winsaveview() " Save the current view (including cursor position)
  " Execute your desired command here. For example, to run an external command:
  silent! %!gofmt
  " Or, to run a Vim command:
  " normal G
  call winrestview(l:saved_view) " Restore the saved view
endfunction
