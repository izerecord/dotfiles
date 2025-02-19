source ~/.config/fish/alias.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
fzf --fish | source

# fzf
fzf_configure_bindings --directory=\cf --variables=\ce
set fzf_fd_opts --hidden --max-depth 5 --ignore
