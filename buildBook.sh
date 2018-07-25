#!/bin/bash

PANDOC_OPTIONS="-f markdown_mmd --standalone --bibliography bibliography.bib --toc"

pandoc $(cat pageOrder.txt) pandocMetaData.yaml "$PANDOC_OPTIONS" -c style/gitHubStyle.css -o foo.html
pandoc $(cat pageOrder.txt) pandocMetaData.yaml "$PANDOC_OPTIONS" -o foo.pdf
pandoc $(cat pageOrder.txt) pandocMetaData.yaml "$PANDOC_OPTIONS" -o foo.docx

mkdir -p docs
cp foo.html docs/index.html
git add docs/index.html
rm -rf docs/screenshots docs/style
cp -pr screenshots docs/screenshots
cp -pr style docs/style
git add docs/screenshots docs/style
git commit -m'update published book on github pages'
git push
