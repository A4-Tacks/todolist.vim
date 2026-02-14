if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

function! GetTodolistFold() "{{{1
    let line = getline(v:lnum)
    if line =~# '^\s*$'
        return foldlevel(nextnonblank(v:lnum+1))
    endif
    let indent = max([0, match(line, '^\s*\%([+-] \)\=\zs\S')]) / &sw
    if getline(v:lnum) =~# '^\s*[+-] '
        if indent <= 1 && getline(prevnonblank(v:lnum-1)) =~# '^[+-] '
                    \  && getline(nextnonblank(v:lnum+1)) =~# '^[+-] '
            return 0
        endif
        return '>'.indent
    endif
    return indent
endfunction " }}}1
function! GetTodolistFoldText() "{{{1
    let line = getline(v:foldstart)
    let end = &colorcolumn ? &colorcolumn : 79
    let width = strdisplaywidth(line)
    return line . repeat(" ", end-width) . "@" . (v:foldend-v:foldstart+1)
endfunction " }}}1

setlocal shiftwidth=2
setlocal foldmethod=expr
setlocal foldexpr=GetTodolistFold()
setlocal foldtext=GetTodolistFoldText()

let s:todo = '# 待办事项'
let s:pend = '# 等待事项'
let s:wait = '# 长期待办'

com! -buffer TodolistInit call append(0, [
            \ s:wait, repeat('=', 78), '',
            \ s:pend, repeat('=', 78), '',
            \ s:todo, repeat('=', 78), '',
            \])

let b:undo_ftplugin = 'setlocal shiftwidth< foldmethod< foldexpr< foldtext<'
            \ . '| delc -buffer TodolistInit'
