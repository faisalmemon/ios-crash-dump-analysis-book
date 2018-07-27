# Symbolification

This chapter explains crash dump symbolification\index{symbolification}.
We use the `icdab_planets` sample app to demonstrate a crash. @icdabgithub

When dealing with real world crashes, a number of different entities are involved.  These can be the end user device, the settings allowing the crash report to be sent back to Apple, the symbols held by Apple and our local development environment setup to mirror such a configuration.

In order to understand how things all fit together it is best to start from first principles and do the data conversion tasks ourselves so if we have to diagnose symbolification issues, we have some experience with the technologies at hand.

## Build Process

Normally when we develop an app, we are deploying the Debug version of our app onto our device.  When we are deploying\index{software!deployment} our app for testers, app review, or app store release, we are deploying the Release version of our app.

In both scenarios debug information is placed into the binary being generated.
This is called DWARF\index{DWARF} debugging information.

For Release builds, that information is then stripped out and placed into a DSYM\index{DSYM} file.
For Debug builds, it is left in.

The debugger can use debugging information in the binary when it sees a crash to
help us understand where the program has gone wrong.

When a user sees our program crash, there is no debugger\index{debugger}.  Instead, a crash
report is generated.  This comprises the machine addresses where the problem was
seen.  Symbolification can convert these addresses
into meaningful source code references.

In order for symbolification to occur, appropriate DSYM files must exist.

Xcode is by default setup so that only DSYM files are generated for Release
builds, and not for Debug builds.

The advantages of a debug build are:

- The debug information is never inconsistent or missing with the program code.
- The debugger can always obtain the symbol information during debugging.

The disadvantages of a debug build are:

- The binary ends up much larger so takes up more bandwidth to download.
- The binary takes up more disk space.
- Reverse engineers can quite easily see how the program works from the binary.


## Build Settings

From Xcode, in our build settings, searching for "Debug Information Format"\index{Xcode!Debug Information Format} we see the following settings:

Setting|Meaning|Usually set for target
--|--|--
DWARF|Debugging information built into the binary itself|Debug
DWARF with dSYM File|We get an extra file also generated with symbols|Release

In the default setup, if we run our debug binary on our device, launching it from the app icon itself then if it were to crash we would not have any symbols in the crash report.  This confuses many people.

Whilst we may have all the source code for our program, and DWARF data in the crashed binary, ReportCrash crash reporter only looks for DSYM files on our Mac in order to perform symbolification.

To avoid this problem, the sample app `icdab_planets` has been configured to have `DWARF with dSYM File` set for both debug and release targets.

## Observing a local crash

The `icdab_planets` program is designed to crash upon launch due to an assertion.

If the `DWARF with dSYM File` setting had not been made, we would get a partially symbolicated crash.

The crash report, seen from _Windows->Devices and Simulators->View Device Logs_,
would look like this (truncated for ease of demonstration)

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	0x0000000183944000 basename_r + 0
4   icdab_planets                 	0x00000001008e45bc 0x1008e0000 + 17852
5   UIKit                         	0x000000018db56ee0
-[UIViewController loadViewIfRequired] + 1020

Binary Images:
0x1008e0000 - 0x1008ebfff icdab_planets arm64
  <9ff56cfacd66354ea85ff5973137f011>
   /var/containers/Bundle/Application/BEF249D9-1520-40F7-93F4-8B99D913A4AC/
   icdab_planets.app/icdab_planets
```

However, with the setting in place, a crash would instead be reported as:

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288
pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	0x0000000183944000 basename_r + 0
4   icdab_planets                 	0x0000000104e145bc
-[PlanetViewController viewDidLoad] + 17852 (PlanetViewController.mm:33)
5   UIKit                         	0x000000018db56ee0
-[UIViewController loadViewIfRequired] + 1020
```

Lines 0, 1, 2, 5 are the same in both cases because our developer environment will
have the symbols for the iOS release under test.  In the second case, Xcode will
look up the DSYM file to clarify line 4.  It tells us this is line 33 in file
PlanetViewController.mm.  This is:

```
assert(pluto_volume != 0.0);
```

## DSYM structure

