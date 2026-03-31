#!/bin/sh
# Core Developer - Entrypoint Script

set -e


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


# Symlink Claude config if mounted inside .claude dir
[ -f "$HOME/.claude/.claude.json" ] && [ ! -f "$HOME/.claude.json" ] && \
    ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"

# Workspace must have repo/ — fail fast if mount is wrong
if [ ! -d "/workspace/repo" ]; then
    echo "ERROR: /workspace/repo not found — mount the full workspace, not just the repo" >&2
    exit 1
fi

# Execute command
exec "$@"
