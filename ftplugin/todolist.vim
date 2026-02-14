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

function! s:jump_chunk(down, move) abort
    let chunk_pattern = $'^\V\%({s:todo}\|{s:pend}\|{s:wait}\)'
    let back = a:down ? "" : "b"

    if a:move
        let item = line('.')
        while item > 1 && getline(item) !~ '^[+-] '
            let item -= 1
        endwhile
        let item_to = item
        while nextnonblank(item_to+1) <= line('$')
                    \&& nextnonblank(item_to+1) != 0
                    \&& getline(nextnonblank(item_to+1)) !~ '^\S'
            let item_to += 1
        endwhile
        exe $'norm!{item}Gd{item_to}G'
    endif

    call search(chunk_pattern, 'ws'.back)
    let chunk = trim(getline('.'))
    norm!j
    call search(chunk_pattern, 'w'.back)
    exe 'norm!' prevnonblank(line('.')-1).'G'

    if a:move
        norm!p
    endif
endfunction

nnoremap <buffer> <c-j> :<c-u>call <SID>jump_chunk(1, 0)<cr>
nnoremap <buffer> <c-k> :<c-u>call <SID>jump_chunk(0, 0)<cr>
xnoremap <buffer> <c-j> :<c-u>call <SID>jump_chunk(1, 1)<cr>
xnoremap <buffer> <c-k> :<c-u>call <SID>jump_chunk(0, 1)<cr>

let b:undo_ftplugin = 'setlocal shiftwidth< foldmethod< foldexpr< foldtext<'
            \ . '| delc -buffer TodolistInit'
            \ . '| nunmap <buffer> <c-j>'
            \ . '| nunmap <buffer> <c-k>'
            \ . '| xunmap <buffer> <c-j>'
            \ . '| xunmap <buffer> <c-k>'
