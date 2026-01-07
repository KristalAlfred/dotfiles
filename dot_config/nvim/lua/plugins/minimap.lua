return {
  "nvim-mini/mini.map",
  version = "false",
  event = "VeryLazy",
  config = function()
    local minimap = require("mini.map")
    local block_symbols = minimap.gen_encode_symbols.dot("4x2")

    -- Integration function that uses Git diff to highlight changed lines.
    local function get_git_diff_lines()
      local bufnr = vim.api.nvim_get_current_buf()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename == "" then
        return {}
      end

      -- Ensure the file is in a Git repo.
      local git_toplevel = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
      git_toplevel = git_toplevel:gsub("%s+", "")
      if git_toplevel == "" then
        return {}
      end

      local diff_cmd = "git diff --unified=0 " .. vim.fn.shellescape(filename)
      local diff_output = vim.fn.systemlist(diff_cmd)
      if not diff_output or #diff_output == 0 then
        return {}
      end

      local edited = {}
      for _, line in ipairs(diff_output) do
        -- Match hunk headers in the diff output.
        local new_start, new_count = line:match("^@@ %-%d+,?%d* %+([0-9]+),?([0-9]*) @@")
        if new_start then
          local start_num = tonumber(new_start)
          local count = tonumber(new_count) or 1
          for i = 0, count - 1 do
            table.insert(edited, { line = start_num + i, hl_group = "MiniMapGitDiff" })
          end
        end
      end
      return edited
    end

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
        get_git_diff_lines,
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
