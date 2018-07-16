This chapter explains how to do local crash dump symbolification.

When dealing with real world crashes, a number of different entities are involved.  These can be the end user device, the settings allowing the crash report to be sent back to Apple, the symbols held by Apple and your local development environment setup to mirror such a configuration.

In order to understand how things all fit together it is best to start from first principles and do the data conversion tasks yourself so if you have to diagnose symbolification issues, you have some experience with the technologies at hand.

Normally when you develop an app, you are deploying the Debug version of your app onto your device.  When you are deploying your app for testers, app review, or app store release, you are deploying the Release version of your app.

Release builds are special for crash dump analysis because they create a lookup
file, called a DSYM file, which map machine addresses to source code references
so the functions involved at the time of a crash can be seen in a meaningful
representation.  This is called symbolification.  Xcode also prunes out
any debug information from the released binaries during deployment to help prevent
reverse engineering of your program.

Xcode is by default setup so that only DSYM files are generated for Release
builds, and not for Debug builds.

Xcode by default for Debug builds puts the equivalent debugging information into the binary you are debugging so that when you test out your app, and there is a crash, the debugger which launched your app knows where the program has gone wrong and shows you the appropriate place in the code in your Xcode session.
The advantage of this approach is that the correct symbol information is bound into the actual binary that had the problem so no possibility of a mismatch can occur.  The downside is that it makes the binary much larger and allows reverse engineers to peek into your binary quite easily as if you had published the source code together with the program.

From Xcode, in your build settings, searching for "Debug Information Format" we see the following settings:

Setting|Meaning|Usually set for target
--|--|--
DWARF|Debugging information built into the binary itself|Debug
DWARF with dSYM File|We get an extra file also generated with symbols|Release

In the default setup, if you run your debug binary on your device, launching it from the app icon itself then if it were to crash you would not have any symbols in the crash report.  This confuses many people.

Whilst you may have all the source code for your program, it's the symbols generated at the time of the original build which are needed for symbolification.

To avoid this problem, the sample app `icdab_planets` has been configured to have `DWARF  with dSYM File` set for both debug and release targets.

The crash report, seen from Windows->Devices and Simulators->View Device Logs,
will then be transformed from something that looks like

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	0x0000000183944000 basename_r + 0
4   icdab_planets                 	0x00000001008e45bc 0x1008e0000 + 17852
5   UIKit                         	0x000000018db56ee0 -[UIViewController loadViewIfRequired] + 1020
```

to

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	0x0000000183944000 basename_r + 0
4   icdab_planets                 	0x0000000104e145bc -[PlanetViewController viewDidLoad] + 17852 (PlanetViewController.mm:33)
5   UIKit                         	0x000000018db56ee0 -[UIViewController loadViewIfRequired] + 1020
```


  We want to do a local demonstration of DSYMs without having to go
via the App Store so we have maximum control of all the parts involved.

We want to be able to do a normal Debug build of our app, deploy it to our local device.  
Then when we run it and see it crash have Xcode give us full details of the crash.

The build system uses the command `dsymutil path_to_app_binary -o output_symbols.dSYM` to do the job.
GenerateDSYMFile /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app.dSYM /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app/icdab_planets
    cd /Users/faisalm/dev/icdab/source/icdab_planets
    export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app/icdab_planets -o /Users/faisalm/Library/Developer/Xcode/DerivedData/icdab_planets-deimnsayssxnidbtkbhjtqahixqn/Build/Products/Debug-iphoneos/icdab_planets.app.dSYM

to create a DSYM file.
