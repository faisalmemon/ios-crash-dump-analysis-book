#!/bin/bash

usage() {                                      
  echo "Usage: $0 -l languageCode file1 file2 ... fileN " 1>&2
}

exit_abnormal() {                             
  usage
  exit 1
}

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

# English (en) is the default language whose files
# do not carry a language code prefix directory path
# because the original and canonical version of the
# book is in US-English.
# When we are supplied "en" it means do not try to
# remap any path names.
if [[ $langName == "en" ]]
then
	echo $remainingArgs
	exit 0
fi


# Try to remap path names to a language specific
# version.  Fallback to the English version if
# unsuccessful.
for file in ${remainingArgs}
do
	leafName=$(basename $file)
	if [[ -f markdown/$langName/${leafName} ]]
	then
		echo markdown/$langName/${leafName}
	else
		echo $file
	fi
done
