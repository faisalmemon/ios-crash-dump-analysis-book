#!/bin/bash

csrutil status | grep disabled
wasDisabled=$?

if [[ $wasDisabled == "1" ]]
then
	echo We need System Integrity Protection Disabled
	exit 1
fi

mkdir -p generated

gcc tfpexample.c -sectcreate __TEXT __info_plist ./Info.plist -o generated/tfpexample -framework Security -framework CoreFoundation

cp -p Info.plist generated

cd generated
codesign -s tfpexample ./tfpexample
