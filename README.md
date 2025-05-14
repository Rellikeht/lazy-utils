# lazy-utils

(neo)vim utilities for lazy loading and initialization of plugins.

Created for situations when some part of configuration is too big
(for example hundreds of procedurally generated keymaps) or plugin
is too slow to be loaded eagerly at startup (nvim-treesitter, nvim-lspconfig).

It consists of two parts (apis): vimscript and lua. Their capabilities
are almost identical. Functions provided are:

- `load_on_startup` (`lazy_utils#LoadOnStartup`) - uses `CursorHold`
  and `CursorMoved` events
- `load_on_insert` (`lazy_utils#LoadOnInsert`) - uses `InsertEnter`
  event
- `load_on_filetypes` (`lazy_utils#LoadOnFiletypes`) - uses `Filetype`
  event
- `load_on_keys` (`lazy_utils#LoadOnKeys`) - remaps given key combination
  (it is expected to be common denominator of other combinations mapped
  by function in second argument) to run function given as second argument,
  unmap combination and simulate pressing it
