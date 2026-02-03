local function is_following()
  local ok, wheelchair = pcall(require, "wheelchair")
  return ok and wheelchair.state.follow_mode
end

local function is_paused()
  local ok, wheelchair = pcall(require, "wheelchair")
  return ok and wheelchair.state.paused
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_c, 1, {
      function()
        return "⏸ Paused"
      end,
      color = { bg = "#f09030", fg = "#1a1a1a", gui = "bold" },
      separator = { left = "", right = "" },
      padding = { left = 1, right = 1 },
      cond = is_paused,
    })

    table.insert(opts.sections.lualine_c, 1, {
      function()
        return "♿ Following ♿"
      end,
      color = { bg = "#0818ab", fg = "#eeeeee", gui = "bold" },
      separator = { left = "", right = "" },
      padding = { left = 1, right = 1 },
      cond = is_following,
    })
  end,
}
