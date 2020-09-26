#!/bin/bash

usage() {
  echo "Usage: $0 [-l languageCode]" 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

langName="en"

while getopts "l:" options; do
  case "${options}" in
    l)
      langName=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

shift $(($OPTIND - 1))
remainingArgs=$@

./commatrademark.sh > trademarks.md

rm foo.$langName.*

filesToProcess=$(./get_markdown_for_lang.sh -l $langName $(cat frontPages.txt mainPages.txt))
latexFilesToProcess=$(./get_markdown_for_lang.sh -l $langName $(cat frontPages_latex.txt mainPages.txt))


# We allow first person in the preface and second person in the Introduction.
# Elsewhere it is third person only.

ignoreFiles='Introduction|Preface|Acknowledgements'

echo Usages of "you" in the narrative
for file in $filesToProcess
do
	if [[ $file =~ $ignoreFiles ]]
	then
		echo -n .
	else
	        grep you $file | grep --color -v hammer | grep -i --color -v layout || echo -n .
	fi

done

echo

echo Processing foo.$langName.html
pandoc $filesToProcess pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc -c style/gitHubStyle.css -o foo.$langName.html
echo Processing boo.$langName.latex
pandoc $latexFilesToProcess pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc --template=style/styleToCreateIndex.latex -V documentclass=book -o boo.$langName.latex

echo Indexing pass 0
pdflatex boo.$langName.latex > boo.$langName.pass.0.log </dev/null
echo Indexing pass 1
pdflatex boo.$langName.latex > boo.$langName.pass.1.log </dev/null
echo Indexing pass 2
pdflatex boo.$langName.latex > boo.$langName.pass.2.log </dev/null

echo "Check for errors; cslreferences error already is known"
egrep -n "LaTeX Error:|Error: Unicode character|Fatal error occurred" boo.$langName.pass.*.log

echo Processing foo.$langName.epub
pandoc $filesToProcess pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --toc --css=style/ebook.css -o foo.$langName.epub

echo Processing foo.$langName.docx
pandoc $filesToProcess pandocMetaData.yaml -f markdown+smart --standalone --bibliography bibliography.bib --reference-doc=style/referenceWordDocumentTemplate.docx -o foo.$langName.docx

echo Constructing github pages

mkdir -p docs/$langName
cp foo.$langName.html docs/$langName/index.html
git add docs/$langName/index.html
rm -rf docs/$langName/screenshots docs/$langName/style
cp -pr screenshots docs/$langName/screenshots
cp -pr style docs/$langName/style

echo Checking in github pages changes
git add docs/$langName/screenshots docs/$langName/style
git commit -m"update published $langName book on github pages"
git push
