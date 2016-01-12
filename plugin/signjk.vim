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

noremap <expr> <Plug>(signjk-j) signjk#move(signjk#keys(), 0)
noremap <expr> <Plug>(signjk-k) signjk#move(signjk#keys(), 1)

augroup plugin-signjk-dummy-sign
  autocmd!
  autocmd BufWinEnter * call signjk#dummysign()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
