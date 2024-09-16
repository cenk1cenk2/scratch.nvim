local M = {}

---@class scratch.Config
---@field log_level? number

---@type scratch.Config
local defaults = {
  log_level = vim.log.levels.INFO,
}

---@type scratch.Config
---@diagnostic disable-next-line: missing-fields
M.options = nil

---@return scratch.Config
function M.read()
  return M.options or defaults
end

---@param config scratch.Config
---@return scratch.Config
function M.setup(config)
  M.options = vim.tbl_deep_extend("force", {}, defaults, config or {})

  return M.options
end

return M
