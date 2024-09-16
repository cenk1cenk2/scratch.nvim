local M = {}

local utils = require("scratch.utils")

---@class scratch.CreateScratchBufferOptions
---@field filetype? string Filetype of the scratch buffer. [default=vim.ui.select]
---@field cwd? boolean | string Whether to use the current working directory or not. [default=true]
---@field events? string[] Event to delete the scratch buffer on. [default={"BufDelete", "VimLeavePre"}]

--- Creates a new scratch buffer.
---@param opts scratch.CreateScratchBufferOptions
function M.create_scratch_buffer(opts)
  local c = require("scratch.config").read()

  opts = vim.tbl_deep_extend("force", {}, c, opts or {})

  local log = require("scratch.log").setup({ level = c.log_level })

  local cb = function(filetype)
    local bufnr = vim.api.nvim_create_buf(true, false)

    ---@type string
    local filename
    if type(opts.cwd) == "string" then
      filename = ("%s/_scratch-%s.%s"):format(opts.cwd, utils.uuid(), filetype)
    elseif opts.cwd then
      filename = ("_scratch-%s.%s"):format(utils.uuid(), filetype)
    else
      filename = ("%s.%s"):format(os.tmpname(), filetype)
    end

    vim.api.nvim_buf_set_name(bufnr, filename)
    vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    vim.api.nvim_win_set_buf(0, bufnr)
    log.info("Created temporary file: %s", filename)

    local augroup = vim.api.nvim_create_augroup("scratch", {})
    vim.api.nvim_create_autocmd(opts.events, {
      group = augroup,
      buffer = bufnr,
      once = true,
      callback = function()
        local _, err = os.remove(filename)

        if err then
          log.error("Failed to remove temporary file: %s -> %s", filename, err)

          return
        end

        log.info("Removed temporary file: %s", filename)
      end,
    })
  end

  if opts.filetype then
    return cb(opts.filetype)
  end

  vim.ui.select(vim.fn.getcompletion("", "filetype"), {
    prompt = "Select a filetype",
  }, function(filetype)
    if filetype == nil then
      log.warn("Nothing to create.")

      return
    end

    cb(filetype)
  end)
end

---@class scratch.ExecuteScratchBufferCallbackOptions
---@field filename string
---@field path string
---@field bufnr number
---@field command string

--- Executes the current buffer in to a callback.
---@param cb fun(opts: scratch.ExecuteScratchBufferCallbackOptions): nil
function M.execute_scratch_buffer(cb)
  local c = require("scratch.config").read()

  local log = require("scratch.log").setup({ level = c.log_level })

  local shada = require("scratch.shada")
  local store_key = "EXECUTE_SCRATCH_BUFFER_LAST"
  local stored_value = shada.get(store_key)

  local bufnr = vim.api.nvim_get_current_buf()

  vim.ui.input({
    prompt = "Command",
    default = stored_value,
    completion = "shellcmd",
  }, function(command)
    if command == nil then
      log.warn("Nothing to execute.")

      return
    end

    shada.set(store_key, command)

    cb({
      bufnr = bufnr,
      filename = vim.api.nvim_buf_get_name(bufnr),
      path = vim.fn.expand(("%%%s:p"):format(bufnr)),
      command = command,
    })
  end)
end

return M
