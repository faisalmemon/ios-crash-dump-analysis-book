### Jablotron crash

The `Jablotron` program is a program that manages alarms and detectors in the home.

Here is an Crash Report where it has crashed, truncated for ease of demonstration:

```
Incident Identifier: 732438C5-9E5A-48E7-95E2-76C800CDD6D9
CrashReporter Key:   181EC21F-295A-4D13-B14E-8BE1A7DFB5C7
Hardware Model:      iPhone3,1
Process:         MyJablotron_dev [177]
Path:            /var/mobile/Applications/D3CC3D22-1B0F-4CAF-8F68-71AD3B211CD9/
MyJablotron_dev.app/MyJablotron_dev
Identifier:      net.jablonet.myjablotron.staging
Version:         3.3.0.14 (3.3.0.14)
Code Type:       ARM
Parent Process:  launchd [1]

Date/Time:       2016-05-24T07:59:56Z
Launch Time:     2016-05-24T07:57:08Z
OS Version:      iPhone OS 7.1.2 (11D257)
Report Version:  104

Exception Type:  SIGBUS
Exception Codes: BUS_ADRALN at 0xcd0b1c
Crashed Thread:  0

Thread 0 Crashed:
0   libswiftCore.dylib                   0x011aed64 0xfba000 + 2051428
1   MyJablotron_dev                      0x004e7c18 0xb2000 + 4414488
2   libswiftCore.dylib                   0x011b007f 0xfba000 + 2056319
3   libswiftCore.dylib                   0x011aff73 0xfba000 + 2056051
4   libswiftCore.dylib                   0x011adf29 0xfba000 + 2047785
5   libswiftCore.dylib                   0x011adf73 0xfba000 + 2047859
6   MyJablotron_dev                      0x00614a6c
 type metadata accessor for
 MyJablotron.CDFM<MyJablotron.ChartDataPointStructure,
  MyJablotron.ChartDataPointStructureLegend>
   (ChartThermoPlotSpace.swift:0)
7   MyJablotron_dev                      0x00606698
 MyJablotron.ChartThermoPlotSpace.init ()MyJablotron.ChartThermoPlotSpace
  (ChartThermoPlotSpace.swift:206)
8   MyJablotron_dev                      0x00606c60
 MyJablotron.ChartThermoPlotSpace.__allocating_init ()
 MyJablotron.ChartThermoPlotSpace (ChartThermoPlotSpace.swift:0)
9   MyJablotron_dev                      0x0048825c
 MyJablotron.ChartBase.initWithThermometer (__ObjC.Thermometer)()
  (ChartBase.swift:139)
10  MyJablotron_dev                      0x00488034
 MyJablotron.ChartBase.initWithSegment (__ObjC.Segment)()
  (ChartBase.swift:123)
11  MyJablotron_dev                      0x0059186c
 MyJablotron.ChartViewController.setupSegment ()()
  (ChartViewController.swift:106)
12  MyJablotron_dev                      0x0058f374
 MyJablotron.ChartViewController.viewDidLoad ()()
  (ChartViewController.swift:39)
13  MyJablotron_dev                      0x0058f5a4
 @objc MyJablotron.ChartViewController.viewDidLoad ()()
  (ChartViewController.swift:0)
14  UIKit                                0x3227d4ab
 -[UIViewController loadViewIfRequired] + 516
15  UIKit                                0x3227d269
 -[UIViewController view] + 22
16  UIKit                                0x3240936b
 -[UINavigationController _startCustomTransition:] + 632
17  UIKit                                0x32326d63
 -[UINavigationController _startDeferredTransitionIfNeeded:] + 416
18  UIKit                                0x32326b6d
 -[UINavigationController __viewWillLayoutSubviews] + 42
19  UIKit                                0x32326b05
 -[UILayoutContainerView layoutSubviews] + 182
20  UIKit                                0x32278d59
 -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 378
21  QuartzCore                           0x31ef662b
 -[CALayer layoutSublayers] + 140
22  QuartzCore                           0x31ef1e3b
 CA::Layer::layout_if_needed(CA::Transaction*) + 348
23  QuartzCore                           0x31ef1ccd
 CA::Layer::layout_and_display_if_needed(CA::Transaction*) + 14
24  QuartzCore                           0x31ef16df
 CA::Context::commit_transaction(CA::Transaction*) + 228
25  QuartzCore                           0x31ef14ef
 CA::Transaction::commit() + 312
26  QuartzCore                           0x31eeb21d
 CA::Transaction::observer_callback(__CFRunLoopObserver*,
    unsigned long, void*) + 54
27  CoreFoundation                       0x2fa27255
 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 18
28  CoreFoundation                       0x2fa24bf9
 __CFRunLoopDoObservers + 282
29  CoreFoundation                       0x2fa24f3b
 __CFRunLoopRun + 728
30  CoreFoundation                       0x2f98febf
 CFRunLoopRunSpecific + 520
31  CoreFoundation                       0x2f98fca3 CFRunLoopRunInMode + 104
32  GraphicsServices                     0x34895663 GSEventRunModal + 136
33  UIKit                                0x322dc14d UIApplicationMain + 1134
34  MyJablotron_dev                      0x002b0683 main (main.m:16)
35  libdyld.dylib                        0x3a719ab7 start + 0
```

We can see the crash is in the Swift Core runtime library.
When we see a crash in common code, from Apple, it usually indicates a misuse of APIs.  In those cases, we expect to see a descriptive error.

In this example, we get a bus alignment error.  Apple's library code accessed a memory address improperly for the CPU architecture.

This is a surprise.  Sometimes when we use an advanced feature, or set compiler optimization settings, we can trigger errors in special cases or lesser used code paths.

We see that the problem is during object initialization time:

```
6   MyJablotron_dev                      0x00614a6c
 type metadata accessor for
 MyJablotron.CDFM<MyJablotron.ChartDataPointStructure,
  MyJablotron.ChartDataPointStructureLegend>
   (ChartThermoPlotSpace.swift:0)
7   MyJablotron_dev                      0x00606698
 MyJablotron.ChartThermoPlotSpace.init ()MyJablotron.ChartThermoPlotSpace
  (ChartThermoPlotSpace.swift:206)
8   MyJablotron_dev                      0x00606c60
 MyJablotron.ChartThermoPlotSpace.__allocating_init ()
 MyJablotron.ChartThermoPlotSpace (ChartThermoPlotSpace.swift:0)
```

The "metadata accessor" phrase is interesting as it implies we are running code that the compiler generates rather than code we have directly written.  Perhaps, as a workaround, we could simplify the code to use simpler language features.

Here we should aim to write a simple test case by taking the `ChartThermoPlotSpace` class and simplifying it until we get the essential code for the crash to occur.

This crash was resolved by Apple updating their compiler to correct a Swift Generics bug.
