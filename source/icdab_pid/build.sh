#!/bin/bash

gcc tfpexample.c -sectcreate __TEXT __info_plist ./Info.plist -o tfpexample -framework Security -framework CoreFoundation
codesign -s tfpexample ./tfpexample

