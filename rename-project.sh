#!/bin/bash

# Check if an argument was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <word>"
  exit 1
fi

# Word to replace
WORD=$1

# Convert to lower case, upper case, and Pascal case
LOWER=$(echo "$WORD" | tr '[:upper:]' '[:lower:]')
UPPER=$(echo "$WORD" | tr '[:lower:]' '[:upper:]')
PASCAL=$(echo "$WORD" | awk '{ for (i=1; i<=NF; i++) { $i=toupper(substr($i,1,1)) tolower(substr($i,2)); } print }')

# Perform the replacements
find . -type f -exec sed -i "s/${LOWER}/${LOWER}/g; s/${UPPER}/${UPPER}/g; s/${PASCAL}/${PASCAL}/g" {} +

echo "Replacements completed for: ${LOWER}, ${UPPER}, ${PASCAL}"
