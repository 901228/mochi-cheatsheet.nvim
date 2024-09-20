local M = {}

M.highlights = {
    header = 'MochiCheatsheetHeader',
    color_num = 0,
}

---@param namespace integer
---@param colors string[]
---@param header_color string
---@param block_bg string
local function setup_highlight_group(namespace, header_color, colors, block_bg)
    vim.api.nvim_set_hl(namespace, M.highlights.header, {
        fg = header_color,
        -- fg = 'bg',
        -- bg = header_color,
    })

    local i = 1
    for _, color in pairs(colors) do
        vim.api.nvim_set_hl(namespace, 'MochiCheatsheetHead' .. tostring(i), {
            fg = 'bg',
            bg = color,
        })
        vim.api.nvim_set_hl(namespace, 'MochiCheatsheetText' .. tostring(i), {
            fg = color,
            bg = block_bg,
        })
        i = i + 1
    end
    M.highlights.color_num = i - 1

    vim.api.nvim_set_hl_ns(namespace)
end

local draw = {
    MIDDLE = 8,
}

---@param buf integer
---@param namespace integer
---@param header string[]
---@return integer
function draw.header(buf, namespace, header)
    ---@type string[]
    local ascii_header = vim.tbl_values(header)
    local win_width = vim.api.nvim_win_get_width(0) - 4

    -- calculate paddings
    local ascii_padding = math.floor((win_width - vim.fn.strdisplaywidth(ascii_header[1])) / 2)
    local padding_str = string.rep(' ', ascii_padding)
    for i, str in ipairs(ascii_header) do
        ascii_header[i] = padding_str .. str .. '  '
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, ascii_header)

    -- add highlights
    for i = 1, #ascii_header do
        vim.api.nvim_buf_add_highlight(
            buf,
            namespace,
            M.highlights.header,
            i - 1,
            vim.fn.byteidx(ascii_header[i], ascii_padding - 2),
            vim.fn.byteidx(ascii_header[i], vim.fn.strdisplaywidth(ascii_header[i]))
        )
    end

    return #ascii_header
end

---@param buf integer
---@param namespace integer
---@param line integer
---@param head string
---@param keys MochiCheatsheetOpts.Key[]
---@param color_id integer
---@param length? integer
---@param offset? integer
---@return integer
function draw.block(buf, namespace, line, head, keys, color_id, length, offset)
    if offset == nil or offset < 0 then offset = 0 end
    if length == nil or length < 0 then length = 0 end

    -- draw head --------------------------------------------------
    local start_col = math.floor((length - vim.fn.strdisplaywidth(head)) / 2) + offset
    local end_col = start_col + vim.fn.strdisplaywidth(head)
    head = string.rep(' ', start_col) .. head
    head = head .. string.rep(' ', length + offset - vim.fn.strdisplaywidth(head))
    local head_lines = { head, string.rep(' ', length + offset) }

    vim.api.nvim_buf_set_lines(buf, line, line + 1, false, head_lines)
    for i = 1, 2 do
        vim.api.nvim_buf_add_highlight(
            buf,
            namespace,
            'MochiCheatsheetText' .. tostring(color_id),
            line + i - 1,
            vim.fn.byteidx(head_lines[i], offset + 1),
            vim.fn.byteidx(head_lines[i], vim.fn.strdisplaywidth(head_lines[1]) - 1)
        )
    end
    -- draw head --------------------------------------------------

    -- draw keymaps
    for i, key in ipairs(keys) do
        local n = key.name
        local k = key.key

        if vim.fn.strdisplaywidth(k) > length - draw.MIDDLE then k = k:sub(1, length - draw.MIDDLE) .. '...' end

        if vim.fn.strdisplaywidth(n) > length - draw.MIDDLE - vim.fn.strdisplaywidth(k) then
            n = n:sub(1, length - draw.MIDDLE - vim.fn.strdisplaywidth(k)) .. '...'
        end

        local key_str = string.rep(' ', offset)
            .. '  '
            .. n
            .. string.rep(' ', length - vim.fn.strdisplaywidth(n .. k) - 4)
            .. k
            .. '  '

        -- write text
        vim.api.nvim_buf_set_lines(buf, line + i + 1, line + i + 1, false, { key_str })

        -- setup highlight
        vim.api.nvim_buf_add_highlight(
            buf,
            namespace,
            'MochiCheatsheetText' .. tostring(color_id),
            line + i + 1,
            vim.fn.byteidx(key_str, offset + 1),
            vim.fn.byteidx(key_str, vim.fn.strdisplaywidth(key_str) - 1)
        )
    end

    -- overwrite head highlights
    vim.api.nvim_buf_add_highlight(
        buf,
        namespace,
        'MochiCheatsheetHead' .. tostring(color_id),
        line,
        vim.fn.byteidx(head, start_col - 1),
        vim.fn.byteidx(head, end_col + 1)
    )

    -- add padding between blocks
    local paddings = { string.rep(' ', offset + length), string.rep(' ', offset + length) }
    vim.api.nvim_buf_set_lines(buf, line + #keys + 2, line + #keys + 3, false, paddings)
    vim.api.nvim_buf_add_highlight(
        buf,
        namespace,
        'MochiCheatsheetText' .. tostring(color_id),
        line + #keys + 2,
        vim.fn.byteidx(paddings[1], offset + 1),
        vim.fn.byteidx(paddings[1], vim.fn.strdisplaywidth(paddings[1]) - 1)
    )

    return #keys + 4
end

---@param buf integer
function M.draw_cheatsheet(buf)
    local config = require('cheatsheet.config').config

    -- create namespace
    local namespace = vim.api.nvim_create_namespace('mochi_cheatsheet')

    -- get win width
    local win_width = vim.api.nvim_win_get_width(0) - 4

    -- setup highlights
    setup_highlight_group(namespace, config.header.color, config.colors, config.block_bg)

    local line = 0

    -- draw header
    line = line + draw.header(buf, namespace, config.header.header)

    -- draw padding between header and contents
    local PADDING = 2
    local padding_str = {}
    for i = 1, PADDING do
        -- padding_str[i] = ' '
        padding_str[i] = string.rep(' ', win_width - 4)
    end
    vim.api.nvim_buf_set_lines(buf, line, line + PADDING, false, padding_str)
    line = line + PADDING

    -- calculate keymaps width
    local LENGTH = 50
    for _, keymap in pairs(config.keymaps) do
        for _, key in ipairs(keymap) do
            local l = vim.fn.strdisplaywidth(key.name) + vim.fn.strdisplaywidth(key.key) + draw.MIDDLE
            if l > LENGTH and l <= win_width then LENGTH = l end
        end
    end

    local offset = math.floor((win_width - LENGTH) / 2)

    -- draw keymaps
    local color_id = 1
    for head, keys in pairs(config.keymaps) do
        line = line + draw.block(buf, namespace, line, head, keys, color_id, LENGTH, offset)
        if color_id >= M.highlights.color_num then
            color_id = 1
        else
            color_id = color_id + 1
        end
    end
end

return M
