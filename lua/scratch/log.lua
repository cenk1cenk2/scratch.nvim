-- Inspired by rxi/log.lua
-- Modified by tjdevries and can be found at github.com/tjdevries/vlog.nvim
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

---@class scratch.Logger: scratch.LogAtLevel
---@field setup scratch.LoggerSetupFn
---@field config scratch.LoggerConfig
---@field p scratch.LogAtLevel

---@class scratch.LogAtLevel
---@field trace fun(...: any): string
---@field debug fun(...: any): string
---@field info fun(...: any): string
---@field warn fun(...: any): string
---@field error fun(...: any): string

---@class scratch.Logger
local M = {
  ---@diagnostic disable-next-line: missing-fields
  p = {},
}

---@class scratch.LoggerConfig
---@field level number
---@field plugin string
---@field modes scratch.LoggerMode[]

---@class scratch.LoggerMode
---@field name string
---@field level number

---@type scratch.LoggerConfig
M.config = {
  level = vim.log.levels.INFO,
  plugin = "scratch.nvim",
  modes = {
    { name = "trace", level = vim.log.levels.TRACE },
    { name = "debug", level = vim.log.levels.DEBUG },
    { name = "info", level = vim.log.levels.INFO },
    { name = "warn", level = vim.log.levels.WARN },
    { name = "error", level = vim.log.levels.ERROR },
  },
}

---@class scratch.LoggerSetup
---@field level? number

---@alias scratch.LoggerSetupFn fun(config?: scratch.LoggerSetup): scratch.Logger

---@type scratch.LoggerSetupFn
function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  local log = function(mode, sprintf, ...)
    if mode.level < M.config.level then
      return
    end

    local console = string.format("[%-5s]: %s", mode.name:upper(), sprintf(...))

    for _, line in ipairs(vim.split(console, "\n")) do
      vim.notify(([[[%s] %s]]):format(M.config.plugin, line), mode.level)
    end
  end

  for _, mode in pairs(M.config.modes) do
    ---@diagnostic disable-next-line: assign-type-mismatch
    M[mode.name] = function(...)
      return log(mode, function(...)
        local passed = { ... }
        local fmt = table.remove(passed, 1)
        local inspected = {}

        for _, v in ipairs(passed) do
          table.insert(inspected, vim.inspect(v))
        end

        return fmt:format(unpack(inspected))
      end, ...)
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    M.p[mode.name] = function(...)
      return log(mode, function(...)
        local passed = { ... }
        local fmt = table.remove(passed, 1)

        return fmt
      end, ...)
    end
  end

  return M
end

--- Sets the log level of the logger.
---@param level integer
function M.set_log_level(level)
  M.config.level = level
end

return M
