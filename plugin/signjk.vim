"=============================================================================
" FILE: plugin/signjk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_signjk
endif
if exists('g:loaded_signjk')
  finish
endif
let g:loaded_signjk = 1
let s:save_cpo = &cpo
set cpo&vim

noremap <expr> <Plug>(signjk-j)  signjk#move(signjk#keys(), 0)
noremap <expr> <Plug>(signjk-k)  signjk#move(signjk#keys(), 1)
noremap <expr> <Plug>(signjk-jk) signjk#move(signjk#keys(), 2)

omap <expr> <Plug>(textobj-signjk-lines) <SID>operatorlines(0)
vmap <expr> <Plug>(textobj-signjk-lines) <SID>operatorlines(1)

onoremap <Plug>(_signjk-Esc) <Esc>
vnoremap <Plug>(_signjk-Esc) <Esc>
nnoremap <Plug>(_signjk-V) V
nnoremap <Plug>(_signjk-C-o) <C-o>
inoremap <Plug>(_signjk-C-o) <Nop>

function! s:operatorlines(is_visual) abort
  let cmds = [
  \   "\<Plug>(_signjk-Esc)",
  \   "\<Plug>(signjk-jk)",
  \   "\<Plug>(_signjk-V)",
  \   "\<Plug>(signjk-jk)",
  \ ]
  let ops = a:is_visual ? [] : [
  \   '"' . v:register . v:operator,
  \   "\<Plug>(_signjk-C-o)\<Plug>(_signjk-C-o)"
  \ ]
  return join(cmds + ops, '')
endfunction

augroup plugin-signjk-dummy-sign
  autocmd!
  autocmd BufWinEnter * call signjk#dummysign()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
