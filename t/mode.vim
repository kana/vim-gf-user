runtime! plugin/gf/user.vim

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
    Expect t:mode ==# 'n'
  end

  it 'correctly detects the current mode (Visual mode)'
    tabnew doc/gf-user.txt
    let t:mode = 'not executed'
    Expect bufname('') ==# 'doc/gf-user.txt'

    execute 'silent normal Vgf'
    Expect bufname('') ==# 'test-path-a'
    Expect t:mode ==# 'V'
  end
end
