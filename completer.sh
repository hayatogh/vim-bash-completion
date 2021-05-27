#!/usr/bin/env bash
# Original author : Brian Beffa <brbsix@gmail.com>
# Original version: https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
#                   https://github.com/rantasub/vim-bash-completion

if [[ $# == 1 ]]; then
	# Complete command
	printf '%s\n' $(compgen -acdf $1)
	exit 0
fi

# Load bash-completion
. "${BASH_COMPLETION_DIR:-/usr/share/bash-completion}/bash_completion"

COMP_LINE=$*
COMP_POINT=${#COMP_LINE}
COMP_WORDS=("$@")
COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
word_preceding=''
if [[ ${#COMP_WORDS[@]} -gt 1 ]]; then
	word_preceding=${COMP_WORDS[-2]}
fi

complete_func=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')
if [[ -z ${complete_func} ]]; then
	# Load on-demand and check again
	_completion_loader "$1"
	complete_func=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')
fi
if [[ -z ${complete_func} ]]; then
	# Exit when not found
	exit 1
fi

"${complete_func}" "${COMP_WORDS[0]}" "${COMP_WORDS[-1]}" "${word_preceding}" 2>/dev/null
printf '%s\n' "${COMPREPLY[@]}"
