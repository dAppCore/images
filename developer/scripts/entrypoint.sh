#!/bin/sh
# Core Developer - Entrypoint Script

set -e


# Run pre-start hooks if they exist
if [ -d "$HOME/.config/core-dev/hooks/pre-start" ]; then
    for hook in $HOME/.config/core-dev/hooks/pre-start/*; do
        [ -x "$hook" ] && "$hook"
    done
fi

# Setup git config if not already set
if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi
fi

if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    if [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
    fi
fi

# Setup SSH agent if keys exist
if [ -d "$HOME/.ssh" ] && [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    for key in $HOME/.ssh/id_* ; do
        [ -f "$key" ] && [ ! -f "$key.pub" ] || ssh-add "$key" 2>/dev/null || true
    done
fi

# Run post-start hooks if they exist
if [ -d "$HOME/.config/core-dev/hooks/post-start" ]; then
    for hook in $HOME/.config/core-dev/hooks/post-start/*; do
        [ -x "$hook" ] && "$hook"
    done
fi

# Symlink Claude config if mounted inside .claude dir
[ -f "$HOME/.claude/.claude.json" ] && [ ! -f "$HOME/.claude.json" ] && \
    ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"


# Clone spec docs from Forge if FORGE_TOKEN is set and repo/docs exists
#SPECS_DIR="$HOME/specs"
#mkdir -p "$SPECS_DIR"
#git clone --depth 1 --single-branch -b main "https://virgil:375068d101922dd1cf269e8b8cb77a0f99d1b486@forge.lthn.ai/core/plans.git" "$SPECS_DIR"
#cd "$SPECS_DIR" && git remote remove origin && cd -

# Execute command
exec "$@"
