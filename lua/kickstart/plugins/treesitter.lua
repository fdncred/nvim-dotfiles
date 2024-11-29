return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'nu', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      -- OPTIONAL!! These enable ts-specific textobjects.
      -- So you can hit `yaf` to copy the closest function,
      -- `dif` to clear the contet of the closest function,
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
    },
    --config = function(_, opts)
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    -- Prefer git instead of curl in order to improve connectivity in some environments
    --require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    --require('nvim-treesitter.configs').setup(opts)

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    --end,
    config = function(_, opts)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.nu = {
        install_info = {
          url = '~/src/tree-sitter-nu', -- local path or git repo
          files = { 'src/parser.c', 'src/scanner.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
          branch = 'main', -- default branch in case of git repo if different from master
          generate_requires_npm = false, -- if stand-alone parser without npm dependencies
          requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
        },
        filetype = 'nu', -- if filetype does not match the parser name
      }
      require('nvim-treesitter.configs').setup(opts)
    end,
    dependencies = { 'nushell/tree-sitter-nu' },
  },
}
-- vim: ts=2 sts=2 sw=2 et
