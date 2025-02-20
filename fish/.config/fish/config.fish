source ~/.config/fish/alias.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# TODO: status is-interactive || exit

starship init fish | source
fzf --fish | source

# fzf specifics
# prerequisits: plugin `patrickf1/fzf.fish`
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\ce --processes=\cp
set fzf_fd_opts --hidden --max-depth 5 --ignore
set fzf_preview_dir_cmd lsd --tree --all --color=always --icon=always
# set fzf_preview_file_cmd
# set fzf_git_log_format 
