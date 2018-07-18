scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'list': fzfp#buffers#list() + fzfp#oldfiles#list(),
        \ }
endfunction "}}}


" Initialization {{{1

let g:fzfp#mixed_mru#source = {
      \ 'name': 'buffers and oldfiles',
      \ 'init': function('s:init')
      \ }


" 1}}}
