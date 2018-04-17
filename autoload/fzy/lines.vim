scriptencoding utf-8



" Interface {{{1

function! s:init(args) abort "{{{
  return {
        \ 'name': 'buffer: ' . bufname('%'),
        \ 'list': map(getline(1, '$'), 'printf("%0' . strlen(line('$')). 'd", v:key+1) . ":" . v:val'),
        \ 'options': ['--reverse', '--no-sort'],
        \ }
endfunction "}}}

function! s:accept(command, args) abort "{{{
  let [matched, nr, content; _] = matchlist(a:args[0], '^\(\d\+\):\(.\+\)$')
  echomsg eval(nr) content
  execute 'normal!' nr . 'G'
endfunction "}}}



" Internal {{{1


" Initialization {{{1

let g:fzy#lines#source = {
      \ 'name': 'lines in current buffer',
      \ 'init': function('s:init'),
      \ 'accept': function('s:accept')
      \ }


" 1}}}
