return {
  {
      "nvim-treesitter/nvim-treesitter",
      config = function()
          local uv = vim.uv or vim.loop
          if vim.fn.has "win32" == 1 and vim.treesitter.language and vim.treesitter.language.add then
              local custom_nu_parser = vim.fn.expand "$LOCALAPPDATA" .. "/tree-sitter/lib/nu.dll"
              if uv.fs_stat(custom_nu_parser) then
                  local ok, err = vim.treesitter.language.add("nu", { path = custom_nu_parser })
                  if not ok and err then
                      vim.notify("Failed to load custom Nu parser: " .. err, vim.log.levels.WARN)
                  end
              end
          end

          require("nvim-treesitter.configs").setup {
              ensure_installed = { "nu" }, -- Ensure the "nu" parser is installed
              highlight = {
                  enable = true,            -- Enable syntax highlighting
              },
              -- OPTIONAL!! These enable ts-specific textobjects.
              -- So you can hit `yaf` to copy the closest function,
              -- `dif` to clear the content of the closest function,
              -- or whatever keys you map to what query.
              textobjects = {
                  select = {
                      enable = true,
                      keymaps = {
                          -- You can use the capture groups defined in textobjects.scm
                          -- For example:
                          -- Nushell only
                          ["aP"] = "@pipeline.outer",
                          ["iP"] = "@pipeline.inner",

                          -- supported in other languages as well
                          ["af"] = "@function.outer",
                          ["if"] = "@function.inner",
                          ["al"] = "@loop.outer",
                          ["il"] = "@loop.inner",
                          ["aC"] = "@conditional.outer",
                          ["iC"] = "@conditional.inner",
                          ["iS"] = "@statement.inner",
                          ["aS"] = "@statement.outer",
                      }, -- keymaps
                  }, -- select
              }, -- textobjects
          }
      end,
      dependencies = {
          -- Install official queries and filetype detection
          -- alternatively, see section "Install official queries only"
          { "nushell/tree-sitter-nu" },
      },
      build = ":TSUpdate",
  },
}
-- vim: ts=2 sts=2 sw=2 et
