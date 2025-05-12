do
  local lazy_group_id = 0
  function get_lazy_group_id()
    lazy_group_id = lazy_group_id + 1
    return lazy_group_id - 1
  end
  function get_lazy_group_name()
    return "lazy_load_group" .. get_lazy_group_id()
  end
  function get_lazy_group()
    return vim.api
             .nvim_create_augroup(get_lazy_group_name(), {})
  end
end

local M = {
  lazy_load_on_startup = function(func)
    local gid = get_lazy_group()
    vim.api.nvim_create_autocmd(
      { "CursorHold", "CursorMoved" }, {
        pattern = "*",
        group = gid,
        callback = function()
          vim.api.nvim_del_augroup_by_id(gid)
          func()
        end,
      }
    )
  end,

  lazy_load_on_filetypes = function(filetypes, func)
    local gid = get_lazy_group()
    vim.api.nvim_create_autocmd(
      { "FileType" }, {
        pattern = filetypes,
        group = gid,
        callback = function()
          vim.api.nvim_del_augroup_by_id(gid)
          func()
        end,
      }
    )
  end,

  replace_keys = function(keys)
    --
  end,
  -- let l:keys = substitute(a:keys, "<leader>", g:mapleader, "g")
  -- let l:keys = substitute(l:keys, "<space>", " ", "g")
  -- let l:keys = substitute(l:keys, "<cr>", "\<CR>", "g")
  -- for l in "qwertyuiopasdfghjklzxcvbnm_^"
  --   exe $"let l:keys = substitute(l:keys, '<c-{l}>', '{"\<c-"..l..">"}', 'g')"
  -- endfor
  -- return l:keys
  -- endfunction

  --
}

return M
