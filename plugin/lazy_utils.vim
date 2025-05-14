if exists("g:loaded_lazy_utils")
  finish
endif

let g:loaded_lazy_utils = 1
let s:lazy_group_id = 0
let s:lazy_helper_id = 0

function! s:GetGroupName()
  let s:lazy_group_id = s:lazy_group_id + 1
  return "lazy_utils_group_"..s:lazy_group_id
endfunction

function! s:GetHelperName()
  let s:lazy_helper_id = s:lazy_helper_id + 1
  return "<SID>LazyHelper_"..s:lazy_helper_id
endfunction

function! lazy_utils#ReplaceCodes(keys)
  " Why there isn't builtin solution for this
  let l:keys = substitute(a:keys, "<leader>", g:mapleader, "g")
  let l:keys = substitute(l:keys, "<space>", " ", "g")
  let l:keys = substitute(l:keys, "<cr>", "\<CR>", "g")
  for l in "qwertyuiopasdfghjklzxcvbnm_^"
    exe $"let l:keys = substitute(l:keys, '<c-{l}>', '{"\<c-"..l..">"}', 'g')"
  endfor
  return l:keys
endfunction

" this currently runs after moving cursor despite name of the event
" (tested in vim)
" TODO B maybe there is way to run this automatically after some time
function! lazy_utils#LoadOnStartup(func)
  let l:group_name = s:GetGroupName()
  let l:helper_name = s:GetHelperName()
  let l:def =<< trim eval STOP
  function {l:helper_name}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! CursorHold,CursorMoved * call {l:helper_name}()
  augroup END
  STOP
  exe join(l:def, "\n")
endfunction

function! lazy_utils#LoadOnInsert(func)
  let l:group_name = s:GetGroupName()
  let l:helper_name = s:GetHelperName()
  let l:def =<< trim eval STOP
  function {l:helper_name}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! InsertEnter * call {l:helper_name}()
  augroup END
  STOP
  exe join(l:def, "\n")
endfunction

function! lazy_utils#LoadOnFiletypes(filetypes, func)
  let l:group_name = s:GetGroupName()
  let l:helper_name = s:GetHelperName()
  let l:def =<< trim eval STOP
  function {l:helper_name}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! FileType {a:filetypes} call {l:helper_name}()
  augroup END
  STOP
  exe join(l:def, "\n")
endfunction

function! lazy_utils#LoadOnKeys(keys, func, esc=0)
  " Just to shorten call at the end
  let l:helper_name = s:GetHelperName()
  let l:keys = keys..(a:esc ? "<Esc>" : "")
  let l:call = $":<C-u>call {l:helper_name}()<CR>"
  let l:def =<< trim eval STOP
  function s:LazyHelper_{s:lazy_helper_id}()
    nunmap {l:keys}
    call {a:func}()
    if {a:esc}
      call feedkeys(lazy_utils#ReplaceCodes("{l:keys}"), "m")
    endif
  endfunction
  nnoremap <silent> {l:keys} {l:call}
  STOP
  exe join(l:def, "\n")
endfunction
