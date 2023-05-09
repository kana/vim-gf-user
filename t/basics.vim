runtime! plugin/gf/user.vim

describe 'gf#user#extend()'
  before
    new
    let b:d = gf#user#get_ext_dict()
  end

  after
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'registers a given extension'
    Expect b:d ==# {}

    call gf#user#extend('foo', 1000)
    Expect b:d['foo'] == 1000
  end

  it 'can override an existing extension with the same name'
    Expect b:d ==# {}

    call gf#user#extend('foo', 1000)
    Expect b:d['foo'] == 1000

    call gf#user#extend('foo', 2000)
    Expect b:d['foo'] == 2000
  end
end

describe 'gf#user#set_priority()'
  before
    new
    let b:d = gf#user#get_ext_dict()
  end

  after
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'sets a priority to an existing extension'
    call gf#user#extend('foo', 1000)
    Expect b:d['foo'] == 1000

    call gf#user#set_priority('foo', 2000)
    Expect b:d['foo'] == 2000
  end

  it 'raises an error if the target extension is not registered'
    Expect b:d ==# {}

    let v:errmsg = ''
    silent! call gf#user#set_priority('bar', 3000)
    Expect v:errmsg ==# "gf-user: Extension 'bar' is not registered."
    Expect b:d ==# {}
  end
end

describe 'gf#user#get_sorted_ext_list()'
  before
    new
    let b:d = gf#user#get_ext_dict()
  end

  after
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'returns a list of extensions sorted by priority then by name'
    call gf#user#extend('foo', 1000)
    call gf#user#extend('bar', 1000)
    call gf#user#extend('baz', 2000)
    call gf#user#extend('qux', 900)

    Expect gf#user#get_sorted_ext_list() ==# ['qux', 'bar', 'foo', 'baz']
  end
end

describe 'gf#user#split()'
  it 'does not split anything for non-"gf" command'
    let status = s:check_split("xyzzy")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'does not split anything for "gf"'
    let status = s:check_split("gf")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'doesn not split anything for "gF"'
    let status = s:check_split("gF")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'splits a window to the current tabpage for "\<C-w>f"'
    let status = s:check_split("\<C-w>f")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc + 1
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'splits a window to the current tabpage for "\<C-w>\<C-f>"'
    let status = s:check_split("\<C-w>\<C-f>")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc + 1
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'splits a window to the current tabpage for "\<C-w>F"'
    let status = s:check_split("\<C-w>F")
    Expect status.new_wn == status.old_wn
    Expect status.new_wc == status.old_wc + 1
    Expect status.new_tn == status.old_tn
    Expect status.new_tc == status.old_tc
  end

  it 'splits a window to a new tabpage for "\<C-w>gf"'
    let status = s:check_split("\<C-w>gf")
    Expect status.new_wn == 1
    Expect status.new_wc == 1
    Expect status.new_tn != status.old_tn
    Expect status.new_tc == status.old_tc + 1
  end

  it 'splits a window to a new tabpage for "\<C-w>gF"'
    let status = s:check_split("\<C-w>gf")
    Expect status.new_wn == 1
    Expect status.new_wc == 1
    Expect status.new_tn != status.old_tn
    Expect status.new_tc == status.old_tc + 1
  end
end

function s:check_split(gf_cmd)
  let status = {}

  let status['old_wn'] = winnr()
  let status['old_wc'] = winnr('$')
  let status['old_tn'] = tabpagenr()
  let status['old_tc'] = tabpagenr('$')

  call gf#user#split(a:gf_cmd)

  let status['new_wn'] = winnr()
  let status['new_wc'] = winnr('$')
  let status['new_tn'] = tabpagenr()
  let status['new_tc'] = tabpagenr('$')

  silent tabonly!
  silent only!

  return status
endfunction

