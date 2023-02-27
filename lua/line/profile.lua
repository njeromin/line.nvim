local line

---Profile how long it takes to run a function
---@param name string
---@param fn function
return function(name, fn, ...)
  local l = line or require("line")
  if not l.config.profile then
    fn(...)
    return
  end

  local time_start = os.clock()

  fn(...)

  local time_delta = (os.clock() - time_start) * 1000
  -- TODO: use something better to send messages rather than relying on the config being loaded into ui before 100ms have passed
  vim.defer_fn(function()
    vim.notify(string.format("%s took %.1f ms.", name, time_delta), nil, { title = "line.nvim - profile" })
  end, 100)
end
