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
    let line = substitute(line, s:prefix_pattern, "", "")
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
let s:prefix_pattern = '\v^[+-] =\zs%(%(create|pending|finish)\([^)]*\) =)*'

com! -buffer TodolistInit call append(0, [
            \ s:wait, repeat('=', 78), '',
            \ s:pend, repeat('=', 78), '',
            \ s:todo, repeat('=', 78), '',
            \])

function! s:date()
    return strftime('%Y-%m-%d %H:%M', localtime())
endfunction

function! s:del_item()
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
endfunction

function! s:jump_chunk(down, move) abort
    let chunk_pattern = $'^\V\%({s:todo}\|{s:pend}\|{s:wait}\)'
    let back = a:down ? "" : "b"

    if a:move
        call s:del_item()
    endif

    call search(chunk_pattern, 'ws'.back)
    norm!j
    call search(chunk_pattern, 'w'.back)
    exe 'norm!' prevnonblank(line('.')-1).'G'
    let chunk = trim(getline(search(chunk_pattern, 'nwb')))

    if a:move
        norm!p
    endif

    let item = getline('.')
    let prefix = matchend(item, s:prefix_pattern)
    if prefix != -1
        if chunk == s:pend
            call setline(line('.'), item[:prefix-1].$'pending({s:date()}) '.item[prefix:])
        endif
    endif
endfunction

nnoremap <buffer><silent> <c-j> :<c-u>call <SID>jump_chunk(1, 0)<cr>
nnoremap <buffer><silent> <c-k> :<c-u>call <SID>jump_chunk(0, 0)<cr>
xnoremap <buffer><silent> <c-j> :<c-u>call <SID>jump_chunk(1, 1)<cr>
xnoremap <buffer><silent> <c-k> :<c-u>call <SID>jump_chunk(0, 1)<cr>

let b:undo_ftplugin = 'setlocal shiftwidth< foldmethod< foldexpr< foldtext<'
            \ . '| delc -buffer TodolistInit'
            \ . '| nunmap <buffer> <c-j>'
            \ . '| nunmap <buffer> <c-k>'
            \ . '| xunmap <buffer> <c-j>'
            \ . '| xunmap <buffer> <c-k>'
