
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# bun completions
[ -s "/Users/christopheprakash/.bun/_bun" ] && source "/Users/christopheprakash/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
alias b="bun"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# postgresql
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Claude Code
PATH="$HOME/.local/bin:$PATH"

# git

alias main="git checkout main"
# alias hist="git --no-pager log --decorate=short --pretty=oneline --topo-order -n25"
alias hist="git --no-pager  log -n25 --reverse --decorate=short --color --date=format-local:'%I:%M%p %y/%m/%d' --pretty=format:'%C(yellow)%h %C(reset)%cd %C(green)%ae %C(auto)%d%C(reset) %s' "

alias stow="git add -A && git commit --no-verify -m 'Roll this back'"
alias unstow="git reset HEAD^"

alias stash="git stash --include-untracked"
alias unstash="git stash pop"

function push() {
    local currentBranch=$(git branch --show-current);
    git push origin $currentBranch $@;
}

function push-force() {
    local currentBranch=$(git branch --show-current);
    
    # Won't overwrite if other users have pushed since last pull
    git push --force-with-lease origin $currentBranch $@;
}

function pull() {
    git fetch origin;
    git pull origin $(git branch --show-current);
}

function pull-force() {
    local currentBranch=$(git branch --show-current);
    local backupBranch="backup/$currentBranch/$(date +'%Y-%m-%d@%H:%M:%S')";
    local remoteBranch="origin/$currentBranch";
    
    echo "Saving copy of local branch $currentBranch to $backupBranch";
    git checkout -b $backupBranch;
    git switch $currentBranch;

    echo "Overwriting local branch $currentBranch with $remoteBranch";
    git reset --hard $remoteBranch;
}

function branch() {
    if [ $# -eq 0 ];
    then
        git branch --sort=committerdate \
            --format='%(HEAD) %(color:yellow)%(align:15,left)%(committerdate:relative)%(end)%(color:reset) %(color:green)%(align:25,left)%(refname:short)%(end)%(color:reset) %(color:red)%(upstream:track)%(color:reset)';
    elif [ $# -eq 1 ];
    then
        git switch $1 || git switch -c $1;
    else
        git branch "$@";
    fi
}

function rebase() {
    local baseBranch=${1:-main};
    git rebase $baseBranch;
} 



# utilities
alias reload="source ~/.zshrc"
alias profile="code ~/.zshrc"
alias zshrc="code ~/.zshrc"

alias IncreaseKeyboardSpeed='defaults write -g InitialKeyRepeat -int 10;defaults write -g KeyRepeat -int 1'

function killport() {
    lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill -9
}

function whichport() {
    lsof -i -P | grep LISTEN | grep $1
}

# config auto-sync
# ~/.zshrc is a symlink into this config repo; resolve it to find the repo.
_zshrc_repo=${${:-$HOME/.zshrc}:A:h}

if [[ -d "$_zshrc_repo/.git" ]]; then
    zmodload -F zsh/stat b:zstat
    zmodload zsh/datetime

    # Commits & pushes local .zshrc changes immediately; otherwise pulls at
    # most once per hour. Runs disowned in the background so it never blocks.
    function _zshrc_sync() {
        local dirty=""
        [[ -n $(git -C "$_zshrc_repo" status --porcelain -- .zshrc 2>/dev/null) ]] && dirty=1

        if [[ -z $dirty ]]; then
            local -a stamp
            if zstat -A stamp +mtime "$_zshrc_repo/.git/zshrc-sync-stamp" 2>/dev/null \
                && (( EPOCHSECONDS - stamp[1] < 3600 )); then
                return 0
            fi
        fi

        (
            cd "$_zshrc_repo" || exit

            # One sync at a time across all shells; clear locks left by a dead sync
            if ! mkdir .git/zshrc-sync.lock 2>/dev/null; then
                local -a lock
                zstat -A lock +mtime .git/zshrc-sync.lock 2>/dev/null || exit
                (( EPOCHSECONDS - lock[1] > 600 )) || exit
                rmdir .git/zshrc-sync.lock 2>/dev/null && mkdir .git/zshrc-sync.lock 2>/dev/null || exit
            fi
            trap 'rmdir .git/zshrc-sync.lock 2>/dev/null' EXIT

            [[ -n $dirty ]] && git commit -q --no-verify -m "Auto-sync .zshrc from ${HOST%%.*}" -- .zshrc
            git pull --rebase --autostash -q origin main || git rebase --abort 2>/dev/null
            if (( $(git rev-list --count origin/main..main 2>/dev/null) )); then
                git push -q origin main
            fi
            touch .git/zshrc-sync-stamp
        ) &>/dev/null &!
    }

    # Detect saves to .zshrc while shells are open (checked before each prompt)
    function _zshrc_watch() {
        local -a m
        zstat -A m +mtime "$_zshrc_repo/.zshrc" 2>/dev/null || return 0
        if [[ -n $_zshrc_last_mtime && $m[1] != $_zshrc_last_mtime ]]; then
            _zshrc_last_mtime=$m[1]
            _zshrc_sync
        fi
        _zshrc_last_mtime=$m[1]
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _zshrc_watch

    _zshrc_sync
fi
