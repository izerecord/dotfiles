# aliases
source ~/.config/fish/alias.fish
# theme
source ~/.config/fish/themes/kanagawa.fish
# mise
if type -q mise
    mise activate fish | source
    # mise activate fish --shims | source
end
# starship
if type -q starship
    starship init fish | source
end

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# krew
if type -q krew
    set -gx PATH $PATH $HOME/.krew/bin
end

# fzf

###############################################################################
# fzf specifics
# prerequisits: plugin `patrickf1/fzf.fish`
# https://github.com/PatrickF1/fzf.fish
###############################################################################
if type -q fzf
    fzf --fish | source
end

if type -q fzf_configure_bindings
    fzf_configure_bindings \
        --directory=\cf \
        --git_log=\cb \
        --git_status=\cg \
        --history=\cr \
        --variables=\ce \
        --processes=\cp
    # search directories
    set -x fzf_fd_opts --hidden --ignore
    set -x fzf_preview_dir_cmd eza --tree --all --color=always --icons=auto
    set fzf_preview_file_cmd bat --color=always --style=numbers
    #set fzf_git_log_format "%s"
    set fzf_diff_highlighter DFT_DISPLAY=inline DFT_COLOR=always git show --color=always --stat --patch --ext-diff {1}
end
#set -x FZF_DEFAULT_OPTS "\
#   --height 40% --tmux bottom,100%,40% --layout reverse --border top"
