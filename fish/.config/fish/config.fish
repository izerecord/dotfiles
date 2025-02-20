source ~/.config/fish/alias.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
fzf --fish | source

# fzf specifics
# prerequisits: plugin `patrickf1/fzf.fish`
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\ce --processes=\cp
set fzf_fd_opts --hidden --max-depth 5 --ignore
