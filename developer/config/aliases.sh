# Core Developer - Shell Aliases

# ============================================================
# Navigation
# ============================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ============================================================
# File Listing (eza)
# ============================================================
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -la --icons'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=3 --icons -a'

# ============================================================
# Modern CLI Replacements
# ============================================================
alias cat='bat'
alias find='fd'
alias grep='rg'
alias top='btop'
alias diff='delta'
alias vim='nvim'
alias vi='nvim'

# ============================================================
# Git
# ============================================================
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline -20'
alias glo='git log --oneline --graph --all'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gf='git fetch'
alias gm='git merge'
alias gr='git rebase'
alias gst='git stash'
alias lg='lazygit'

# ============================================================
# Docker
# ============================================================
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias drm='docker rm'
alias drmi='docker rmi'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias ld='lazydocker'

# ============================================================
# Kubernetes
# ============================================================
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deployment'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# ============================================================
# PHP / Laravel
# ============================================================
alias art='php artisan'
alias sail='./vendor/bin/sail'
alias pest='./vendor/bin/pest'
alias pint='./vendor/bin/pint'
alias phpunit='./vendor/bin/phpunit'
alias stan='./vendor/bin/phpstan'
alias tinker='php artisan tinker'

# ============================================================
# Node.js
# ============================================================
alias nr='npm run'
alias ni='npm install'
alias nid='npm install -D'
alias nu='npm update'
alias nci='npm ci'
alias pn='pnpm'
alias pnr='pnpm run'
alias pni='pnpm install'
alias bn='bun'
alias bnr='bun run'
alias bni='bun install'

# ============================================================
# Python
# ============================================================
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source .venv/bin/activate'

# ============================================================
# Go
# ============================================================
alias gob='go build'
alias gor='go run'
alias got='go test'
alias gotv='go test -v'
alias gomt='go mod tidy'
alias gof='go fmt ./...'
alias gol='golangci-lint run'

# ============================================================
# Rust
# ============================================================
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cc='cargo check'
alias cf='cargo fmt'
alias cl='cargo clippy'

# ============================================================
# Core CLI
# ============================================================
alias core='core'
alias cdev='core dev'
alias cbuild='core build'
alias crun='core run'
alias crelease='core release'
alias cphp='core php'

# ============================================================
# Data Processing
# ============================================================
alias json='jq'
alias yaml='yq'
alias csv='mlr --csv'

# ============================================================
# Security
# ============================================================
alias encrypt='age -e'
alias decrypt='age -d'
alias scan='trivy fs .'
alias secrets='trufflehog filesystem .'

# ============================================================
# FZF Integrations
# ============================================================
alias fzp='fzf --preview "bat --color=always {}"'
alias fzg='fzf --preview "git diff {} | delta"'

# ============================================================
# Misc
# ============================================================
alias h='history'
alias cl='clear'
alias q='exit'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias week='date +%V'
alias myip='curl -s ifconfig.me'
alias ports='ss -tuln'
alias serve='python3 -m http.server'
alias weather='curl -s wttr.in'
