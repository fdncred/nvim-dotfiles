return {
  'Bekaboo/dropbar.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = 'nvim-telescope/telescope-fzf-native.nvim',
  config = function()
    require('dropbar').setup()
  end,
}
