This chapter explains how to do local crash dump symbolification.

When dealing with real world crashes, a number of different entities are involved.  These can be the end user device, the settings allowing the crash report to be sent back to Apple, the symbols held by Apple and your local development environment setup to mirror such a configuration.

In order to understand how things all fit together it is best to start from first principles and do the data conversion tasks yourself so if you have to diagnose symbolification issues, you have some experience with the technologies at hand.

Normally when you develop an app, you are deploying the Debug version of your app onto your device.  When you are deploying your app for testers, app review, or app store release, you are deploying the Release version of your app.

Release builds are special for crash dump analysis because they create a lookup
file, called a DSYM file, which map machine addresses to source code references
so the functions involved at the time of a crash can be seen in a meaningful
representation.  This is called symbolificiation.

Xcode is by default setup so that only DSYM files are generated for Release
builds.  We want to do a local demonstration of DSYMs without having to go
via the App Store so we have maximum control of all the parts involved.
crash report into meaningful references to your source code

The build system uses the command `dsymutil path_to_app_binary -o output_symbols.dSYM` to do the job.
GenerateDSYMFile /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app.dSYM /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app/icdab_planets
    cd /Users/faisalm/dev/icdab/source/icdab_planets
    export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app/icdab_planets -o /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app.dSYM

to create a DSYM file.