describe 'gf#user#try()'
  before
    new
  end

  after
    %bwipeout!
  end

  it 'fails if a given function is failed to find a file'
    Expect gf#user#try('GfAlwaysFailureFind', 'gf') to_be_false
  end

  it 'opens a path and move the cursor to a given position'
    silent let result = gf#user#try('GfSomePathL8C20Find', 'gf')
    Expect result to_be_true
    Expect bufname('') ==# 'doc/gf-user.txt'
    Expect line('.') == 8
    Expect col('.') == 20
  end

  it 'opens a path and move the cursor to the first non-blank character'
    silent let result = gf#user#try('GfSomePathL8C0Find', 'gf')
    Expect result to_be_true
    Expect bufname('') ==# 'doc/gf-user.txt'
    Expect line('.') == 8
    Expect col('.') == 5
    Expect getline(line('.')) =~# '^\s\s\s\s\S'
  end

  it 'opens a path which is neither a file nor a directory'
    Expect bufname('') ==# ''

    silent let result = gf#user#try('GfNonExistingPathFind', 'gf')
    Expect result to_be_true
    Expect bufname('') ==# 'foobarbaz'
    Expect line('.') == 1
    Expect col('.') == 1
  end

  it 'splits a window if necessary'
    let old_wn = winnr()
    let old_wc = winnr('$')
    let old_tn = tabpagenr()
    let old_tc = tabpagenr('$')

    silent let result = gf#user#try('GfNonExistingPathFind', "\<C-w>f")

    let new_wn = winnr()
    let new_wc = winnr('$')
    let new_tn = tabpagenr()
    let new_tc = tabpagenr('$')
    Expect result to_be_true
    Expect bufname('') ==# 'foobarbaz'
    Expect line('.') == 1
    Expect col('.') == 1
    Expect new_wn == old_wn
    Expect new_wc == old_wc + 1
    Expect new_tn == old_tn
    Expect new_tc == old_tc
  end
end

function GfAlwaysFailureFind()
  return 0
endfunction

function GfSomePathL8C20Find()
  return {'path': 'doc/gf-user.txt', 'line': 8, 'col': 20}
endfunction

function GfSomePathL8C0Find()
  return {'path': 'doc/gf-user.txt', 'line': 8, 'col': 0}
endfunction

function GfNonExistingPathFind()
  return {'path': 'foobarbaz', 'line': 888, 'col': 888}
endfunction

describe 'gf#user#do()'
  before
    new
    call gf#user#extend('GfPathAFind', 1000)
    call gf#user#extend('GfPathBFind', 1000)
  end

  after
    let b:d = gf#user#get_ext_dict()
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'uses the built-in command, then extensions'
    tabnew
    Expect bufname('') ==# ''

    silent call gf#user#do('gf', 'n')
    Expect bufname('') ==# 'test-path-a'

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$
    silent call gf#user#do("\<C-w>f", 'n')
    Expect bufname('') ==# 'doc/gf-user.txt'
  end

  it 'works also in Visual mode'
    tabnew
    Expect bufname('') ==# ''

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$vb
    silent call gf#user#do("\<C-w>f", 'n')
    Expect bufname('') ==# 'test-path-a'
  end
end

function GfPathAFind()
  return {'path': 'test-path-a', 'line': 888, 'col': 888}
endfunction

function GfPathBFind()
  return {'path': 'test-path-b', 'line': 888, 'col': 888}
endfunction

describe 'UI key mappings'
  before
    new
    call gf#user#extend('GfPathAFind', 1000)
    call gf#user#extend('GfPathBFind', 1000)
  end

  after
    let b:d = gf#user#get_ext_dict()
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'uses the built-in command, then extensions'
    tabnew
    Expect bufname('') ==# ''

    execute "silent normal \<Plug>(gf-user-gf)"
    Expect bufname('') ==# 'test-path-a'

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$
    execute "silent normal \<Plug>(gf-user-\<C-w>f)"
    Expect bufname('') ==# 'doc/gf-user.txt'
  end

  it 'works also in Visual mode'
    tabnew
    Expect bufname('') ==# ''

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$vb
    execute "silent normal \<Plug>(gf-user-\<C-w>f)"
    Expect bufname('') ==# 'test-path-a'
  end
end

describe 'Default key mappings'
  before
    new
    call gf#user#extend('GfPathAFind', 1000)
    call gf#user#extend('GfPathBFind', 1000)
  end

  after
    let b:d = gf#user#get_ext_dict()
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'uses the built-in command, then extensions'
    tabnew
    Expect bufname('') ==# ''

    execute "silent normal gf"
    Expect bufname('') ==# 'test-path-a'

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$
    execute "silent normal \<C-w>f"
    Expect bufname('') ==# 'doc/gf-user.txt'
  end

  it 'works also in Visual mode'
    tabnew
    Expect bufname('') ==# ''

    call setline(1, 'doc/gf-user.txt')
    normal! 1gg$vb
    execute "silent normal \<C-w>f"
    Expect bufname('') ==# 'test-path-a'
  end
end
