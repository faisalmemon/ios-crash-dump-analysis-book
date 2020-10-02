#!/bin/bash

filelist=$*

if ! [[ -f ./markdown_fold ]]
then
    echo You need to build the markdown_fold tool first
    exit 1
fi

for item in ${filelist}
do
    if [[ -f ${item} ]]
    then
	echo Processing $item
	cp ${item} ${item}.orig
	./markdown_fold ${item} > ${item}.new
	mv ${item}.new ${item}
	diff ${item}.orig ${item}
	rm ${item}.orig
    fi
done
