# apps... but better
# alias git=hub
alias vim=nvim
alias ls=lsd

# cat bat catbat madness
if test -f /etc/os-release
    set ID (grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

    switch $ID
        case debian ubuntu
            alias cat="batcat"
            alias bat="batcat"
        case arch
            alias cat="bat"
            alias batcat="bat"
            alias task="go-task"
    end
end


# git
abbr -a gs git status -sb
abbr -a gst git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gcm git commit -m
abbr -a gca git commit --amend
# abbr -a gcl git clone
# abbr -a gco git checkout
abbr -a gp git push
abbr -a gpl git pull
abbr -a gl git log
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gr git rebase -i HEAD~15
abbr -a gf git fetch
# abbr -a gfc git findcommit
# abbr -a gfm git findmessage

abbr -a lg lazygit 

# yadm
# abbr -a ys yadm status -s -b
# abbr -a ya yadm add
# abbr -a yc yadm commit
# abbr -a ycm yadm commit -m
# abbr -a yp yadm push
# abbr -a yl yadm l
# abbr -a yd yadm diff
# abbr -a yds yadm diff --staged

# ls
alias l='ls'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# misc
alias reload='exec fish'
