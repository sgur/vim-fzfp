scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'cmd': ['git', 'ls-files'],
        \ }
endfunction "}}}


" Initialization {{{1

let g:fzy_installed_sources['git-ls-files'] = {
      \ 'name': 'git ls-files',
      \ 'init': function('s:init')
      \ }

" 1}}}
