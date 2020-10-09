#!/bin/bash

workspaceFile=../icdab.xcworkspace
logFile=./testsuite.log.txt

# In your Devices manager, set the name for your attached iPad as follows
testDevice=iPod_touch_7_gen

# In your Devices manager, set the name for Apple TV simulator as follows
testAppleTv=apple_tv

# Hardware Testing on iPad Pro
testSuite="icdab_edgeTests icdab_aslTests icdab_aslUITests icdab_asTests icdab_asUITests icdab_cameraUITests icdab_planets_facadeTests icdab_planets_facadeUITests icdab_planets_stlTests icdab_ptUITests icdab_planets_stlUITests icdab_planetsTests icdab_planetsUITests icdab_wrapTests icdab_wrapUITests"

# Simulator Testing on Mac
logicTestingTestSuite="icdab_thread_test"

# Logic Testing on Apple TV
logicTestingTvTestSuite="icdab_cycleTests"

echo We change into the script directory in order to execute using relative paths for resources
cd "${BASH_SOURCE%/*}" || exit

rm -f $logFile

for testScheme in $testSuite
do
	echo ++ Scheme ++ $testScheme
	xcodebuild test -workspace $workspaceFile -scheme $testScheme -destination name=$testDevice
done | tee -a $logFile

for testScheme in $logicTestingTestSuite
do
	echo ++ Scheme ++ $testScheme
	xcodebuild test -workspace $workspaceFile -scheme $testScheme -destination platform=macOS
done | tee -a $logFile

for testScheme in $logicTestingTvTestSuite
do
	echo ++ Scheme ++ $testScheme
	xcodebuild test -workspace $workspaceFile -scheme $testScheme -destination name=$testAppleTv
done | tee -a $logFile

exit

