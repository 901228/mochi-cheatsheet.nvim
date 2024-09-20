---@meta

---@class MochiCheatsheetOpts.Key
---@field name string
---@field key string

---@alias MochiCheatsheetOpts.Keymaps table<string, MochiCheatsheetOpts.Key[]>

---@class MochiCheatsheetOpts.Header
---@field color string
---@field header string[]

---@class MochiCheatsheetOpts
---@field header? MochiCheatsheetOpts.Header
---@field keymaps? table<string, (MochiCheatsheetOpts.Key | { [1]: string, [2]: string })[]>
---@field colors? string[]
---@field block_bg? string
