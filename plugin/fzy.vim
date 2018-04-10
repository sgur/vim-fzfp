" fzy
" Version: 0.0.1
" Author: sgur
" License: MIT License

if exists('g:loaded_fzy')
  finish
endif
let g:loaded_fzy = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

if !executable('fzf')
  echoerr 'No "fzf" found in $PATH'
  echoerr 'Please refer https://github.com/junegunn/fzf#installation'
  finish
endif
if !(has('job') && has('terminal'))
  echoerr 'Vim with +job and +terminal is requried'
  finish
endif

let g:fzy_options = ['--multi', '--no-mouse', '--no-hscroll']
let g:fzy_default_action = 'drop'
let g:fzy_action = {
      \ 'ctrl-t': 'tab new',
      \ 'ctrl-x': 'new',
      \ 'ctrl-v': 'vertical new',
      \ }
let g:fzy_default_window = {'rows': 0, 'cols': 0}
let g:fzy_use_history = 1
let g:fzy_history_file = expand('~/.cache/fzf/history')

command! -nargs=? -complete=dir FzyFiles  call fzy#files(<q-args>)
command! -nargs=0 FzyGitLsFiles  call fzy#git_ls_files()
command! -nargs=0 FzyOldfiles  call fzy#oldfiles()
command! -nargs=0 FzyBuffer call fzy#buffer()
command! -nargs=0 -bang FzySmartFiles  call fzy#smart_files()
command! -nargs=0 -bang FzyMru  call fzy#mixed_mru()
command! -nargs=0 FzyBufLines  call fzy#buflines()

nnoremap <silent> <Plug>(fzy-smart-files)  :<C-u>call fzy#smart_files()<CR>
nnoremap <silent> <Plug>(fzy-mixed-mru)    :<C-u>call fzy#mixed_mru()<CR>

if !hasmapto("<Plug>(fzy-smart-files)", 'n') && empty(maparg("\<C-p>"))
  nmap <C-p> <Plug>(fzy-smart-files)
endif
if !hasmapto("<Plug>(fzy-mixed-mru)", 'n') && empty(maparg("\<C-n>"))
  nmap <C-n> <Plug>(fzy-mixed-mru)
endif


let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:set et:

