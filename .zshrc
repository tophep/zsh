
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# bun completions
[ -s "/Users/christopheprakash/.bun/_bun" ] && source "/Users/christopheprakash/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# postgresql
export PATH="/Applications/Postgres.app/Contents/Versions/16/bin:$PATH"

# git
alias pull="git pull origin $(git branch --show-current)"
alias main="git checkout main"

function branch() {
    git switch $1 || git switch -c $1;
} 
function rebase() {
    local baseBranch=${1:-main};
    git rebase $baseBranch;
} 
alias rebase:abort="git rebase --abort"
alias rebase:continue="git rebase --continue"
alias stash="git add -A && git commit --no-verify -m 'Roll this back'"
alias unstash="git reset HEAD^"
alias push="git push origin $(git branch --show-current)"

# utilities
alias IncreaseKeyboardSpeed='defaults write -g InitialKeyRepeat -int 10;defaults write -g KeyRepeat -int 1'

function killport() {
    lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill -9
}

function whichport() {
    lsof -i -P | grep LISTEN | grep $1
}
