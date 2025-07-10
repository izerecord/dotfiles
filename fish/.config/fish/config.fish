source ~/.config/fish/alias.fish

#
# add .local/bin to path
#
mkdir -p ~/.local/bin
set -U fish_user_paths $fish_user_paths ~/.local/bin

#
# theme
#
# some hacky test. I dont know. I am not happy
# if not string match -q -- "$fish_color_normal" "cdd6f4"
#     fish_config theme save "Catppuccin Mocha"
# end

#
# completions
#
task --completion fish | source
flux completion fish | source

# only works on v0.25.0
# https://github.com/sharkdp/bat/blob/master/CHANGELOG.md
# bat --completion fish | source

status is-interactive || exit

###########################
# starship
###########################
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
set -x fzf_fd_opts --hidden --ignore
# preview directories with `lsd --tree`
set -x fzf_preview_dir_cmd lsd --tree --all --color=always --icon=always

# fzf catpucchin and 40% height
set -x FZF_DEFAULT_OPTS "\
   --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
   --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
   --color=selected-bg:#45475A \
   --color=border:#313244,label:#CDD6F4 \
   --height 40% --tmux bottom,80%,40% --layout reverse --border top"

# set fzf_preview_file_cmd
# set fzf_git_log_format
