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
    let s:src = g:fzfp#files#source
  endif
  return s:src.init(a:args)
endfunction "}}}

function! s:name() abort "{{{
  return 'smart-files[' . s:src.name . ']'
endfunction "}}}

function! s:on_exit_cb(job, status) abort "{{{
  if !a:status
    let s:src = g:fzfp#git_ls_files#source
  else
    let s:src = g:fzfp#files#source
  endif
endfunction "}}}


" Initialization {{{1

let g:fzfp#smart_files#source = {
      \ 'init': function('s:init'),
      \ 'name': function('s:name')
      \ }

let s:src = ''

" 1}}}
