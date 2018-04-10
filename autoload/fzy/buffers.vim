scriptencoding utf-8



" Interface {{{1

function! fzy#buffers#list() abort
  return s:buffers()
endfunction


" Internal {{{1

function! s:init(args) abort "{{{
  let tempname = tempname()
  call writefile(s:buffers(), tempname)
  return {
        \ 'staticfile': tempname,
        \ }
endfunction "}}}

function! s:buffers() abort "{{{
  return map(getbufinfo({'buflisted': 1}), 'fnamemodify(v:val.name, '':~'')')
endfunction "}}}


" Initialization {{{1

let g:fzy_installed_sources['buffers'] = {
      \ 'init': function('s:init')
      \ }


" 1}}}
