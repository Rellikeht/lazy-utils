if exists("g:loaded_lazy_utils")
  finish
endif

let g:loaded_lazy_utils = 1
let s:lazy_group_id = 0
let s:lazy_helper_id = 0

" this currently runs after moving cursor despite name of the event
" (tested in vim)
" TODO B maybe there is way to run this automatically after some time
function! LazyLoadOnStartup(func)
  let l:group_name = "lazy_load_group_"..s:lazy_group_id
  let l:def =<< trim eval STOP
  function s:LazyHelper_{s:lazy_helper_id}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! CursorHold * call s:LazyHelper_{s:lazy_helper_id}()
  augroup END
  STOP
  exe join(l:def, "\n")
  let s:lazy_group_id = s:lazy_group_id + 1
  let s:lazy_helper_id = s:lazy_helper_id + 1
endfunction

function! LazyLoadOnInsert(func)
  let l:group_name = "lazy_load_group_"..s:lazy_group_id
  let l:def =<< trim eval STOP
  function s:LazyHelper_{s:lazy_helper_id}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! InsertEnter * call s:LazyHelper_{s:lazy_helper_id}()
  augroup END
  STOP
  exe join(l:def, "\n")
  let s:lazy_group_id = s:lazy_group_id + 1
  let s:lazy_helper_id = s:lazy_helper_id + 1
endfunction

function! LazyLoadOnFiletypes(filetypes, func)
  let l:group_name = "lazy_load_group_"..s:lazy_group_id
  let l:def =<< trim eval STOP
  function s:LazyHelper_{s:lazy_helper_id}()
    augroup {l:group_name}
    autocmd!
    call {a:func}()
    augroup END
  endfunction
  augroup {l:group_name}
  autocmd! FileType {a:filetypes} call s:LazyHelper_{s:lazy_helper_id}()
  augroup END
  STOP
  exe join(l:def, "\n")
  let s:lazy_group_id = s:lazy_group_id + 1
  let s:lazy_helper_id = s:lazy_helper_id + 1
endfunction

" not very polished thing
function! ReplaceCodes(keys)
  " Why there isn't builtin solution for this
  let l:keys = substitute(a:keys, "<leader>", g:mapleader, "g")
  let l:keys = substitute(l:keys, "<space>", " ", "g")
  let l:keys = substitute(l:keys, "<cr>", "\<CR>", "g")
  for l in "qwertyuiopasdfghjklzxcvbnm_^"
    exe $"let l:keys = substitute(l:keys, '<c-{l}>', '{"\<c-"..l..">"}', 'g')"
  endfor
  return l:keys
endfunction

function! LazyLoadOnKeys(keys, func, esc=0)
  " Just to shorten call at the end
  let l:call = $":<C-u>call <SID>LazyHelper_{s:lazy_helper_id}()<CR>"
  let l:def =<< trim eval STOP
  function s:LazyHelper_{s:lazy_helper_id}()
    call {a:func}()
    nunmap {a:keys}{(a:esc)?"<Esc>":""}
    call feedkeys(ReplaceCodes("{a:keys}"), "m")
  endfunction
  nnoremap <silent> {a:keys}{(a:esc)?"<Esc>":""} {l:call}
  STOP
  exe join(l:def, "\n")
  let s:lazy_helper_id = s:lazy_helper_id + 1
endfunction
