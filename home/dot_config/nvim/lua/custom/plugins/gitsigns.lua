-- kickstart's core gitsigns.setup() (init.lua SECTION 4) doesn't set
-- current_line_blame; turn it on without re-declaring the whole config
-- (recommended keymaps, including the <leader>tb toggle, are on by default).
require('gitsigns.config').config.current_line_blame = true
