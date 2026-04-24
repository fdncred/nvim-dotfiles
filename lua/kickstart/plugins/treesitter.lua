return {
  {
      "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
      config = function()
          local uv = vim.uv or vim.loop
          local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")

          local function parser_lib_extension()
              if vim.fn.has "win32" == 1 then
                  return "dll"
              end
              if vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1 then
                  return "dylib"
              end
              return "so"
          end

          local function nu_candidate_paths()
              local ext = parser_lib_extension()
              local candidates = {}

              local function add(path)
                  if path and path ~= "" then
                      table.insert(candidates, vim.fn.expand(path))
                  end
              end

              -- User override path, works on all operating systems.
              add(vim.env.NU_TREE_SITTER_PARSER)

              -- Common parser install locations.
              add(vim.fs.joinpath(vim.fn.stdpath "data", "tree-sitter", "lib", "nu." .. ext))
              add(vim.fs.joinpath(vim.fn.stdpath "data", "site", "parser", "nu." .. ext))

              -- Legacy/custom paths used in some setups.
              if vim.fn.has "win32" == 1 then
                  add((vim.env.LOCALAPPDATA or "") .. "/tree-sitter/lib/nu.dll")
              end
              if vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1 then
                  add((vim.env.HOME or "") .. "/src/tree-sitter-nu/nu.dylib")
              end

              return candidates
          end

          local function try_register_nu_parser()
              if not (vim.treesitter and vim.treesitter.language and vim.treesitter.language.add) then
                  return false
              end

              for _, path in ipairs(nu_candidate_paths()) do
                  if uv.fs_stat(path) then
                      local ok = pcall(vim.treesitter.language.add, "nu", { path = path })
                      if ok then
                          return true
                      end
                  end
              end

              -- Fall back to default runtime parser discovery.
              return pcall(vim.treesitter.language.add, "nu")
          end

          local nu_registered = try_register_nu_parser()
          local nu_parser_ready = false

          if ok_parsers and parsers.has_parser "nu" then
              -- Smoke test parser creation without depending on current buffer/filetype state.
              nu_parser_ready = pcall(vim.treesitter.get_string_parser, "", "nu")
          end

          if not nu_parser_ready and not nu_registered then
              vim.notify(
                  "Nu Treesitter parser is unavailable. Set NU_TREE_SITTER_PARSER to your parser file path if needed.",
                  vim.log.levels.WARN
              )
          end

          local function nu_highlight_query_ok()
              if not nu_parser_ready then
                  return false
              end
              return pcall(vim.treesitter.query.get, "nu", "highlights")
          end

          require("nvim-treesitter.configs").setup {
              ensure_installed = { "nu" }, -- Ensure the "nu" parser is installed
              highlight = {
                  enable = true,            -- Enable syntax highlighting
                  -- Prevent startup crashes when parser creation fails or if the Nushell highlight query is invalid.
                  disable = function(lang)
                      if lang == "nu" then
                          return not nu_highlight_query_ok()
                      end
                      return false
                  end,
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
