return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
  },
  config = function()
    require('telescope').setup {
      pickers = {
          find_files = {
              theme = "ivy",
              follow = true,
              hidden = false
          }
      },
      extensions = {
          fzf = {}
      }
    }

    require('telescope').load_extension('fzf')

    vim.keymap.set("n", "<leader>fh", require('telescope.builtin').help_tags)
    vim.keymap.set("n", "<leader>fd", require('telescope.builtin').find_files)
    vim.keymap.set("n", "<leader>fg", require('telescope.builtin').live_grep)
    vim.keymap.set("n", "<leader>en", function()
        require('telescope.builtin').find_files {
            cwd = vim.fn.stdpath("config")
        }
    end)
  end
}
