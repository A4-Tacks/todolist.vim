if exists('b:current_syntax')
  finish
endif

syn match todolistPre           /^\s*[+-] / nextgroup=todolistDate
syn match todolistTitle         /^\S.*\ze\n====*$/
syn match todolistTitleBar      /^====*$/
syn match todolistDate          /\v<%(create|pending|finish)\([^)]*\) =/ nextgroup=todolistDate conceal

hi def link todolistPre         Character
hi def link todolistTitle       Define
hi def link todolistTitleBar    Define
hi def link todolistDate        Comment
