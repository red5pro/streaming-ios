#!/bin/bash

# = NOTE =
# Use at root of repository: ./scripts/license_inject.sh
SRC=$(realpath R5ProTestbed)
FIND="Copyright ©"
STRING="The Software shall be used solely in conjunction with Red5 Pro"
LICENSE_FILE=$(realpath scripts/LICENSE_INJECT_COLLAPSED)
IS_INTEGER='^[0-9]+$'
WAS_UPDATED=0

# check to see if already has license...
echo "Traversing ${SRC}..."
while IFS= read -r -d '' file; do
        if grep -q "$STRING" "$file"; then
                echo "Already has license. ${file}"
        else
                LINE=$(awk '/'"$FIND"'/{ print NR; exit }' "$file")
                if ! [[ "$LINE" =~ $IS_INTEGER ]]; then
                    echo "Could not find copyright for ${file}."
                else
                    LICENSE=$(cat "$LICENSE_FILE")
                    sed -i ''"$LINE"'s#.*#'"$LICENSE"'#' "$file"
                fi
                WAS_UPDATED=1
        fi
done < <(find "${SRC}/" -type f -name "*.swift" -print0)

if [ $WAS_UPDATED != 0 ]; then
  echo "License injection was required. Please commit all updated files."
  exit 1
fi
