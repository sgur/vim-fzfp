scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  let paths = globpath(&packpath, 'pack/*/*/*', 1, 1)

  return {
        \ 'name': 'packages in packpath',
        \ 'list': paths
        \ }
endfunction "}}}


" Initialization {{{1

let g:fzfp#packages#source = {
      \ 'init': function('s:init'),
      \ 'name': 'packages'
      \ }


" 1}}}
