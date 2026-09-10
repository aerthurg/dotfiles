return {
    {
        "stevearc/overseer.nvim",
        opts = function(_, opts)
            local overseer = require("overseer")

            overseer.register_template({
                name = "rails server",
                generator = function(search, callback)
                    local cwd = search.dir or vim.fn.getcwd()
                    local has_gemfile = vim.fn.filereadable(cwd .. "/Gemfile") == 1
                    local has_app_dir = vim.fn.isdirectory(cwd .. "/app") == 1

                    if not (has_gemfile and has_app_dir) then
                        callback({})
                        return
                    end

                    callback({
                        {
                            name = "rails server",
                            builder = function()
                                return {
                                    cmd = { "bin/rails" },
                                    args = { "server" },
                                    components = { "default", "on_output_quickfix" },
                                }
                            end,
                        },
                    })
                end,
            })
        end,
    },
}
