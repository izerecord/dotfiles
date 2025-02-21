source ~/.config/fish/alias.fish

status is-interactive || exit

###########################
# starship
# #########################
starship init fish | source
set -x STARSHIP_CONFIG ~/.config/starship/starship.toml

###############################################################################
# fzf specifics
# prerequisits: plugin `patrickf1/fzf.fish`
###############################################################################
fzf --fish | source
fzf_configure_bindings \
    --directory=\cf \
    --git_log=\cg \
    --git_status=\cs \
    --history=\cr \
    --variables=\ce \
    --processes=\cp
# search directory
set fzf_fd_opts --hidden --max-depth 5 --ignore
# preview directories with `lsd --tree`
set fzf_preview_dir_cmd lsd --tree --all --color=always --icon=always

# fzf catpucchin and 50% height
set -Ux FZF_DEFAULT_OPTS "\
   --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
   --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
   --color=selected-bg:#45475a \
   --height 40% --tmux bottom,80%,40% --layout reverse --border top"
# set fzf_preview_file_cmd
# set fzf_git_log_format 
