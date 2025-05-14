do
  local lazy_group_id = 0
  function get_group_id()
    lazy_group_id = lazy_group_id + 1
    return lazy_group_id - 1
  end
  function get_group_name()
    return "lazy_load_group" .. get_group_id()
  end
  function get_group()
    return vim.api.nvim_create_augroup(get_group_name(), {})
  end
end

local M = {
  load_on_startup = function(func)
    local gid = get_group()
    vim.api.nvim_create_autocmd(
      {"CursorHold", "CursorMoved"}, {
        pattern = "*",
        group = gid,
        callback = function()
          vim.api.nvim_del_augroup_by_id(gid)
          func()
        end,
      }
    )
  end,

  load_on_insert = function(func)
    local gid = get_group()
    vim.api.nvim_create_autocmd(
      {"InsertEnter"}, {
        pattern = "*",
        group = gid,
        callback = function()
          vim.api.nvim_del_augroup_by_id(gid)
          func()
        end,
      }
    )
  end,

  load_on_filetypes = function(filetypes, func)
    local gid = get_group()
    vim.api.nvim_create_autocmd(
      {"FileType"}, {
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
    -- easy I guess
    return vim.api
             .nvim_replace_termcodes(keys, true, true, true)
  end,

  load_on_keys = function(keys, func)
    local modes = {"n"}
    vim.keymap.set(
      modes, keys, function()
        vim.keymap.del(modes, keys)
        vim.fn.feedkeys(replace_keys(keys), "m")
        func()
      end, {noremap = true, silent = true}
    )
  end,

  --
}

return M
