" gf-user - A framework to open a file by context
" Version: 0.0.0
" Copyright (C) 2012-2023 Kana Natsuno <https://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

if exists('g:loaded_gf_user')
  finish
endif




function! s:define_ui_key_mappings()
  for gf_cmd in ['gf', 'gF',
  \              '<C-w>f', '<C-w><C-f>', '<C-w>F',
  \              '<C-w>gf', '<C-w>gF']
    for mode_char in ['n', 'x']
      execute printf(
      \   '%snoremap <Plug>(%s-%s) :<C-u>call gf#user#do("%s", "%s")<CR>',
      \   mode_char,
      \   'gf-user',
      \   gf_cmd,
      \   substitute(gf_cmd, '<\(\a-\a\)>', '\\<LT>\1>', 'g'),
      \   mode_char
      \ )
    endfor
  endfor
endfunction
call s:define_ui_key_mappings()




command! -bang -bar -nargs=0 GfUserDefaultKeyMappings
\ call s:cmd_GfUserDefaultKeyMappings(<bang>0)
function! s:cmd_GfUserDefaultKeyMappings(banged_p)
  let modifier = a:banged_p ? '' : '<unique>'
  for gf_cmd in ['gf', 'gF',
  \              '<C-w>f', '<C-w><C-f>', '<C-w>F',
  \              '<C-w>gf', '<C-w>gF']
    for map_cmd in ['nmap', 'xmap']
      execute printf('silent! %s %s %s  <Plug>(gf-user-%s)',
      \              map_cmd,
      \              modifier,
      \              gf_cmd,
      \              gf_cmd)
    endfor
  endfor
endfunction

if !exists('g:gf_user_no_default_key_mappings')
  GfUserDefaultKeyMappings
endif




let g:loaded_gf_user = 1

" __END__
" vim: foldmethod=marker
