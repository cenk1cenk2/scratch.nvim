local M = {}

---@class scratch.Config
---@field log_level? number
---@field cwd? boolean | string Whether to use the current working directory or not. [default=true]
---@field events? string[] Event to delete the scratch buffer on. [default={"BufDelete", "VimLeavePre"}]

---@type scratch.Config
local defaults = {
  log_level = vim.log.levels.INFO,
  cwd = true,
  events = { "BufDelete", "VimLeavePre" },
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
