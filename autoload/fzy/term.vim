scriptencoding utf-8



" Interface {{{1

function! fzy#term#start(context) abort
  call s:start(a:context)
endfunction

" Internal {{{1

function! s:start(context) abort "{{{
  let result_file = tempname()
  let base_dir = get(a:context, 'basedir', '')
  botright call term_start(fzy#env#get().term_wrapped_cmd(s:build_fzf_args(a:context), result_file, base_dir), {
        \ 'norestore': 1,
        \ 'term_name': '<' . a:context.name . '>',
        \ 'term_rows': get(g:fzy_default_window, 'rows', 0),
        \ 'term_cols': get(g:fzy_default_window, 'cols', 0),
        \ 'term_kill': 'term',
        \ 'term_finish': 'close',
        \ 'eof_chars': has('win32') ? "\<C-d>" : "exit",
        \ 'exit_cb': function('s:term_exit_cb', [result_file], a:context),
        \ 'err_cb': function('s:term_error_cb')
        \ })
  setlocal statusline&
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
    if a:status != 0
      if a:status == 130
        echohl WarningMsg | echo 'Abort.' | echohl NONE
      elseif a:status != 0
        call s:log(a:status, 'error')
      endif
      return
    endif

    let args = []
    let output = readfile(a:temp)
    let command = output[0]
    for item in output[1:]
      if has_key(self, 'handler') && type(self.handler) == v:t_func
        let args += [item]
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
    if has_key(self, 'handler') && type(self.handler) == v:t_func
      call self.handler(command, args)
    endif
  finally
    if has_key(self, 'staticfile') && delete(self.staticfile) != 0
      echoerr 'DELETE FAILED:' self.staticfile
    endif
    if filewritable(a:temp) && delete(a:temp) != 0
      echoerr 'DELETE FAILED:' a:temp
    endif
  endtry
endfunction "}}}

function! s:build_fzf_args(context) abort "{{{
  let cmd = s:build_pre_args(a:context) + ['fzf'] + ['--expect=' . join(keys(g:fzy_action), ',')]
  let cmd += get(a:context, 'options', [])
  let cmd += g:fzy_options
  let cmd += exists('$FZF_DEFAULT_OPTS') ? [$FZF_DEFAULT_OPTS] : []
  if g:fzy_use_history && filewritable(g:fzy_history_file)
    let cmd += ['--history='.g:fzy_history_file]
  endif
  call s:log(join(cmd), 'cmd')
  return cmd
endfunction "}}}

function! s:build_pre_args(context) abort "{{{
  let cmd = has_key(a:context, 'staticfile')
        \ ? [has('win32') || has('win64') ? 'type' : 'cat'] + [a:context.staticfile]
        \ : has_key(a:context, 'cmd')
        \   ? a:context.cmd
        \   : []
  if !empty(cmd)
    let cmd += ['|']
  endif
  return cmd
endfunction "}}}

function! s:log(msg, ...) abort "{{{
  if &verbose
    echomsg '[fzf/term' . (a:0 ? ':' . a:1 : '') . ']' a:msg
  endif
endfunction "}}}

" Initialization {{{1



" 1}}}
