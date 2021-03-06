#!/bin/bash

set -x

: ${rev:=HEAD}

fail() { echo "Fatal error: $@." >&2; exit 1; }

git_repo_sweep()
{
  # be sure you won't need the original refs from a previous filter-branch before doing the sweep
  git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
}

# all the basic steps we're going to perform
git_index_info_list() { git ls-files -s; }
git_index_info_path_prepend() { [ -z $1 ] && fail "Nothing to prepend"; sed s-$'\t'-$'\t'${1%%/}/-; }
git_index_info_rewrite()
{
  local index="$GIT_INDEX_FILE"
  local temporary="$index.rewrite"

  [ -z "$index" ] && fail "To be used in a git-filter-branch context"

  [ -e "$temporary" ] && fail "$temporary: Index file already exists"

  GIT_INDEX_FILE="$temporary" git update-index --index-info && mv -v "$temporary" "$index"

  [ -e "$temporary" ] && fail "$temporary: Temporary file still exists"
}

git_index_filter()
{
  git filter-branch --index-filter "$@" $rev
}

git_index_rewrite_to_subfolder()
{
  local prefix="${1:-subfolder/}"

  # some prerequisites needed for our filter magic to work
  export -f git_index_info_{list,path_prepend,rewrite}

  git_index_filter "git_index_info_list | git_index_info_path_prepend ${prefix} | git_index_info_rewrite"
}

# allow git_index_info_* functions to use fail in subshell
export -f fail

git_repo_sweep
git_index_rewrite_to_subfolder

