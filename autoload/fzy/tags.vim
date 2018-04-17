scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'list': s:tags(),
        \ 'options': ['--query="''' . substitute(bufname('%'), '\\', '/', 'g') . ' "']
        \ }
endfunction "}}}

function! s:tags() abort "{{{
  let _ = []
  for tagfile in tagfiles()
    let _ += readfile(tagfile)
  endfor
  return _
endfunction "}}}


" Initialization {{{1

let g:fzy_installed_sources['tags'] = {
      \ 'init': function('s:init')
      \ }



" 1}}}
