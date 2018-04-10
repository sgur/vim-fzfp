scriptencoding utf-8



" Interface {{{1

function! fzy#files(dir) abort
  let context = {
        \ 'name': 'fzf files',
        \ 'handler': function('s:default_edit_command')
        \ }
  if !empty(a:dir)
    let context.basedir = fnamemodify(a:dir, ':p')
  endif
  call fzy#term#start(context)
endfunction

function! fzy#git_ls_files() abort
  let context = {
        \ 'name': 'git ls-files',
        \ 'cmd': ['git', 'ls-files'],
        \ 'basedir': fnamemodify(getcwd(), ':p'),
        \ 'handler': function('s:default_edit_command')
        \ }
  call fzy#term#start(context)
endfunction

function! fzy#oldfiles() abort
  let tempname = tempname()
  call writefile(s:oldfiles(), tempname)
  let context = {
        \ 'name': 'oldfiles',
        \ 'staticfile': tempname,
        \ 'handler': function('s:default_edit_command')
        \ }
  call fzy#term#start(context)
endfunction

function! fzy#buffer() abort
  let tempname = tempname()
  call writefile(s:buffers(), tempname)
  let context = {
        \ 'name': 'buffer',
        \ 'staticfile': tempname,
        \ 'handler': function('s:default_edit_command')
        \ }
  call fzy#term#start(context)
endfunction

function! fzy#smart_files() abort
  call job_start('git rev-parse --is-inside-work-tree',{
        \ 'out_io': 'null', 'err_io': 'null',
        \ 'exit_cb': function('s:smart_files_on_exit_cb')
        \ })
endfunction

function! fzy#mixed_mru() abort
  let tempname = tempname()
  call writefile(s:buffers() + s:oldfiles(), tempname)

  let context = {
        \ 'name': 'mru',
        \ 'staticfile': tempname,
        \ 'handler': function('s:default_edit_command')
        \ }
  call fzy#term#start(context)
endfunction

function! fzy#buflines() abort
  let tempname = tempname()
  let cols = strlen(line('$'))
  call writefile(map(getline(1, '$'), 'printf("%0' . cols . 'd", v:key+1) . ":" . v:val'), tempname)
  let context = {
        \ 'name': 'buffer: ' . bufname('%'),
        \ 'staticfile': tempname,
        \ 'options': ['--reverse', '--no-sort'],
        \ 'handler': function('s:buffer_handler')
        \ }
  call s:start(context)
endfunction


" Internal {{{1

function! s:log(msg, ...) abort "{{{
  if &verbose
    echomsg '[fzf' . (a:0 ? ':' . a:1 : '') . ']' a:msg
  endif
endfunction "}}}

function! s:oldfiles() abort "{{{
  call s:init_oldfiles()
  return copy(s:oldfiles)
endfunction "}}}

function! s:buffers() abort "{{{
  return map(getbufinfo({'buflisted': 1}), 'fnamemodify(v:val.name, '':~'')')
endfunction "}}}

function! s:smart_files_on_exit_cb(job, status) abort "{{{
  if !a:status
    call fzy#git_ls_files()
  else
    call fzy#files(getcwd())
  endif
endfunction "}}}

function! s:buffer_handler(command, args) abort "{{{
  let [matched, nr, content; _] = matchlist(a:args[0], '^\(\d\+\):\(.\+\)$')
  echomsg eval(nr) content
  execute 'normal!' nr . 'G'
endfunction "}}}


" MRU {{{2

augroup plugin-fzf
  autocmd!
  autocmd BufReadPost *  call s:on_bufreadpost(expand('<afile>:p'))
augroup END

function! s:on_bufreadpost(path) abort "{{{
  call s:init_oldfiles()
  call s:upsert(s:oldfiles, fnamemodify(a:path, ':p:~'))
endfunction "}}}

function! s:init_oldfiles() abort "{{{
  if !exists('s:oldfiles')
    let s:oldfiles = []
    for entry in v:oldfiles
      if !filereadable(fnamemodify(entry, ':p'))
        continue
      endif
      call s:upsert(s:oldfiles, entry)
    endfor
  endif
endfunction "}}}

function! s:upsert(list, item) abort "{{{
  let idx = index(a:list, a:item, 0, has('win32') || has('win64') ? 1 : 0)
  if idx > -1
    call remove(a:list, idx)
  endif
  call add(a:list, a:item)
endfunction "}}}

function! s:default_edit_command(command, args) abort "{{{
  let ex_cmd = get(g:fzy_action, a:command, g:fzy_default_action)
  silent execute (len(a:args) == 1 ? ex_cmd : 'args') join(a:args)
endfunction "}}}


" Initialization {{{1



" 1}}}
