return {
  'Bekaboo/dropbar.nvim',
  version = '*',
  dependencies = 'nvim-telescope/telescope-fzf-native.nvim',
  config = function()
    require('dropbar').setup()
  end,
}
