local server = require "nvim-lsp-installer.server"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"
local installers = require "nvim-lsp-installer.installers"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"
local Data = require "nvim-lsp-installer.data"
local path = require "nvim-lsp-installer.path"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://chipsalliance.github.io/verible/",
        languages = { "systemverilog", "verilog" },
        installer = {
            context.use_os_distribution(),
            context.capture(function(ctx)
                return context.use_github_release_file("chipsalliance/verible", function(version)
                    if ctx.os_distribution.id == "ubuntu" then
                        local target_file = when(
                            platform.arch == "x64",
                            coalesce(
                                when(
                                    ctx.os_distribution.version.major == 16,
                                    "verible-%s-Ubuntu-16.04-xenial-x86_64.tar.gz"
                                ),
                                when(
                                    ctx.os_distribution.version.major == 18,
                                    "verible-%s-Ubuntu-18.04-bionic-x86_64.tar.gz"
                                ),
                                when(
                                    ctx.os_distribution.version.major == 20,
                                    "verible-%s-Ubuntu-20.04-focal-x86_64.tar.gz"
                                ),
                                when(
                                    ctx.os_distribution.version.major == 22,
                                    "verible-%s-Ubuntu-22.04-jammy-x86_64.tar.gz"
                                )
                            )
                        )
                        return target_file and target_file:format(version)
                    else
                        local target_file = coalesce(
                            when(platform.is_win and platform.arch == "x64", "verible-%s-win64.zip")
                        )
                        return target_file and target_file:format(version)
                    end
                end)
            end),
            context.capture(function(ctx)
                return installers.pipe {
                    installers.when {
                        unix = std.untargz_remote(ctx.github_release_file),
                        win = std.unzip_remote(ctx.github_release_file),
                    },
                    std.rename(("verible-%s"):format(ctx.requested_server_version), "verible"),
                }
            end),
            context.receipt(function(receipt, ctx)
                receipt:with_primary_source(receipt.github_release_file(ctx))
            end),
        },
        default_options = {
            cmd_env = {
                PATH = process.extend_path {
                    path.concat(coalesce(
                        when(platform.is_win, { root_dir, "verible" }),
                        when(platform.is_unix, { root_dir, "verible", "bin" }),
                        { root_dir, "verible", "bin" } -- default
                    )),
                },
            },
        },
    }
end
