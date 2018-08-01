#!/bin/bash

mkdir -p generated

gcc tfpexample.c -sectcreate __TEXT __info_plist ./Info.plist -o generated/tfpexample -framework Security -framework CoreFoundation

cp -p Info.plist generated

cd generated
codesign -s tfpexample ./tfpexample