The DSYM file\index{DSYM!file structure} is strictly speaking a directory hierarchy:
```
icdab_planets.app.dSYM
icdab_planets.app.dSYM/Contents
icdab_planets.app.dSYM/Contents/Resources
icdab_planets.app.dSYM/Contents/Resources/DWARF
icdab_planets.app.dSYM/Contents/Resources/DWARF/icdab_planets
icdab_planets.app.dSYM/Contents/Info.plist
```

It is just the DWARF data normally put into the debug binary but copied into a separate file.

From looking at our build log, we can see how the DSYM was generated.
It is effectively just `dsymutil path_to_app_binary -o output_symbols_dir.dSYM`\index{command!dsymutil}

## Manual Symbolification

In order to help us get comfortable with crash dump reports, we can demonstrate
how the symbolification actually works.  In the first crash dump, we want to understand:

```
4   icdab_planets                 	0x00000001008e45bc 0x1008e0000 + 17852
```

If we knew accurately the version of our code at the time of the crash, we can
recompile our program, but with the DSYM setting switched on, and then get a
DSYM file after the original crash.  It should line up almost exactly.

The crash dump program tells us where the program was loaded, in memory, at the
time of the problem.  That tells us the master base offset\index{base offset} from
which all other address (TEXT) locations are relative to.  

At the bottom of the crash
dump, we have line `0x1008e0000 - 0x1008ebfff icdab_planets`
Therefore, the icdab_planets binary starts at location `0x1008e0000`

Running the lookup command `atos`\index{command!atos} symbolicates the line of interest:
```
# atos -arch arm64 -o ./icdab_planets.app.dSYM/Contents/Resources/DWARF/
icdab_planets -l 0x1008e0000 0x00000001008e45bc
-[PlanetViewController viewDidLoad] (in icdab_planets)
 (PlanetViewController.mm:33)
```

The crash reporter tool fundamentally just uses `atos` to symbolicate the
crash report, as well as providing other system related information.

Symbolification is described further by an Apple Technote in case we want to get into it in more detail. @tn2123

## Reverse Engineering Approach

In the above example we have the source code and symbols for the crash dump so can do Symbolification.

Sometimes we may have included a third party binary framework in our project for which we do not have the source code.  It is good practice for the vendor to supply symbol information for their framework to allow crash dump analysis.  When symbol information is not available, it is still possible to make progress by applying some reverse engineering.

When working with third parties there is typically a much larger turnaround time for diagnostics and troubleshooting.  We find that well written and specific bug reports can speed up things a lot.  The following approach can help provide the kind of specific information needed.

We shall demonstrate our approach using the Hopper tool mentioned in the Tooling chapter.

Launching hopper, we choose _File->Read Executable to Disassemble_.  The binary in our case is `examples/assert_crash_ios/icdab_planets`

We need to "rebase" our disassembly so the addresses it shows mirror those of the program when it crashed.  We choose _Modify->Change File Base Address_.  As before, we supply `0x1008e0000`.

Now we can visit the code that crashed.  The address `0x00000001008e45bc` is actually the address the device would _return_ to after performing the function call in the stack trace.  Nevertheless, it puts us in the right part of the file.  We choose _Navigate->Go To Address or Symbol_ and supply `0x00000001008e45bc`

The overall view we see is

![](screenshots/hopperAddressView.png)

Zooming in on the code line, we have

![](screenshots/hopperPlanetAbort.png)

This indeed shows the return address for the assert method.  Further up, we see the test for Pluto's volume being non-zero.  This is just a very basic Hopper example.  We shall revisit Hopper later to demonstrate its most interesting feature - that of being able to generate pseudocode from assembly code.  This lowers the mental load of comprehending crashes.  Most developers rarely look at assembly code nowadays so this feature is worth the cost of the software itself!

Now at least for the current problem, we could formulate a bug report that said the code was crashing because Pluto's volume was zero.  That may be enough to unlock the problem from the framework vendor's point of view.

In a more complex case, imagine we were using an image conversion library that was crashing.  
There can be many pixel\index{pixel} formats for images. An `assert` might lead us to notice it was the format that was asserting.  Therefore, we could just try a different pixel format.

Another example would be a security library.  Security code often gives back generic error codes, not specific fault codes to allow for future code enhancement and avoid leaking internal details.  A crash dump in a security library might point out exactly the kind of security issue, and help us correct some data structure passed into the library much earlier on.
