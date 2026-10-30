syntax on
set showmatch
set nonumber
set expandtab
set ts=2 sw=2
set ruler
set updatetime=50
set mouse=nv
set ignorecase
set smartcase

call plug#begin()
"TODO may just get rid of this plugin, not really using"
"Japanese input method plugin"
"Plug 'tyru/eskk.vim'
"Material color themes"
"Plug 'kaicataldo/material.vim', { 'branch': 'main' }
"Solarized color themes
"Plug 'altercation/vim-colors-solarized', { 'branch' : 'master' }
"Rainbow Parentheses"
Plug 'junegunn/rainbow_parentheses.vim'
"Git gutter"
Plug 'airblade/vim-gitgutter', { 'branch': 'main' }
"Diff unit syntax"
Plug 'rickhowe/diffunitsyntax', { 'branch': 'master'}
call plug#end()

"let g:material_theme_style = 'ocean'
"colors are :
"default,palenight,ocean,lighter,darker,default-community,palenight-community,ocean-community,lighter-community,darker-community
"colorscheme material"

" Solarized configuration
"set background=dark
"let g:solarized_termcolors=256

let g:gitgutter_highlight_lines = 0
let g:gitgutter_highlight_linenrs = 0
let g:gitgutter_realtime = 1
let g:gitgutter_live_mode = 1

augroup restore_cursor_on_write_after_format
  autocmd! 
  autocmd BufWritePre *.go call FormatGoCode()
  autocmd BufWritePre *.sh call FormatShellCode()
  autocmd BufWritePre *.json call FormatJson()
augroup END

augroup QuickfixHighlight
  autocmd!
  autocmd FileType qf runtime! syntax/qf.vim
  autocmd FileType qf highlight QuickFixLine ctermbg=DarkBlue ctermfg=White guibg=#000087 guifg=#FFFFFF
augroup END

function! XmqWrite()
    let l:saved_view = winsaveview()
    silent! %!xmq to-xml | xmlstarlet fo
    write
    silent! %!xmq
    call winrestview(l:saved_view)
endfunction

function! XmqRead()
    let l:saved_view = winsaveview()
    silent! %!xmq
    call winrestview(l:saved_view)
    set syntax=xmq
endfunction

function! XmqToXml()
    let l:saved_view = winsaveview()
    silent! %!xmq to-xml | xmlstarlet fo
    call winrestview(l:saved_view)
    set syntax=xml
endfunction

function! MarkdownWrite()
    let l:saved_view = winsaveview()
    silent! %!pandoc -t commonmark_x
    write
    call winrestview(l:saved_view)
endfunction

function! MarkdownRead()
    let l:saved_view = winsaveview()
    silent! %!pandoc -t commonmark_x
    call winrestview(l:saved_view)
endfunction

function! RunIOFM()
  let l:saved_view = winsaveview()
  silent! %!iofm
  call winrestview(l:saved_view)
endfunction

function! RunIOFMClean()
  let l:saved_view = winsaveview()
  silent! %d | .!iofm
  call winrestview(l:saved_view)
endfunction

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

function! FormatJson()
    let l:saved_view = winsaveview()
    silent! %!jq -M '.'
    call winrestview(l:saved_view)
endfunction

" TODO could collapse the below two functions and base type on file extension
function! GoSymbols()
  let l:saved_view = winsaveview()
  vim /\v^(func|var|type) / %
  call winrestview(l:saved_view)
  copen
endfunction

function! BashSymbols()
  let l:saved_view = winsaveview()
  vim /\v^(function|readonly|.*\(\)) / %
  call winrestview(l:saved_view)
  copen
endfunction

function! GitDiff()
  let l:saved_view = winsaveview()
  %d|r!git diff
  call winrestview(l:saved_view)
endfunction

command Xmqw call XmqWrite()
command Xmqr call XmqRead()
command XmqX call XmqToXml()
command Mdw call MarkdownWrite()
command Mdr call MarkdownRead()
command Todo vim /\vTODO|FIXME|BUG/ % | copen
command Gsym call GoSymbols()
command Bsym call BashSymbols()
command Msym call MuleSymbols()
command Iofm call RunIOFM()
command Iofmref call RunIOFMClean()
command ReplaceUuids %s/{uuid}/\=substitute(system('uuidgen'), '\n', '', 'g')/gc
command Gitd call GitDiff()
command -nargs=* Tdifftool tab term git difftool <args>
command -nargs=* Ndifftool term git difftool <args>
command -nargs=* Ml .!mule <args>

cabbrev xw Xmqw
cabbrev xr Xmqr
cabbrev xx XmqX
cabbrev mw Mdw
cabbrev mr Mdr
cabbrev fm Iofm
cabbrev fmr Iofmref
cabbrev Gf execute "normal! <C-V><C-W>fzt"
cabbrev Gtf execute "normal! <C-V><C-W>gFzt"
cabbrev Gvf execute "vertical wincmd f"
cabbrev Co copen
cabbrev Cc cclose
cabbrev Tn tabnew
autocmd BufRead,BufNewFile *.dwl set filetype=dw
cabbrev Ww wincmd w
cabbrev Wj wincmd j
cabbrev Wk wincmd k
cabbrev Wh wincmd h
cabbrev Wl wincmd l

colorscheme default
hi Normal ctermbg=NONE guibg=NONE
"%s/{uuid}/\=substitute(system('uuidgen'), '\n', '', 'g')/g
syntax off
