#!/usr/bin/env fish
if test (hostname) = casdev
    # pipx
    set PATH $PATH $HOME/.local/bin
    # go
    set PATH $PATH $HOME/go/bin
    set -Ux PATH $GOPATH/bin $PATH
    # proxy
    if test -z "$http_proxy"
        exec bash -c "source /data/scripts/set_proxy.sh >/dev/null 2>&1; exec fish"
        clear
    end
    # pnpm
    set PATH $PATH $HOME/.local/share/pnpm/bin
    # nvim
    set PATH $PATH /opt/nvim-linux-x86_64/bin
    # env
    set -x TASK_X_REMOTE_TASKFILES 1
end
