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

# Execute command
exec "$@"
