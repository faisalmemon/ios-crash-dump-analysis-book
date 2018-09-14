#!/bin/bash

# Take the index file and extract trademark references, and construct a comma separated list.

grep trademark foo.idx | awk -F'!' '{print $2}' | awk -F"}" '{print $1}' | sort -u | paste -s -d, - | sed -e 's/,/, /g'
