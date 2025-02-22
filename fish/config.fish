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
if not string match -q -- "$fish_color_normal" "cdd6f4"
    fish_config theme save "Catppuccin Mocha"
end

#
# completions
#
task --completion fish | source
flux completion fish | source
bat --completion fish | source


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
set -x fzf_fd_opts --hidden --max-depth 5 --ignore
# preview directories with `lsd --tree`
set -x fzf_preview_dir_cmd lsd --tree --all --color=always --icon=always

# fzf catpucchin and 50% height
set -x FZF_DEFAULT_OPTS "\
   --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
   --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
   --color=selected-bg:#45475a \
   --height 40% --tmux bottom,80%,40% --layout reverse --border top"
# set fzf_preview_file_cmd
# set fzf_git_log_format 

