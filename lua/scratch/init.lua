local M = {}

---@param config scratch.Config
function M.setup(config)
  local c = require("scratch.config").setup(config)

  local log = require("scratch.log").setup({ level = c.log_level })

  log.debug("Plugin has been setup: %s", c)
end

return M
