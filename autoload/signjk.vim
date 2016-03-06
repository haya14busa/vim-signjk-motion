"=============================================================================
" FILE: autoload/signjk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:ID_START = 1414141414

let g:signjk#use_upper = get(g:, 'signjk#use_upper', 0)
let g:signjk#keys = get(g:, 'signjk#keys', 'asdghklqwertyuiopzxcvbnmfj;')
let g:signjk#dummysign = get(g:, 'signjk#dummysign', 1)

let s:V = vital#of('signjk')
let s:Hint = s:V.import('HitAHint.Hint')

let s:DIRECTION = {'forward': 0, 'backward': 1, 'both': 2}

function! s:init_hl() abort
  highlight default SignjkTarget  term=standout ctermfg=81 gui=bold guifg=#66D9EF
  highlight default SignjkTarget2 ctermfg=229 guifg=#E6DB74
endfunction

function! s:init() abort
  call s:init_hl()
  " There is a transparent char after 'text='
  sign define signjkdummy text=ㅤ texthl=SignColumn
endfunction

call s:init()

augroup plugin-signjk-highlight
  autocmd!
  autocmd ColorScheme * call s:init_hl()
augroup END

function! signjk#keys() abort
  return g:signjk#keys
endfunction

function! signjk#dummysign() abort
  if g:signjk#dummysign
    execute printf('sign place %d line=%d name=signjkdummy buffer=%d', s:ID_START, 1, bufnr('%'))
  endif
endfunction

function! signjk#move(keys, direction) abort
  let b:signjk = {
  \   'id_table': {},
  \   'bufnr': bufnr('%')
  \ }
  let lines = s:gather_lines(a:direction)
  if a:direction is# s:DIRECTION.backward
    call reverse(lines)
  endif
  let target_lnum = s:select_line(lines, a:keys)
  if target_lnum is# -1
    let esc = v:count > 0 || mode(1) is# 'no'  ? "\<Esc>" : ''
    return esc
  else
    return s:generate_command(target_lnum)
  endif
endfunction

function! s:generate_command(target_lnum) abort
  let dlnum = a:target_lnum - line('.')
  let key = dlnum > 0 ? 'j' : 'k'
  let move = dlnum is# 0 ? '' : abs(dlnum) . key
  let esc = v:count > 0 || !(mode(1) is# 'n')  ? "\<Esc>" : ''
  let op = mode(1) is# 'no' ? '"' . v:register . v:operator
  \ : s:is_visual(mode(1)) ? 'gv'
  \ : ''
  return esc . 'm`' . op . move
endfunction

function! s:select_line(lnums, keys) abort
  let lines_len = len(a:lnums)
  if lines_len is# 1
    return a:lnums[0]
  elseif lines_len < 1
    return -1
  else
    return s:choose_prompt(s:Hint.create(a:lnums, a:keys))
  endif
endfunction

" @param Tree{string: (T|Tree)} hint_dict
function! s:choose_prompt(hint_dict) abort
  try
    call s:place_sign(s:line_to_hint(a:hint_dict))
    echo 'Type key: '
    let c = s:getchar()
    redraw
    if g:signjk#use_upper
      let c = toupper(c)
    endif
  finally
    call s:remove_sign()
  endtry

  if has_key(a:hint_dict, c)
    let target = a:hint_dict[c]
    return type(target) is# type({}) ? s:choose_prompt(target) : target
  else
    echo 'Invalid target: ' . c
    return -1
  endif
endfunction

function! s:getchar(...) abort
  let mode = get(a:, 1, 0)
  call inputsave()
  while 1
    let char = call('getchar', a:000)
    " Workaround for the <expr> mappings
    if string(char) !~# "\x80\xfd`"
      break
    endif
  endwhile
  call inputrestore()
  return mode == 1 ? !!char
  \   : type(char) == type(0) ? nr2char(char) : char
endfunction

" @param {{lnum: list<char>}} line_to_hint
function! s:place_sign(line_to_hint) abort
  for [lnum, hint] in items(a:line_to_hint)
    let is_more_than_one_hint = len(hint) > 1
    let hl = is_more_than_one_hint ? 'SignjkTarget2' : 'SignjkTarget'
    call s:sign(str2nr(lnum), join(hint[:1], ''), hl)
  endfor
endfunction

function! s:sign(lnum, text, hl) abort
  let name = printf('signjk#%s', a:lnum)
  let id = s:ID_START + a:lnum
  let b:signjk.id_table[id] = {
  \   'lnum': a:lnum,
  \   'text': a:text
  \ }
  execute printf('sign define %s text=%s texthl=%s', name, a:text, a:hl)
  execute printf('sign place %d line=%d name=%s buffer=%d', id, a:lnum, name, b:signjk.bufnr)
endfunction

function! s:remove_sign(...) abort
  let bufnr = get(a:, 1, bufnr('%'))
  let signjk = getbufvar(bufnr, 'signjk', {})
  for id in keys(get(signjk, 'id_table', {}))
    execute printf('sign unplace %d buffer=%d', id, bufnr)
  endfor
endfunction


" s:line_to_hint() returns dict whose key is line number and whose value is
" the hints
" e.g. {'1': ['a'], '2': ['b', 'a'], '3': ['b', 'b']}
" @return {{lnum: list<char>}}
function! s:line_to_hint(hint_dict) abort
  return s:_line_to_hint({}, a:hint_dict)
endfunction

function! s:_line_to_hint(dict, hint_dict, ...) abort
  let prefix = get(a:, 1, [])
  for [hint, v]  in items(a:hint_dict)
    if type(v) is# type(0)
      let a:dict[v] = prefix + [hint]
    else
      call s:_line_to_hint(a:dict, v, prefix + [hint])
    endif
    unlet v
  endfor
  return a:dict
endfunction

function! s:gather_lines(direction) abort
  if a:direction is# s:DIRECTION.forward
    let lines = range(line('.') + 1, line('w$'))
  elseif a:direction is# s:DIRECTION.backward
    let lines = range(line('w0'), line('.') - 1)
  else
    let lines = range(line('w0'), line('w$'))
  endif
  return filter(lines, '!s:is_in_folded(v:val)')
endfunction

function! s:is_in_folded(lnum) abort
  return foldclosed(a:lnum) != -1
endfunction

function! s:is_visual(mode) abort
  return a:mode =~# "[vV\<C-v>]"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
