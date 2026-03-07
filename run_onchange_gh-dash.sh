#!/bin/bash
# Install gh-dash GitHub CLI extension
# Script hash: 1 (bump this number to re-run)

if ! command -v gh &> /dev/null; then
    echo "gh not found, skipping gh-dash setup"
    exit 0
fi

if gh extension list | grep -q "dlvhdr/gh-dash"; then
    echo "gh-dash extension already installed"
    exit 0
fi

gh extension install dlvhdr/gh-dash
echo "gh-dash extension installed"
