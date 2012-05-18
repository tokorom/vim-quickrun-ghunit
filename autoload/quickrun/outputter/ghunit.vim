" quickrun: outputter: ghunit
" Author : tokorom <tokorom@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.config = {
\ }

function! s:outputter.finish(session)
  let data = self._result
  lclose
  if stridx(data, '** BUILD SUCCEEDED **') > 0
    " Success
    let message = matchstr(data, 'Executed .*)\.')
    if 0 == strlen(message)
      let message = '** ALL GREEN **'
    endif
    highlight GHUnitSuccess term=reverse ctermbg=darkgreen guibg=darkgreen
    echohl GHUnitSuccess | echo message | echohl None
  else
    " Failed
    try
      if data =~ '\vFile\:[^:]+Line\:'
        set errorformat=%E%.%#File:\ %f,%C%.%#Line:\ %l,%Z%.%#Reason:\ %m
        let message = matchstr(data, '\zsFailed tests.*\zeCommand ')
        if 0 == strlen(message)
          let message = '** FAILED **'
        endif
      else
        set errorformat=%f:%l:%*[^:]:\ %m
        let message = '** BUILD FAILED **'
      endif
      cgetexpr self._result
      cwindow
      cc
      for winnr in range(1, winnr('$'))
        if getwinvar(winnr, '&buftype') ==# 'ghunit'
          call setwinvar(winnr, 'quickfix_title', 'quickrun: ' .
          \   join(a:session.commands, ' && '))
          break
        endif
      endfor
      highlight GHUnitFailed term=reverse ctermbg=darkred guibg=darkred
      echohl GHUnitFailed | echo message | echohl None
    finally
    endtry
  endif
endfunction


function! quickrun#outputter#ghunit#new()
  return deepcopy(s:outputter)
endfunction

let &cpo = s:save_cpo
