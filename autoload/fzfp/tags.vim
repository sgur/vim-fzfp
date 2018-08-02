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

function! s:accept(command, args) abort "{{{
  for line in a:args
    let matches =matchlist(line, '^\(\p\+\)\t\(\f\+\)\t/\(.\+\)/;')
    let [_1, _2, path, pattern; _3] = matches
    for tagpath in tagfiles()
      let base = fnamemodify(tagpath, ':p:h')
      let path = expand(simplify(base . '/' . path))
      if filereadable(path)
        echomsg 'edit' '+/' . escape(pattern, ' ') path
        execute 'edit' '+/' . escape(pattern, ' ') path
      endif
    endfor
  endfor
endfunction "}}}


" Initialization {{{1

let g:fzfp#tags#source = {
      \ 'init': function('s:init'),
      \ 'accept': function('s:accept')
      \ }



" 1}}}
