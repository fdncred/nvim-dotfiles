--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.10-dev') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local check_external_reqs = function()
  -- Required for this configuration on Neovim v0.12.
  for _, exe in ipairs { 'git', 'unzip', 'rg', 'nu', 'cmake' } do
    if vim.fn.executable(exe) == 1 then
      vim.health.ok(string.format("Found required executable: '%s'", exe))
    else
      vim.health.error(string.format("Missing required executable: '%s'", exe))
    end
  end

  -- Optional tools enabled by configured plugins/filetypes.
  for _, exe in ipairs { 'make', 'markdownlint', 'topiary' } do
    if vim.fn.executable(exe) == 1 then
      vim.health.ok(string.format("Found optional executable: '%s'", exe))
    else
      vim.health.info(string.format("Optional executable not found: '%s'", exe))
    end
  end

  local lua_ls_fallbacks = {
    vim.fn.stdpath 'data' .. '/lsp-servers/lua-language-server/bin/lua-language-server',
    vim.fn.stdpath 'data' .. '/lsp-servers/lua-language-server/bin/lua-language-server.exe',
    vim.fn.stdpath 'data' .. '/lsp-servers/lua-language-server/lua-language-server',
    vim.fn.stdpath 'data' .. '/lsp-servers/lua-language-server/lua-language-server.exe',
  }
  local lua_ls_fallback
  for _, path in ipairs(lua_ls_fallbacks) do
    if vim.fn.filereadable(path) == 1 then
      lua_ls_fallback = path
      break
    end
  end

  if vim.fn.executable 'lua-language-server' == 1 then
    vim.health.ok("Found lua-language-server in PATH")
  elseif lua_ls_fallback then
    vim.health.ok('Found lua-language-server at fallback path: ' .. lua_ls_fallback)
  else
    vim.health.warn("lua-language-server not detected (PATH or fallback path)")
  end

  local clipboard = vim.opt.clipboard:get()
  local has_unnamedplus = false
  if type(clipboard) == 'table' then
    has_unnamedplus = vim.tbl_contains(clipboard, 'unnamedplus')
  else
    has_unnamedplus = tostring(clipboard):find('unnamedplus', 1, true) ~= nil
  end

  if has_unnamedplus then
    local clipboard_tools
    if vim.fn.has 'win32' == 1 then
      clipboard_tools = { 'win32yank', 'clip', 'powershell', 'pwsh' }
    elseif vim.fn.has 'mac' == 1 then
      clipboard_tools = { 'pbcopy', 'pbpaste' }
    else
      clipboard_tools = { 'wl-copy', 'wl-paste', 'xclip', 'xsel' }
    end

    local has_provider = false
    for _, exe in ipairs(clipboard_tools) do
      if vim.fn.executable(exe) == 1 then
        has_provider = true
        vim.health.ok(string.format("Clipboard provider candidate found: '%s'", exe))
        break
      end
    end

    if not has_provider then
      vim.health.warn("'clipboard' includes 'unnamedplus' but no known clipboard tool/provider was detected")
    end
  end

  return true
end

local value_to_string = function(value)
  if type(value) == 'table' then
    return vim.inspect(value)
  end
  return tostring(value)
end

local option_matches = function(name, expected)
  local actual = vim.opt[name]:get()

  if type(expected) == 'table' then
    if type(actual) ~= 'table' then
      return false, actual
    end

    if vim.islist(expected) then
      return vim.deep_equal(actual, expected), actual
    end

    for key, expected_value in pairs(expected) do
      if actual[key] ~= expected_value then
        return false, actual
      end
    end
    return true, actual
  end

  if type(actual) == 'table' and vim.islist(actual) then
    return table.concat(actual, ',') == expected, actual
  end

  if type(actual) == 'table' and type(expected) == 'string' then
    -- Some flag options (e.g. 'mouse') are returned as map-like tables.
    return actual[expected] == true, actual
  end

  return actual == expected, actual
end

local check_config_options = function()
  local expected_options = {
    number = true,
    termguicolors = true,
    mouse = 'a',
    showmode = false,
    clipboard = 'unnamedplus',
    breakindent = true,
    undofile = true,
    ignorecase = true,
    smartcase = true,
    signcolumn = 'yes',
    updatetime = 250,
    timeoutlen = 300,
    splitright = true,
    splitbelow = true,
    list = true,
    listchars = { tab = '» ', trail = '·', nbsp = '␣' },
    inccommand = 'split',
    cursorline = true,
    scrolloff = 10,
    shell = 'nu',
    shellcmdflag = '--login --stdin --no-newline -c',
    shellredir = 'out+err> %s',
    shellquote = '',
    shellxquote = '',
    shellxescape = '',
    shelltemp = false,
    shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record",
    hlsearch = true,
  }

  for name, expected in pairs(expected_options) do
    local matches, actual = option_matches(name, expected)
    if matches then
      vim.health.ok(string.format("Option '%s' is configured as expected", name))
    else
      vim.health.warn(string.format("Option '%s' expected %s but got %s", name, value_to_string(expected), value_to_string(actual)))
    end
  end

  local expected_globals = {
    mapleader = ' ',
    maplocalleader = ' ',
    have_nerd_font = true,
  }

  for name, expected in pairs(expected_globals) do
    local actual = vim.g[name]
    if actual == expected then
      vim.health.ok(string.format("Global 'g:%s' is configured as expected", name))
    else
      vim.health.warn(string.format("Global 'g:%s' expected %s but got %s", name, value_to_string(expected), value_to_string(actual)))
    end
  end
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_config_options()
  end,
}
