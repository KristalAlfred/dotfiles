return {
  "nvim-mini/mini.map",
  version = false,
  event = "VeryLazy",
  config = function()
    local minimap = require("mini.map")
    local block_symbols = minimap.gen_encode_symbols.dot("4x2")

    -- Define the highlight group for Git diff changes.
    vim.cmd([[highlight default MiniMapGitDiff guifg=#ff8800 guibg=NONE]])

    minimap.setup({
      symbols = {
        encode = block_symbols,
        scroll_line = "█",
        scroll_view = "▒",
      },
      window = {
        show = true,
        focusable = false,
        width = 15,
        side = "right",
        show_integration = true,
      },
      -- Use the Git diff integration.
      integrations = {
        minimap.gen_integration.diff(),
      },
    })

    minimap.open(nil)

    vim.keymap.set("n", "<leader>mm", minimap.toggle, { desc = "Toggle minimap" })
    vim.keymap.set("n", "<leader>mo", minimap.open, { desc = "Open minimap" })
    vim.keymap.set("n", "<leader>mc", minimap.close, { desc = "Close minimap" })
    vim.keymap.set("n", "<leader>mf", minimap.toggle_focus, { desc = "Toggle minimap focus" })
    vim.keymap.set("n", "<leader>mr", minimap.refresh, { desc = "Refresh minimap" })

    local has_clue, mini_clue = pcall(require, "mini.clue")
    if has_clue then
      mini_clue.config.clues.merge({
        { mode = "n", keys = "<Leader>m", desc = "+Minimap" },
      })
    end
  end,
}
