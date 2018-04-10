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

let g:fzy_installed_sources = get(g:, 'fzy_installed_sources', {})
let g:fzy_sources = get(g:, 'fzy_sources', ['files', 'oldfiles', 'git-ls-files', 'buffers', 'lines', 'mixed-mru', 'smart-files'])

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

command! -nargs=0 Fzy  call fzy#start(0)

command! -nargs=? -complete=dir FzyFiles  call fzy#start('files', {'basedir': <q-args>})
command! -nargs=0 FzyGitLsFiles  call fzy#start('git-ls-files')
command! -nargs=0 FzyOldfiles  call fzy#start('oldfiles')
command! -nargs=0 FzyBuffer call fzy#start('buffers')
command! -nargs=0 -bang FzySmartFiles  call fzy#start('smart-files')
command! -nargs=0 -bang FzyMru  call fzy#start('mixed-mru')
command! -nargs=0 FzyLines  call fzy#start('lines')

nnoremap <silent> <Plug>(fzy-smart-files)  :<C-u>call fzy#start('smart-files')<CR>
nnoremap <silent> <Plug>(fzy-mixed-mru)    :<C-u>call fzy#start('mixed-mru')<CR>

if !hasmapto("<Plug>(fzy-smart-files)", 'n') && empty(maparg("\<C-p>"))
  nmap <C-p> <Plug>(fzy-smart-files)
endif
if !hasmapto("<Plug>(fzy-mixed-mru)", 'n') && empty(maparg("\<C-n>"))
  nmap <C-n> <Plug>(fzy-mixed-mru)
endif

if index(g:fzy_sources, 'oldfiles') >= 0 || index(g:fzy_sources, 'mixed-mru') >= 0
  augroup plugin-fzy-oldfiles
    autocmd!
    autocmd BufReadPost *  call fzy#oldfiles#on_bufreadpost(expand('<afile>:p'))
  augroup END
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:set et:

