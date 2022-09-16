#!/bin/bash
# Show and replace all occurrances of $2, run from within repository root.
# First, show occurences.
echo "### Occurrences: ###"
{ occurrences=$(
    grep --exclude=README.md --exclude-dir=.git --exclude-dir=maintenance -I -R "${2:-my.domain.placeholder}" . \
        | tee /dev/fd/3 \
        | awk -F: '{ print $1 }' \
        | uniq); } 2> /dev/null 3>&1
# Then replace after confirmation
read -p "Replace all with '${1:-$HOSTNAME}'? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  for occurrence in $occurrences; do
    sed -i "s|${2:-my.domain.placeholder}|${1:-$HOSTNAME}|g" "${occurrence}"
  done
fi
