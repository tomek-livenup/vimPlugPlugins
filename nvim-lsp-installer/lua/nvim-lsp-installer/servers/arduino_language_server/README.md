# arduino_language_server

## Necessary extra configuration

The Arduino Language Server does not come fully bootstrapped out of the box. In order for the language server to
successfully start, you need to provide which [FQBN](#FQBN) (e.g. "arduino:avr:nano") it should start with.

This is done during server initialization, and can be done by utilizing lspconfig's `on_new_config` hook:

```lua
local lsp_installer = require("nvim-lsp-installer")

lsp_installer.on_server_ready(function (server)
    local opts = {}
    if server.name == "arduino_language_server" then
        opts.on_new_config = function (config, root_dir)
            local partial_cmd = server:get_default_options().cmd
            local MY_FQBN = "arduino:avr:nano"
            config.cmd = vim.list_extend(partial_cmd, { "-fqbn", MY_FQBN })
        end
    end
    server:setup(opts)
end)
```

### Dynamically changing FQBN per project

```lua
local lsp_installer = require("nvim-lsp-installer")

-- When the arduino server starts in these directories, use the provided FQBN.
-- Note that the server needs to start exactly in these directories.
-- This example would require some extra modification to support applying the FQBN on subdirectories!
local my_arduino_fqbn = {
    ["/home/h4ck3r/dev/arduino/blink"] = "arduino:avr:nano",
    ["/home/h4ck3r/dev/arduino/sensor"] = "arduino:mbed:nanorp2040connect",
}

local DEFAULT_FQBN = "arduino:avr:uno"

lsp_installer.on_server_ready(function (server)
    local opts = {}
    if server.name == "arduino_language_server" then
        opts.on_new_config = function (config, root_dir)
            local partial_cmd = server:get_default_options().cmd
            local fqbn = my_arduino_fqbn[root_dir]
            if not fqbn then
                vim.notify(("Could not find which FQBN to use in %q. Defaulting to %q."):format(root_dir, DEFAULT_FQBN))
                fqbn = DEFAULT_FQBN
            end
            config.cmd = vim.list_extend(partial_cmd, { "-fqbn", fqbn })
        end
    end
    server:setup(opts)
end)
```

## FQBN

A FQBN, fully qualified board name, is used to distinguish between the various supported boards. Its format is defined
as `<package>:<architecture>:<board>`, where

-   `<package>` - vendor identifier; typically just `arduino` for Arduino boards
-   `<architecture>` - microcontroller architecture; e.g., `avr`, `megaavr`, `sam`, etc.
-   `<board>` - board name defined by the software; e.g., `uno`, `uno2018`, `yun`, etc.

To identify the available FQBNs for boards you currently have connected, you may use the `arduino-cli` command, like so:

```sh
$ arduino-cli board list
Port         Protocol Type              Board Name  FQBN            Core
/dev/ttyACM0 serial   Serial Port (USB) Arduino Uno arduino:avr:uno arduino:avr
                                                    ^^^^^^^^^^^^^^^
```
