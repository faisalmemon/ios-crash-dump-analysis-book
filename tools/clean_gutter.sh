#!/bin/bash

usage() {
  echo "Usage: $0 -r rootForRelativePaths relPath1 relPath2 ... relPathN " 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

rootPath=_invalid_

while getopts "r:" options; do
  case "${options}" in
    r)
      rootPath=${OPTARG}
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

if [[ $rootPath == "_invalid_" ]]
then
    exit_abnormal
fi

echo root path is $rootPath

shift $(($OPTIND - 1))
remainingArgs=$@

scriptPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if ! [[ -f $scriptPath/markdown_fold ]]
then
    echo You need to build the markdown_fold tool first
    exit 1
fi

for item in ${remainingArgs}
do
    candidate=${rootPath}/${item}
    if [[ -a ${candidate} ]]
    then
        echo Processing ${candidate}
        $scriptPath/markdown_fold ${candidate} > ${candidate}.new
        diff ${candidate} ${candidate}.new
        mv ${candidate}.new ${candidate}
        rm -f ${candidate}.new ${candidate}.orig
    fi
done
