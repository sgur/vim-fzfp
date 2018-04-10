scriptencoding utf-8



" Interface {{{1


" Internal {{{1

function! s:init(args) abort "{{{
  let tempname = tempname()
  call writefile(fzy#buffers#list() + fzy#oldfiles#list(), tempname)

  return {
        \ 'staticfile': tempname,
        \ }
endfunction "}}}


" Initialization {{{1

let g:fzy_installed_sources['mixed-mru'] = {
      \ 'name': 'buffers and oldfiles',
      \ 'init': function('s:init')
      \ }


" 1}}}
