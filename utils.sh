#!/usr/bin/env bash

function joinByString() {
  local separator="$1"
  shift
  local first="$1"
  shift
  printf "%s" "$first" "${@/#/$separator}"
}

# get index in array
get_index () {
    local array=("${!1}")
    local searching=$2
    local i
    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" = "${searching}" ]]; then
            echo $i
            return
        fi
    done
    echo -1
}
