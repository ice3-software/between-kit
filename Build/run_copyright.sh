#!/bin/bash

declare -a SRC_FOLDERS=("Pod" "Use Cases" "Tests")

#
# Year is determined locally as the fn is called from a subshell
# in `find .. exec`
#
function bumpCp {
    local year=$(date +"%Y")
    sed -i '' "s/Copyright (c) [0-9][0-9]*/Copyright (c) $year/g" "$1"
}

export -f bumpCp

for folder in "${SRC_FOLDERS[@]}"
do
    find "./$folder" \( -name "*.h" -o -name "*.m" \) -exec bash -c 'bumpCp "$0"' {} \;
done

bumpCp "./LICENSE"