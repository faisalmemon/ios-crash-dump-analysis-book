#!/bin/bash

testDevice=iPad_Pro_9_7_inch
workspaceFile=../icdab.xcworkspace
testSuite="icdab_aslTests icdab_aslUITests icdab_asTests icdab_asUITests icdab_planets_facadeTests icdab_planets_facadeUITests icdab_planets_stlTests icdab_planets_stlUITests icdab_planetsTests icdab_planetsUITests icdab_wrapTests icdab_wrapUITests"

echo We change into the script directory in order to execute using relative paths for resources
cd "${BASH_SOURCE%/*}" || exit

for testScheme in $testSuite
do
	echo ++ Scheme ++ $testScheme
	xcodebuild test -workspace $workspaceFile -scheme $testScheme -destination name=$testDevice
done

