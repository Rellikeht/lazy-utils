local lazy_group_id = 0
local function get_group_id()
  lazy_group_id = lazy_group_id + 1
  return lazy_group_id - 1
end
local function get_group_name()
  return "lazy_load_group" .. get_group_id()
end
local function get_group()
  return vim.api.nvim_create_augroup(get_group_name(), {})
end

local function replace_keys(keys)
  -- easy I guess
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function load_on_factory(aucmds)
  return function(func)
    local gid = get_group()
    vim.api.nvim_create_autocmd(
      aucmds, {
        pattern = "*",
        group = gid,
        callback = function()
          vim.api.nvim_del_augroup_by_id(gid)
          func()
        end,
      }
    )
  end
end

local M = {
  replace_keys = replace_keys,
  load_on_cursor = load_on_factory({ "CursorMoved", "CursorHold" }),
  load_on_insert = load_on_factory({ "InsertEnter" }),
  load_on_startup = load_on_factory({
    "CursorMoved", "CursorHold", "VimEnter",
  }),

  load_on_filetypes = function(filetypes, func)
    local gid = get_group()
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

  load_on_keys = function(keys, func, modes, esc)
    if modes == nil then modes = { "n" } end
    if esc then keys = keys .. "<Esc>" end
    vim.keymap.set(
      modes, keys, function()
        vim.keymap.del(modes, keys)
        func()
        if not esc then
          vim.fn.feedkeys(replace_keys(keys), "m")
        end
      end, { noremap = true, silent = true }
    )
  end,

  --
}

return M
