
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
export PATH="/Applications/Postgres.app/Contents/Versions/16/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

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
    if [ $# -eq 1 ]; 
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

alias IncreaseKeyboardSpeed='defaults write -g InitialKeyRepeat -int 10;defaults write -g KeyRepeat -int 1'

function killport() {
    lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill -9
}

function whichport() {
    lsof -i -P | grep LISTEN | grep $1
}
