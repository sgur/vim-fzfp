scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'cmd': ['git', 'ls-files'],
        \ }
endfunction "}}}


" Initialization {{{1


 let g:fzfp#git_ls_files#source = {
      \ 'name': 'git ls-files',
      \ 'init': function('s:init')
      \ }

" 1}}}
