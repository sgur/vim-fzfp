scriptencoding utf-8



" Interface {{{1

function! fzy#env#get() abort
  return s:environment
endfunction


" Internal {{{1

function! s:log(msg, ...) abort "{{{
  if &verbose
    echomsg '[fzf/env' . (a:0 ? ':' . a:1 : '') . ']' a:msg
  endif
endfunction "}}}

" Envrionment - Windows {{{2

let s:env_win = {}

function! s:env_win.shellescape(str) abort "{{{
  try
    let ssl = &shellslash
    set noshellslash
    return shellescape(a:str)
  finally
    let &shellslash = ssl
  endtry
endfunction "}}}

function! s:env_win.term_wrapped_cmd(cmd, tempfile, basedir) abort "{{{
  let cdcmd = !empty(a:basedir) ? printf('cd /d %s & ', self.shellescape(a:basedir)) : ''
  let cmd = printf('cmd /c (chcp 65001 >NUL) && %s%s > %s', cdcmd, join(a:cmd), self.shellescape(a:tempfile))
  call s:log(cmd, 'wrapped cmd')
  return cmd
endfunction "}}}

" Environment - Unix-like {{{2

let s:env_unix = {}

function! s:env_unix.shellescape(str) abort "{{{
  return shellescape(a:str)
endfunction "}}}

function! s:env_unix.term_wrapped_cmd(cmd, tempfile, basedir) abort "{{{
  let cmd = join(a:cmd)
  if !empty(a:basedir)
    let cmd = printf('cd %s; %s', self.shellescape(a:basedir), cmd)
  endif
  let sh = get(filter(['sh', 'bash'], 'executable(v:val)'), 0, 'sh')
  let cmd = printf('%s -c "{ %s; } > %s"', sh, cmd, self.shellescape(a:tempfile))
  call s:log(cmd, 'wrapped cmd')
  return cmd
endfunction "}}}

" Initialization {{{1

lockvar s:env_win s:env_unix
if has('win32') || has('win64')
  let s:environment = s:env_win
else
  let s:environment = s:env_unix
endif
lockvar s:environment

" 1}}}
