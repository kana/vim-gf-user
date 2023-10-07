runtime! plugin/gf/user.vim

" The expected value should be 'n'.
" But this test is executed via vspec which runs Vim in Ex mode.
" Therefore mode() returns 'ce' instead of 'n'.
let g:EXPECTED_NORMAL_MODE = 'ce'

function GfUserExtensionFunctionSample()
  let t:mode = mode(1)
  return {'path': 'test-path-a', 'line': 888, 'col': 888}
endfunction

describe 'Extension function'
  before
    new
    call gf#user#extend('GfUserExtensionFunctionSample', 1000)
  end

  after
    let b:d = gf#user#get_ext_dict()
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'correctly detects the current mode (Normal mode)'
    tabnew doc/gf-user.txt
    let t:mode = 'not executed'
    Expect bufname('') ==# 'doc/gf-user.txt'

    execute 'silent normal gf'
    Expect bufname('') ==# 'test-path-a'
    Expect t:mode ==# g:EXPECTED_NORMAL_MODE
    Expect mode(1) ==# g:EXPECTED_NORMAL_MODE
  end

  it 'correctly detects the current mode (Visual mode)'
    tabnew doc/gf-user.txt
    let t:mode = 'not executed'
    Expect bufname('') ==# 'doc/gf-user.txt'

    execute 'silent normal Vgf'
    Expect bufname('') ==# 'test-path-a'
    Expect t:mode ==# 'V'
    Expect mode(1) ==# g:EXPECTED_NORMAL_MODE
  end
end

function GfFailure()
  let t:mode = mode(1)
  return 0
endfunction

describe 'gf-user'
  before
    new
    call gf#user#extend('GfFailure', 1000)
  end

  after
    let b:d = gf#user#get_ext_dict()
    call filter(b:d, '0')
    %bwipeout!
  end

  it 'clears Visual mode if all tries are failed, to behave the same as built-in gf commands'
    tabnew doc/gf-user.txt
    let t:mode = 'not executed'
    Expect bufname('') ==# 'doc/gf-user.txt'

    execute 'silent normal Vgf'
    Expect bufname('') ==# 'doc/gf-user.txt'
    Expect t:mode ==# 'V'
    Expect mode(1) ==# g:EXPECTED_NORMAL_MODE
  end
end
