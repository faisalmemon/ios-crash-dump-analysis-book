#!/bin/bash

pandoc $(cat pageOrder.txt) pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc -c style/gitHubStyle.css -o foo.html
