local M = {}

local filetype = 'MochiCheatsheet'

local cache = {}

---@return integer
function M.show()
    -- check if this buffer is cheatsheet
    if vim.bo.filetype == filetype then
        return vim.api.nvim_get_current_buf()
    end

    -- save previous buffer ID
    cache.previous_buffer = vim.api.nvim_get_current_buf()

    -- create new buffer
    local buffer = vim.api.nvim_create_buf(false, true)

    -- switch to new buffer
    vim.api.nvim_set_current_buf(buffer)

    -- draw cheatsheet
    require('cheatsheet.draw').draw_cheatsheet(buffer)

    -- set vim config of buffer
    vim.opt_local.bufhidden = 'delete'
    vim.opt_local.buflisted = false
    vim.opt_local.modifiable = false
    vim.opt_local.buftype = 'nofile'
    vim.opt_local.number = false
    vim.opt_local.list = false
    vim.opt_local.wrap = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.opt_local.colorcolumn = '0'
    vim.opt_local.foldcolumn = '0'
    vim.opt_local.filetype = filetype

    -- set key to close the cheatsheet
    local close = function()
        vim.api.nvim_set_current_buf(cache.previous_buffer)
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
    vim.keymap.set('n', '<ESC>', close, { buffer = buffer })
    vim.keymap.set('n', 'q', close, { buffer = buffer })

    return buffer
end

---@param opts? MochiCheatsheetOpts
function M.setup(opts)
    local Config = require('cheatsheet.config')
    Config.config = vim.tbl_deep_extend('force', Config.defaults, opts or {})

    ---@type MochiCheatsheetOpts.Keymaps
    Config.config.keymaps = Config.parse_keymap(Config.config.keymaps)
end

return M
