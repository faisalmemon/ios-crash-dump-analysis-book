#!/bin/bash

# Take the index file and extract trademark references, and construct a comma separated list.

# foo.idx is the latex generated index (from the previous build)
# awk using $2 is to get the trademark index detail item (not the plain word trademark)
# awk using $1 is to chop out trailing text from the detail item which is the textual trademark
# sort is to get unique entries
# paste is to convert newline separated items into a comma separated list
# sed with /, / is to put a space after the commas
# sed with $/\./ is to put a period at the end of the line

# If there was no previous build, leave the trademark file empty by producing empty output

if [[ -f boo.idx ]] 
then
grep trademark boo.idx | awk -F'!' '{print $2}' | awk -F"}" '{print $1}' | sort -u | paste -s -d, - | sed -e 's/,/, /g' | sed -e 's/$/\./'
fi
