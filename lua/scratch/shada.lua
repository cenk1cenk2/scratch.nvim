local M = {}

M.prefix = "SHADA_SCRATCH_"

function M.set(key, value)
  vim.g[M.prefix .. key] = value
end

function M.get(key)
  return vim.g[M.prefix .. key]
end

function M.delete(key)
  vim.g[M.prefix .. key] = nil
end

return M
