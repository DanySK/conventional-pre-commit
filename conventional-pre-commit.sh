#!/usr/bin/env bash

# list of Conventional Commits types
cc_types=("feat" "fix")
default_types=("build" "chore" "ci" "docs" "${cc_types[@]}" "perf" "refactor" "revert" "style" "test")
types=( "${cc_types[@]}" )

if [ $# -eq 1 ]; then
    types=( "${default_types[@]}" )
else
    # assume all args but the last are types
    while [ $# -gt 1 ]; do
        types+=( "$1" )
        shift
    done
fi

# the commit message file is the last remaining arg
msg_file="$1"

# join types with | to form regex ORs
r_types="($(IFS='|'; echo "${types[*]}"))"
# optional (scope)
r_scope="(\([[:alnum:] \/-]+\))?"
# optional breaking change indicator and colon delimiter
r_delim='!?:'
# subject line, body, footer
r_subject=" [[:alnum:]].+"
# the full regex pattern
pattern="^$r_types$r_scope$r_delim$r_subject$"

# Check if commit is conventional commit
if grep -Eq "$pattern" "$msg_file"; then
    exit 0
fi

echo "[Commit message] $( cat "$msg_file" )"
echo "
Your commit message does not follow Conventional Commits formatting
https://www.conventionalcommits.org/

Conventional Commits start with one of the below types:
    $(IFS=' '; echo "${types[*]}")
followed by an optional scope within parentheses,
followed by an exclamation mark (!) in case of breaking change,
followed by a colon (:),
followed by the commit message.

Example commit message fixing a bug non-breaking backwards compatibility:
    fix(module): fix bug #42

Example commit message adding a non-breaking feature:
    feat(module): add new API

Example commit message with a breaking change:
    refactor(module)!: remove infinite loop
"
exit 1
