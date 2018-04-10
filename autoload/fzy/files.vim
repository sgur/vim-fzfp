scriptencoding utf-8



" Interface {{{1



" Internal {{{1

function! s:init(args) abort
  let context = {}
  if has_key(a:args, 'basedir')
    let context.basedir = fnamemodify(a:args.basedir, ':p')
  endif
  return context
endfunction

" Initialization {{{1

let g:fzy_installed_sources['files'] = {
      \ 'name': 'fzf files',
      \ 'init': function('s:init')
      \ }



" 1}}}
