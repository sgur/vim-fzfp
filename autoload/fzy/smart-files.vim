scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  let job = job_start('git rev-parse --is-inside-work-tree',{
        \ 'out_io': 'null', 'err_io': 'null',
        \ 'exit_cb': function('s:on_exit_cb')
        \ })

  while job_status(job) isnot# 'dead'
    sleep 100m
  endwhile

  if empty(s:src)
    let s:src = 'files'
  endif
  return g:fzy_installed_sources[s:src].init(a:args)
endfunction "}}}

function! s:name() abort "{{{
  return 'smart-files[' . s:src . ']'
endfunction "}}}

function! s:on_exit_cb(job, status) abort "{{{
  if !a:status
    let s:src = 'git-ls-files'
  else
    let s:src = 'files'
  endif
endfunction "}}}


" Initialization {{{1

runtime autoload/fzy/files.vim
runtime autoload/fzy/git-ls-files.vim

let g:fzy_installed_sources['smart-files'] = {
      \ 'init': function('s:init'),
      \ 'name': function('s:name')
      \ }

let s:src = ''

" 1}}}
