#!/usr/bin/env bash

micro -plugin install fzf

echo "Ensure fzf and ag are installed, and the following line is in your shell config:"
echo "export FZF_DEFAULT_OPTS=\"--color=dark --no-scrollbar --pointer='> ' --marker='* ' --gutter=' '\""
