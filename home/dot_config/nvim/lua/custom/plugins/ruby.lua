-- nvim-lspconfig ships a default `lsp/ruby_lsp.lua` config; kickstart's core
-- `servers` table (init.lua SECTION 6) doesn't include it, so enable it here
-- and make sure Mason installs the binary, independent of that table.
require('mason-tool-installer').setup { ensure_installed = { 'ruby-lsp' } }
vim.lsp.enable 'ruby_lsp'
