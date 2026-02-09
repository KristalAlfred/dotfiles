return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Remove the buffer source entirely
      -- This is to remove words in the buffer from auto-complete suggestions.
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "buffer"
      end, opts.sources or {})
    end,
  },
}
