#!/bin/bash

pandoc $(cat pageOrder.txt) pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc -c style/gitHubStyle.css -o foo.html
pandoc $(cat pageOrder.txt) pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc -o foo.pdf

mkdir -p docs
cp foo.html docs/index.html
git add docs/index.html
rm -rf docs/screenshots
cp -pr screenshots docs/screenshots
git add docs/screenshots
git commit -m'update published book on github pages'
git push
