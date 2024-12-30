VERSION = "0.0.1"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local shell = import("micro/shell")
local strings = import("strings")

function toggleMouse(_pane, _args)
    local ruler = config.GetGlobalOption("ruler")
    if ruler then
        config.SetGlobalOption("ruler", "false")
        config.SetGlobalOption("mouse", "false")
        micro.InfoBar():Message("Disabled ruler & mouse")
    else
        config.SetGlobalOption("ruler", "true")
        config.SetGlobalOption("mouse", "true")
        micro.InfoBar():Message("Enabled ruler & mouse")
    end
end

function complete(_pane, _args)
    local v = micro.CurPane()

    if v.Cursor == nil then
        return
    end

    local line = v.Buf:Line(v.Cursor.Loc.Y)
    local s1 = string.sub(line, 1, v.Cursor.Loc.X)
    local m1 = string.match(s1, "[A-Za-z0-9_]*$")

    _runComplete(m1, v.Buf.Path, {v, buffer.Loc(v.Cursor.X, v.Cursor.Y)})
end

function _runComplete(prefix, filename, runargs)
    local bp = runargs[1]
    local prefixCommand = ""
    if prefix ~= "" then
         prefixCommand = "--prefix " .. prefix
    end
    local command = "bash -l -c 'generate_completion " .. prefixCommand .. " " .. filename .. " | fzf'"

    if shell.TermEmuSupported then
        local err = shell.RunTermEmulator(bp, command, false, true, _completeOutput, runargs)
        if err ~= nil then
            micro.InfoBar():Error(err)
        end
    else
        local output, err = shell.RunInteractiveShell(command, false, true)
        if err ~= nil then
            micro.InfoBar():Error(err)
        else
            _completeOutput(output, runargs)
        end
    end
end

function _completeOutput(output, runargs)
    local bp = runargs[1]
    local loc = runargs[2]

    output = strings.TrimSpace(output)
    if output ~= "" then
        bp.Buf:Replace(loc, loc, output)
    end
end
