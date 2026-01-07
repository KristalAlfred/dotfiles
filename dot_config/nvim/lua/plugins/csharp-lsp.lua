return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable omnisharp
        omnisharp = {
          enabled = false,
        },
        -- Enable roslyn (newer, better)
        csharp_language_server = {},
        -- OR use csharp_ls instead
        -- csharp_ls = {},
      },
    },
  },
}
