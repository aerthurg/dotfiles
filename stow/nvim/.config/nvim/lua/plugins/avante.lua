return {
  {
    "yetone/avante.nvim",
    build = "make BUILD_FROM_SOURCE=true",
    opts = {
      provider = "deepseek",
      providers = {
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-chat",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        hints = { enabled = false },
        web_search = false,
        enable_fastapply = false,
      },
    },
  },
}
