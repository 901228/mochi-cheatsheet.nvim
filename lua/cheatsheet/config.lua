local M = {}

---@type MochiCheatsheetOpts
M.defaults = {
    header = {
        color = '#89DCEB',
        header = {
            -- 🭫
            '                                       ',
            '█▀▀ █▃█ █🬰🬰 🬎 ▀█▀ █🬰🬰 █▃█ █🬂🬂 █🬰🬰 ▀█▀',
            '█▄▄ █🮂█ █🬭🬭 █🬋█  █  🬭🬭█ █🮂█ █🬰🬰 █🬭🬭  █ ',
            '                                       ',
        },
    },
    keymaps = {},
    colors = {
        white = '#CDD6F4',
        gray = '#6C7086',
        blue = '#89B4FA',
        teal = '#94E2D5',
        red = '#F38BA8',
        green = '#A6E3A1',
        yellow = '#F9E2AF',
        peach = '#FAB387',
        lavender = '#B4BEFE',
        mauve = '#CBA6F7',
    },
    block_bg = '#313244'
}

---@type MochiCheatsheetOpts
M.config = {}

---@param keymaps? table<string, (MochiCheatsheetOpts.Key | { [1]: string, [2]: string })[]>
---@return MochiCheatsheetOpts.Keymaps
function M.parse_keymap(keymaps)
    keymaps = keymaps or {}

    ---@type MochiCheatsheetOpts.Keymaps
    local _keymaps = {}
    for category, keys in pairs(keymaps) do
        _keymaps[category] = {}
        for _, key in ipairs(keys) do
            local k = key.key or key[2]
            if k ~= nil then
                local n = key.name or key[1] or ''
                _keymaps[category][#_keymaps[category] + 1] = { name = n, key = k }
            end
        end
    end

    return _keymaps
end

return M
