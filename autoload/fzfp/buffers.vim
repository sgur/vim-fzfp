scriptencoding utf-8



" Interface {{{1

function! fzfp#buffers#list() abort
  return s:buffers()
endfunction


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'list': s:buffers()
        \ }
endfunction "}}}

function! s:buffers() abort "{{{
  return map(getbufinfo({'buflisted': 1}), 'fnamemodify(v:val.name, '':~'')')
endfunction "}}}


" Initialization {{{1

let g:fzfp#buffers#source = {
      \ 'init': function('s:init')
      \ }


" 1}}}
