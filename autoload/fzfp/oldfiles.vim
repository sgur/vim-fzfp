scriptencoding utf-8



" Interface {{{1

function! fzfp#oldfiles#list() abort
  return s:oldfiles()
endfunction


" Internal {{{1

function! s:init(args) abort "{{{
  return {
        \ 'list': s:oldfiles()
        \ }
endfunction "}}}

function! s:oldfiles() abort "{{{
  return copy(s:oldfiles)
endfunction "}}}

function! s:init_oldfiles() abort "{{{
  if !exists('s:oldfiles')
    let s:oldfiles = []
    for entry in v:oldfiles
      if s:is_localfile(entry) && !filereadable(fnamemodify(entry, ':p'))
        continue
      endif
      call s:upsert(s:oldfiles, entry)
    endfor
  endif
endfunction "}}}

function! s:is_localfile(fname) abort "{{{
  if (has('win32') || has('win64')) && a:fname =~ '^\\'
    return v:false
  endif
  return v:true
endfunction "}}}

function! fzfp#oldfiles#on_bufreadpost(path) abort "{{{
  call s:upsert(s:oldfiles, fnamemodify(a:path, ':p:~'))
endfunction "}}}

function! s:upsert(list, item) abort "{{{
  let idx = index(a:list, a:item, 0, has('win32') || has('win64') ? 1 : 0)
  if idx > -1
    call remove(a:list, idx)
  endif
  call add(a:list, a:item)
endfunction "}}}


" Initialization {{{1

let g:fzfp#oldfiles#source = {
      \ 'init': function('s:init')
      \ }

call s:init_oldfiles()


" 1}}}
