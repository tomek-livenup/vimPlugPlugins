local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://www.npmjs.com/package/graphql-language-service-cli",
        languages = { "graphql" },
        installer = npm.packages { "graphql-language-service-cli", "graphql" },
        default_options = {
            cmd_env = npm.env(root_dir),
        },
    }
end
