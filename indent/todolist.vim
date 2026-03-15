if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

function! GetTodolistIndent() "{{{1
    if getline(v:lnum) =~# '^\s*$'
        let prev = prevnonblank(v:lnum-1)
        return foldclosed(prev) != -1 ? 0 : indent(prev)
    else
        return indent(v:lnum)
    endif
endfunction " }}}1

setlocal indentexpr=GetTodolistIndent()
let b:undo_indent = 'setlocal indentexpr<'
