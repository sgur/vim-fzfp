scriptencoding utf-8

" sources =
" short_name : {
" 'name' : [string] or [funcref] statusline name
" 'init' : [funcref] on source initialized,
" 'accept' : [funcref] on selection accepted,
" 'enter' : [funcref] on source displayed,
" 'exit' : [funcref] on source disappeared,
" }

" Interface {{{1

function! fzfp#start(src, ...) abort
  if empty(g:fzfp_sources)
    echoerr 'fzfp: no sources'
  endif
  if type(a:src) == v:t_string
    let src = a:src
    let s:start = index(g:fzfp_sources, a:src)
  elseif type(a:src) == v:t_number
    let src = g:fzfp_sources[a:src]
    let s:start = a:src
  endif
  let src = substitute(src, '-', '_', 'g')
  let context = g:fzfp#{src}#source.init(a:0 ? a:1 : {})
  let name = s:resolve_name(get(g:fzfp#{src}#source, 'name', src))
  if has_key(g:fzfp#{src}#source, 'accept')
    let context.accept = g:fzfp#{src}#source.accept
  endif
  call s:term_start(name, context)
endfunction


" Internal {{{1

let s:start = 0

function! s:succ() abort "{{{
  let s:start += 1
  if s:start >= len(g:fzfp_sources)
    let s:start = 0
  endif
  return s:start
endfunction "}}}

function! s:pred() abort "{{{
  let s:start -= 1
  if s:start < 0
    let s:start = len(g:fzfp_sources) - 1
  endif
  return s:start
endfunction "}}}

function! s:log(msg, ...) abort "{{{
  if &verbose
    echomsg '[fzf' . (a:0 ? ':' . a:1 : '') . ']' a:msg
  endif
endfunction "}}}

function! s:default_edit_command(command, args) abort "{{{
  let ex_cmd = get(g:fzfp_action, a:command, g:fzfp_default_action)
  silent execute (len(a:args) == 1 ? ex_cmd : 'args') join(a:args)
endfunction "}}}

function! s:resolve_name(name) abort "{{{
  if type(a:name) == v:t_func
    return a:name()
  endif
  return a:name
endfunction "}}}

" Terminal {{{2

function! s:term_start(name, context) abort "{{{
  let result_file = tempname()
  let base_dir = get(a:context, 'basedir', '')
  botright call term_start(s:environment.term_wrapped_cmd(s:build_fzf_args(a:context), result_file, base_dir), {
        \ 'norestore': 1,
        \ 'term_name': '<' . a:name . '>',
        \ 'term_rows': get(g:fzfp_default_window, 'rows', 0),
        \ 'term_cols': get(g:fzfp_default_window, 'cols', 0),
        \ 'term_kill': 'term',
        \ 'term_finish': 'close',
        \ 'eof_chars': has('win32') ? "\<C-d>" : "exit",
        \ 'exit_cb': function('s:term_exit_cb', [result_file], a:context),
        \ 'err_cb': function('s:term_error_cb')
        \ })
  setlocal statusline&
  autocmd WinLeave <buffer>  call job_stop(term_getjob(bufnr('%')))
endfunction "}}}

function! s:term_error_cb(ch, msg) abort "{{{
  call s:log(a:msg, 'error_cb')
  echohl ErrorMsg | echomsg a:msg |~ echohl NONE
endfunction "}}}

function! s:term_exit_cb(temp, job, status) dict abort "{{{
  while ch_canread(a:job)
    call s:log(ch_read(a:job), 'exit_cb')
  endwhile

  try
    let output = readfile(a:temp)
    let command = get(output, 0, '')
    if command is# 'ctrl-f'
      silent hide
      call fzfp#start(s:succ())
      return
    endif
    if command is# 'ctrl-b'
      silent hide
      call fzfp#start(s:pred())
      return
    endif

    if a:status != 0
      if a:status == 130
        echohl WarningMsg | echo 'Abort.' | echohl NONE
      elseif a:status != 0
        call s:log(a:status, 'error')
      endif
      return
    endif

    let args = []
    for item in output[1:]
      if has_key(self, 'accept') && type(self.accept) == v:t_func
        let args += [item]
        call s:log(item, 'edit/custom accept')
        continue
      endif

      if filereadable(expand(item))
        let path = expand(item)
      elseif has_key(self, 'basedir') && filereadable(expand(self.basedir . item))
        let path = expand(self.basedir . item)
      else
        continue
      endif
      call s:log(path, 'edit')
      let args += [fnameescape(path)]
    endfor

    if empty(args)
      echohl WarningMsg | echo 'No entries selected.' | echohl NONE
      call s:log('no entry', 'exit')
    endif

    silent hide
    if has_key(self, 'accept') && type(self.accept) == v:t_func
      call self.accept(command, args)
    else
      call s:default_edit_command(command, args)
    endif
  finally
    " if has_key(self, 'staticfile') && delete(self.staticfile) != 0
    "   echoerr 'DELETE FAILED:' self.staticfile
    " endif
    if filewritable(a:temp) && delete(a:temp) != 0
      echoerr 'DELETE FAILED:' a:temp
    endif
  endtry
endfunction "}}}

function! s:build_fzf_args(context) abort "{{{
  let cmd = s:build_pre_args(a:context) + ['fzf'] + ['--expect=ctrl-f,ctrl-b,' . join(keys(g:fzfp_action), ',')] + get(a:context, 'options', []) + g:fzfp_options
  if exists('$FZF_DEFAULT_OPTS')
    let cmd += [$FZF_DEFAULT_OPTS]
  endif
  if g:fzfp_use_history && filewritable(g:fzfp_history_file)
    let cmd += ['--history='.g:fzfp_history_file]
  endif
  call s:log(join(cmd), 'cmd')
  return cmd
endfunction "}}}

function! s:build_pre_args(context) abort "{{{
  if has_key(a:context, 'list')
    let temppath = tempname()
    call writefile(a:context.list, temppath)
    let cmd = [has('win32') || has('win64') ? 'type' : 'cat'] + [temppath]
  elseif has_key(a:context, 'staticfile')
    let cmd = [has('win32') || has('win64') ? 'type' : 'cat']
    for file in type(a:text.staticfile) == v:t_list ? a:text.staticfile : [a:text.staticfile]
      let cmd += [file]
    endfor
  elseif has_key(a:context, 'cmd')
    let cmd = a:context.cmd
  else
    let cmd = []
  endif
  if !empty(cmd)
    let cmd += ['|']
  endif
  return cmd
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

if has('win32') || has('win64')
  let s:environment = s:env_win
else
  let s:environment = s:env_unix
endif


" 1}}}
