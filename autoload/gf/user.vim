" gf-user - A framework to open a file by context
" Version: @@VERSION@@
" Copyright (C) 2012 Kana Natsuno <http://whileimautomaton.net/>
" License: So-called MIT/X license  {{{
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
" Interface  "{{{1
function! gf#user#extend(funcname, priority)  "{{{2
  let s:ext_dict[a:funcname] = a:priority
endfunction




function! gf#user#set_priority(funcname, priority)  "{{{2
  if has_key(s:ext_dict, a:funcname)
    let s:ext_dict[a:funcname] = a:priority
  else
    echoerr 'gf-user: Extension' string(a:funcname) 'is not registered.'
  endif
endfunction








" Misc.  "{{{1
" Variables  "{{{2

if !exists('s:ext_dict')
  let s:ext_dict = {}  " FuncName -> Priority
endif




function! gf#user#do(gf_cmd, mode)  "{{{2
  try
    if a:mode ==# 'v'
      normal! gv
    endif
    execute 'normal!' a:gf_cmd
    return
  catch /\C\V\^Vim\%((\a\+)\)\?:\(E446\|E447\):/
    for funcname in gf#user#get_sorted_ext_list()
      if gf#user#try(funcname, a:gf_cmd)
        return
      endif
    endfor
    echohl ErrorMsg
    echomsg substitute(v:exception, '\C^Vim.\{-}:', '', '')
    echohl NONE
  endtry
endfunction




function! gf#user#get_ext_dict()  "{{{2
  return s:ext_dict
endfunction




function! gf#user#get_sorted_ext_list()  "{{{2
  return
  \ map(
  \   sort(
  \     map(
  \       keys(s:ext_dict),
  \       '[printf("%06d %s", s:ext_dict[v:val], v:val), v:val]'
  \     )
  \   ),
  \   'v:val[1]'
  \ )
endfunction




function! gf#user#split(gf_cmd)  "{{{2
  let nop_cmd = ''
  let split_cmd_table = {
  \   "gf": nop_cmd,
  \   "gF": nop_cmd,
  \   "\<C-w>f": 'split',
  \   "\<C-w>\<C-f>": 'split',
  \   "\<C-w>F": 'split',
  \   "\<C-w>gf": 'tab split',
  \   "\<C-w>gF": 'tab split',
  \ }
  execute get(split_cmd_table, a:gf_cmd, nop_cmd)
endfunction




function! gf#user#try(funcname, gf_cmd)  "{{{2
  let p = function(a:funcname)()
  " p.path might be neither a file nor a directory.  In this case, p.path is
  " expected to be "open"ed by other plugins.  For example, if p.path ==
  " 'http://www.example.com/', netrw will be used to "open" the path.  So that
  " it's not necessary to check filereadable(p.path) || isdirectory(p.path).
  if p isnot 0
    call gf#user#split(a:gf_cmd)
    edit `=p.path`
    execute 'normal!' (p.line . 'gg')
    if p.col != 0
      execute 'normal!' (p.col . '|')
    endif
    return !0
  else
    return 0
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
