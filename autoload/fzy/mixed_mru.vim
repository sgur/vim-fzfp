scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'list': fzy#buffers#list() + fzy#oldfiles#list(),
        \ }
endfunction "}}}


" Initialization {{{1

let g:fzy#mixed_mru#source = {
      \ 'name': 'buffers and oldfiles',
      \ 'init': function('s:init')
      \ }


" 1}}}
