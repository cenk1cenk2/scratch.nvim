local M = {}

local utils = require("scratch.utils")

---@class scratch.CreateScratchBufferOptions
---@field filetype? string Filetype of the scratch buffer. [default=vim.ui.select]
---@field cwd? boolean Whether to use the current working directory or not. [default=true]
---@field events string[] Event to delete the scratch buffer on. [default={"BufDelete", "VimLeavePre"}]

--- Creates a new scratch buffer.
---@param opts scratch.CreateScratchBufferOptions
function M.create_scratch_buffer(opts)
  opts = vim.tbl_deep_extend("force", {
    events = { "BufDelete", "VimLeavePre" },
    cwd = true,
  }, opts or {})

  local filetypes = vim.fn.getcompletion("", "filetype")

  local c = require("scratch.config").get()

  local log = require("scratch.utils").setup({ level = c.log_level })

  local cb = function(filetype)
    local bufnr = vim.api.nvim_create_buf(true, false)

    ---@type string
    local filename
    if opts.cwd then
      filename = ("%s.%s"):format(os.tmpname(), filetype)
    else
      filename = ("_scratch-%s.%s"):format(utils.uuid(), filetype)
    end

    vim.api.nvim_buf_set_name(bufnr, filename)
    vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    vim.api.nvim_win_set_buf(0, bufnr)
    log.info("Created temporary file: %s", filename)

    local augroup = vim.api.nvim_create_augroup("scratch", {})
    vim.api.create_autocmd({
      augroup = augroup,
      event = opts.events,
      buffer = bufnr,
      callback = function()
        os.remove(filename)

        log:info("Removed temporary file: %s", filename)
      end,
    })
  end

  if opts.filetype then
    return cb(opts.filetype)
  end

  vim.ui.select(filetypes, {
    prompt = "Select a filetype",
  }, function(filetype)
    if filetype == nil then
      log.warn("Nothing to create.")

      return
    end

    cb(filetype)
  end)
end

--- Executes the current buffer in to a callback.
---@param cb fun(filename: string, lines: string[]): nil
function M.execute_scratch_buffer(cb)
  local c = require("scratch.config").get()

  local log = require("scratch.utils").setup({ level = c.log_level })

  local shada = require("scratch.shada")
  local store_key = "EXECUTE_SCRATCH_BUFFER_LAST"
  local stored_value = shada.get(store_key)

  local bufnr = vim.api.nvim_get_current_buf()

  vim.ui.input({
    prompt = "Command",
    default = stored_value,
  }, function(command)
    if command == nil then
      log.warn("Nothing to execute.")

      return
    end

    shada.set(store_key, command)

    local filename = vim.fn.expand("%")
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    cb(filename, lines)
  end)
end

return M
