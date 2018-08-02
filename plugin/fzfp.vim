" fzfp
" Version: 0.0.1
" Author: sgur
" License: MIT License

if exists('g:loaded_fzfp')
  finish
endif
let g:loaded_fzfp = 1

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

let g:fzfp_sources = get(g:, 'fzfp_sources', ['files', 'oldfiles', 'git-ls-files', 'buffers', 'lines', 'mixed-mru', 'smart-files', 'tags', 'packages'])

let g:fzfp_options = ['--multi', '--no-mouse', '--no-hscroll']
let g:fzfp_default_action = 'drop'
let g:fzfp_action = {
      \ 'ctrl-t': 'tab new',
      \ 'ctrl-x': 'new',
      \ 'ctrl-v': 'vertical new',
      \ }
let g:fzfp_default_window = {'rows': 0, 'cols': 0}
let g:fzfp_use_history = 1
let g:fzfp_history_file = expand('~/.cache/fzfp/history')

command! -nargs=0 Fzfp  call fzfp#start(0)

command! -nargs=? -complete=dir FzfpFiles  call fzfp#start('files', {'basedir': <q-args>})
command! -nargs=0 FzfpGitLsFiles  call fzfp#start('git-ls-files')
command! -nargs=0 FzfpOldfiles  call fzfp#start('oldfiles')
command! -nargs=0 FzfpBuffer call fzfp#start('buffers')
command! -nargs=0 -bang FzfpSmartFiles  call fzfp#start('smart-files')
command! -nargs=0 -bang FzfpMru  call fzfp#start('mixed-mru')
command! -nargs=0 FzfpLines  call fzfp#start('lines')
command! -nargs=0 FzfpTags  call fzfp#start('tags')
command! -nargs=0 FzfpPackages  call fzfp#start('packages')

nnoremap <silent> <Plug>(fzfp-smart-files)  :<C-u>call fzfp#start('smart-files')<CR>
nnoremap <silent> <Plug>(fzfp-mixed-mru)    :<C-u>call fzfp#start('mixed-mru')<CR>

if !hasmapto("<Plug>(fzfp-smart-files)", 'n') && empty(maparg("\<C-p>"))
  nmap <C-p> <Plug>(fzfp-smart-files)
endif
if !hasmapto("<Plug>(fzfp-mixed-mru)", 'n') && empty(maparg("\<C-n>"))
  nmap <C-n> <Plug>(fzfp-mixed-mru)
endif

if index(g:fzfp_sources, 'oldfiles') >= 0 || index(g:fzfp_sources, 'mixed-mru') >= 0
  augroup plugin-fzfp-oldfiles
    autocmd!
    autocmd BufReadPost *  call fzfp#oldfiles#on_bufreadpost(expand('<afile>:p'))
  augroup END
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:set et:

