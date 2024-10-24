#!/usr/bin/env fish
# not needed for now, because the workaround of 
# https://github.com/microsoft/vscode-remote-release/issues/2509#issuecomment-1640162892
if test (hostname) = casdev
    # pipx
    set PATH $PATH $HOME/.local/bin
    # proxy
    if test -z "$http_proxy"
        exec bash -c "source /data/scripts/set_proxy.sh >/dev/null 2>&1; exec fish"
        clear
    end
end
