# Core-dev shell aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='eza -la --icons --git'
alias la='eza -la --icons'
alias lt='eza --tree --level=2 --icons'

# Git
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias ld='lazydocker'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'

# PHP/Laravel
alias art='php artisan'
alias sail='./vendor/bin/sail'
alias pest='./vendor/bin/pest'
alias pint='./vendor/bin/pint'

# Core
alias c='core'
alias cdev='core dev'
alias cbuild='core build'
alias crun='core run'

# Misc
alias cat='bat'
alias find='fd'
alias grep='rg'
alias top='btop'
alias vim='nvim'
alias vi='nvim'

# FZF integrations
alias fzp='fzf --preview "bat --color=always {}"'
