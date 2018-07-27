# The Crash Report

In this chapter, we get into the details of what comprises a crash report.
Our main focus is the iOS crash report.  We also cover the macOS crash report,
which caries a slightly different structure but serves the same purpose.

When a crash occurs the `ReportCrash`\index{command!ReportCrash} program extracts information from the crashing process from the Operating System.  The result is a text file with a `.crash`\index{extension!.crash} extension.

When symbol information is available, Xcode will symbolicate the crash report to show symbolic names instead of machine addresses.  This improves the comprehensibility of the report.

Apple have produced a detailed document explaining the anatomy of a crash dump.  @tn2151

## System Diagnostics

Crash Reports are just one part of a much bigger diagnostic reporting story.

Ordinarily as application developers, we don't need to look much further.  However, if our problems are potentially triggered by an unexplained series of events or a more complex system interaction with hardware or Apple provided system services, then not only do we need to look at our crash reports, we need to study the system diagnostics.

### Extracting System Diagnostic Information
When understanding the environment that gave rise to our crash, we may need to install Mobile Device Management Profiles (to switch on certain debugging subsystems), or create virtual network interfaces (for network sniffing).  Apple provide a great web page covering each scenario.  @apple-sysdiag  

On iOS, the basic idea is that we install a profile, which alters our device to produce more logging, and then we reproduce the crash (or get the customer to do that).  Then we press a special key sequence on the device (for example, both volume buttons and the side button).  The system vibrates briefly to indicate it is running a program, `sysdiagnose`\index{command!sysdiagnose}, which extracts many log files.  Then we use iTunes to synchronize our device to retrieve the resultant `sysdiagnose_date_name.tar.gz` file.  Inside this archive file are many system and subsystem logs, and we can see when crashes occur and the context that gave rise to them.

An equivalent approach is available on macOS as well.

## Guided tour of an iOS Crash Report

Here we go through each section of an iOS crash report and explain the fields. @tn2151

Note here iOS Crash Report means a crash report that came from a physical target device.
After a crash, apps are often debugged on the Simulator.  The exception code may be different in that case because the Simulator uses different methodology to cause the app to stop under the debugger.

### Crash Report Header Section

A Crash Report starts with the following header:

```
Incident Identifier: E030D9E4-32B5-4C11-8B39-C12045CABE26
CrashReporter Key:   b544a32d592996e0efdd7f5eaafd1f4164a2e13c
Hardware Model:      iPad6,3
Process:             icdab_planets [2726]
Path:                /private/var/containers/Bundle/Application/
BEF249D9-1520-40F7-93F4-8B99D913A4AC/icdab_planets.app/icdab_planets
Identifier:          www.perivalebluebell.icdab-planets
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           www.perivalebluebell.icdab-planets [1935]
```

These items are explained by the following table:

Entry|Meaning
--|--
Incident Identifier|Unique report number of crash
CrashReporter Key|Unique identifier for the device that crashed
Hardware Model|Apple Hardware Model @ios-devices
Process|Process name (number) that crashed
Path|Full pathname of crashing program on the device file system
Identifier|Bundle identifier from `Info.plist`\index{Info.plist}
Version|CFBundleVersion; also CFBundleVersionString in brackets
Code Type|Target architecture of the process that crashed
Role\index{task!role}|The process `task_role`.  An indicator if we were in the background, foreground, or was a console app.  Mainly affects the scheduling priority of the process.
Parent Process|Parent of the crashing process. `launchd`\index{command!launchd} is a process launcher and is often the parent.
Coalition\index{task!coalition}|Tasks are grouped into coalitions so they can pool together their consumption of resources @resource-management

The first thing to look at is the version.  Typically if we are a small team or an individual, we will not have the resources to diagnose crashes in older versions of our app, so the first thing might be to get the customer to install the latest version.

If we have a lot of crashes then we might see it being a problem to one customer (common CrashReporter key seen) or lots of customers (so different CrashReporter keys are seen).  This may affect how we rank the priority of the crash.

The hardware model could be interesting.  It is iPad only devices, or iPhone only, or both?
Maybe our code has less testing or unique code paths for a given platform.

The hardware model might indicate an older device, which we have not tested on.

Whether the app crashed in the Foreground or Background (the Role) is interesting because most applications are not tested when they are backgrounded.  For example, we might receive a phone call, or have task switched between apps.

The Code Type (target architecture) is now mostly 64-bit ARM.  However, we might see ARM being reported - the original 32-bit ARM.

### Crash Report Date and Version Section

A Crash Report will continue with date and version information:

```
Date/Time:           2018-07-16 10:15:31.4746 +0100
Launch Time:         2018-07-16 10:15:31.3763 +0100
OS Version:          iPhone OS 11.3 (15E216)
Baseband Version:    n/a
Report Version:      104
```

These items are explained by the following table:

Entry|Meaning
--|--
Date/Time|When the crash occurred
Launch Time|When the process was originally launched before crashing
OS Version| Operating System Version (Build number).  @ios-versions
Baseband Version| Version number of the firmware of the cellular modem (used for phone calls) or `n/a` if the device has no cellular modem (most iPads, iPod Touch, etc.)
Report Version|The version of ReportCrash used to produce the report

The first thing to check is the OS Version.  Is it newer or older than we've tested?  Is it a beta version of the operating system?

The next thing to check is the difference between the launch time and the time of the crash.  Did the app crash immediately or after a long time?  Early start crashes can sometimes be a packaging and deployment problem.  We shall visit some techniques to tackle those later on.

Is the date a sensible value?  Sometimes a device is set back or forwards in time, perhaps to trigger date checks on security certificates or license keys.  Make sure the date is a realistic looking one.

Normally the baseband version is not interesting.  The presence of the baseband means we could be interrupted by a phone call (of course there is VOIP calling as well in any case).  iPad software is generally written to assume we're not going to get a phone call but iPads can be purchased with a cellular modem\index{iPad!cellular modem} option.

### Crash Report Exception Section

A Crash Report will next have exception\index{exception} information:

```
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Triggered by Thread:  0
```

or it may have a more detailed exception information:
```
Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace <0xF>, Code 0xdead10cc
Triggered by Thread:  0
```

What has happened is that the MachOS\index{MachOS} kernel has raised an Operating System Exception on the problematic process, which terminates the process.  The ReportCrash program then retrieves from the OS details of such an exception.

These items are explained by the following table:

Entry|Meaning
--|--
Exception Type|The type of exception in Mach OS. @exception-types
Exception Codes|These codes encode the kind of exception, such as trying to trying to access an invalid address, and supporting information.  @exception-types
Exception Note|Either this says `SIMULATED (this is NOT a crash)` because the process will killed by the watchdog timer, or it says `EXC_CORPSE_NOTIFY` because the process crashed
Termination Reason|Optionally present, this gives a Namespace (number or subsystem name) and a magic number Code (normally a hex number that looks like a English word).  See below for details on each Termination Codes.
Triggered by Thread|The thread in the process that caused the crash


In this section the most important item is the exception type.

Exception Type|Meaning
--|--
`EXC_CRASH (SIGABRT)` |Our program raised a programming language exception such as a failed assertion and this caused the OS to Abort our app
`EXC_CRASH (SIGQUIT)` |A process received a quit signal from another process that is managing it.  Typically, this means a Keyboard extension took too long or used up too much memory.  App extensions are given only limited amounts of memory.
`EXC_CRASH (SIGKILL)` |The system killed our app (or app extension), usually because some resource limit had been reached.  The Termination Reason needs to be looked at to work out what policy violation was the reason for termination.
`EXC_BAD_ACCESS` or `SIGSEGV` or `SIGBUS` |Our program most likely tried to access a bad memory location or the address was good but we did not have the privilege to access it.  The memory might have been deallocated due to due memory pressure.
`EXC_BREAKPOINT (SIGTRAP)` |This is due to an `NSException` being raised (possibly by a library on our behalf) or `_NSLockError` or `objc_exception_throw` being called.  For example, this can be the Swift environment detecting an anomaly such as force unwrapping a nil optional
`EXC_BAD_INSTRUCTION (SIGILL)` |This is when the program code itself is faulty, not the memory it might be accessing.  This should be rare on iOS devices; a compiler or optimiser bug, or faulty hand written assembly code.  On Simulator, it is a different story as using an undefined opcode is a technique used by the Swift runtime to stop on access to zombie objects (deallocated objects).

When Termination Reason is present, we can look up the Code as follows:

Termination Code | Meaning
--|--
`0xdead10cc`  |We held a file lock or sqlite database lock before suspending.  We should release locks before suspending.
`0xbaaaaaad` | A stackshot was done of the entire system via the side and both volume buttons.  See earlier section on System Diagnostics
`0xbad22222` | VOIP was terminated as it resumed too frequently.  Also see with code using networking whilst in the background.  If our TCP connection is woken up too many times (say 15 wakes in 300 seconds) we get this crash.
`0x8badf00d` | Our app took too long to perform a state change (starting up, shutting down, handling system message, etc.).  The watchdog timer noticed the policy violation and caused the termination.  The most common culprit is doing synchronous networking on the main thread.
`0xc00010ff` | The system detected a thermal event and kill off our app.  If it's just on one device it could be a hardware issue, not a software problem in our app.  If it happens on other devices, check our app's power usage using Instruments.
`0x2bad45ec` | There was a security violation. If the Termination Description says, "Process detected doing insecure drawing while in secure mode" it means our app tried to write to the screen when it was not allowed because for example the Lock Screen was being shown.

#### Magic Numbers and their Hexspeak

With a certain geek humor, the termination codes, when discussed, are spoken as follows:

Magic Number | Spoken Phrase
--|--
`0xdead10cc` | Deadlock
`0xbaaaaaad` | Bad
`0xbad22222` | Bad too (two) many times
`0x8badf00d` | Ate (eight) bad food
`0xc00010ff` | Cool Off
`0x2bad45ec` | Too bad for security

#### Aborts
When we have a `SIGABRT` , we should look for what exceptions and assertions are present in our code from the stack trace of the crashed thread.

#### Memory Issues
When we have a memory issue, `EXC_BAD_ACCESS` , `SIGSEGV` or `SIGBUS`.  The faulty memory reference is the second number of the Exception Codes number pair.  For this type of problem, the diagnostics settings within Xcode for the target in the schema are relevant.  The address sanitizer should be switched on to see if it can spot the error.  If that cannot detect the issue, try each of the memory management settings, one at a time.

If Xcode shows a lot of memory is being used by the app, then it might be that memory we were relying upon has been freed by the system.  For this, switch on the Malloc Stack logging option, selecting All Allocation and Free History.  Then at some point during the app, the MemGraph button can be clicked, and then the allocation history of objects explored.

#### Exceptions
When we have a `EXC_BREAKPOINT` it can seem confusing.  The program may have been running standalone without a debugger so where did the breakpoint come from?  Typically, we are running `NSException` code.  This will make the system signal the process with the trace trap signal and this makes any available debugger attach to the process to aid debugging.  So in the case where we were running the app under the debugger, even with breakpoints switched off, we would breakpoint in here so we can find out why there was a runtime exception.  In the case of normal app running, there is no debugger so we would just crash the app.

#### Illegal Instructions
When we have a `EXC_BAD_INSTRUCTION` , the exception codes (second number) will be the problematic assembly code.  This should be a rare condition.  It is worthwhile adjusting the optimization level of the code at fault in the Build Settings because higher level optimizations can cause more exotic instructions to be emitted during build time, and hence a bigger chance for a compiler bug.  Alternatively, the problem might be a lower level library which has hand assembly optimizations in it - such as a multimedia library.  Handwritten assembly can be the cause of bad instructions.

### Crash Report Filtered Syslog Section

The Crash Report continues with the syslog section:

```
Filtered syslog:
None found
```

This is an anomalous section because it is supposed to look at the process ID of the crashed process and then look to see if there are any syslog (System Log) entries for that process.  We have never seen filtered entries in a crash, and only see `None found` reported.

### Crash Report Exception Backtrace section

When our app has detected a problem and has asked the Operating System to terminate the app, we get an Exception Backtrace section of the report.  This covers the cases of calling `abort`, `NSException`,  `_NSLockError`, or `objc_exception_throw` either ourselves or indirectly through the Swift, Objective-C or C runtime support libraries.

What we don't get is the text of the actual assertion that had occurred.  One presumes that the prior section for filtered syslog information was supposed to do that job.  Nevertheless, _Window->Devices and Simulators->Open Console_ will allow us to recover that information.

When we see an Exception Backtrace in a customer crash report, we should ask if we can get the device console log for the crashing device.

We would for example see:
```
default	13:36:58.000000 +0000	icdab_nsdata	 My data is <> - ok since we can
 handle a nil

default	13:36:58.000000 +0100	icdab_nsdata	 
-[__NSCFConstantString _isDispatchData]: unrecognized selector sent to
instance 0x3f054

default	13:36:58.000000 +0100	icdab_nsdata	 *** Terminating app due to
uncaught exception 'NSInvalidArgumentException', reason:
'-[__NSCFConstantString _isDispatchData]: unrecognized selector sent to
instance 0x3f054'
	*** First throw call stack:
	(0x25aa391b 0x2523ee17 0x25aa92b5 0x25aa6ee1 0x259d2238 0x2627e9a5 0x3d997
    0x2a093785 0x2a2bb2d1 0x2a2bf285 0x2a2d383d 0x2a2bc7b3 0x27146c07
    0x27146ab9 0x27146db9 0x25a65dff 0x25a659ed 0x25a63d5b 0x259b3229
     0x259b3015 0x2a08cc3d 0x2a087189 0x3d80d 0x2565b873)

default	13:36:58.000000 +0100	SpringBoard	 Application
'UIKitApplication:www.perivalebluebell.icdab-nsdata[0x51b9]' crashed.

default	13:36:58.000000 +0100	UserEventAgent	 2769630555571:
 id=www.perivalebluebell.icdab-nsdata pid=386, state=0

default	13:36:58.000000 +0000	ReportCrash	 Formulating report for
corpse[386] icdab_nsdata

default	13:36:58.000000 +0000	ReportCrash	 Saved type '109(109_icdab_nsdata)'
 report (2 of max 25) at
 /var/mobile/Library/Logs/CrashReporter/icdab_nsdata-2018-07-27-133658.ips
```

The line of interest is:
```
'-[__NSCFConstantString _isDispatchData]: unrecognized selector sent to
instance 0x3f054'
```

This means the `NSString` class was sent the `_isDispatchData` method.
No such method exists.

The matching exception backtrace seen in the Crash Report is:
```
Last Exception Backtrace:
0   CoreFoundation                	0x25aa3916 __exceptionPreprocess + 122
1   libobjc.A.dylib               	0x2523ee12 objc_exception_throw + 33
2   CoreFoundation                	0x25aa92b0
-[NSObject+ 1045168 (NSObject) doesNotRecognizeSelector:] + 183
3   CoreFoundation                	0x25aa6edc ___forwarding___ + 695
4   CoreFoundation                	0x259d2234 _CF_forwarding_prep_0 + 19
5   Foundation                    	0x2627e9a0
-[_NSPlaceholderData initWithData:] + 123
6   icdab_nsdata                  	0x000f89ba
-[AppDelegate application:didFinishLaunchingWithOptions:]
 + 27066 (AppDelegate.m:26)
7   UIKit                         	0x2a093780
-[UIApplication _handleDelegateCallbacksWithOptions:isSuspended:restoreState:]
 + 387
8   UIKit                         	0x2a2bb2cc
-[UIApplication _callInitializationDelegatesForMainScene:transitionContext:]
 + 3075
9   UIKit                         	0x2a2bf280
-[UIApplication _runWithMainScene:transitionContext:completion:] + 1583
10  UIKit                         	0x2a2d3838
__84-[UIApplication _handleApplicationActivationWithScene:transitionContext:
completion:]_block_invoke3286 + 31
11  UIKit                         	0x2a2bc7ae
-[UIApplication workspaceDidEndTransaction:] + 129
12  FrontBoardServices            	0x27146c02
__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 13
13  FrontBoardServices            	0x27146ab4
-[FBSSerialQueue _performNext] + 219
14  FrontBoardServices            	0x27146db4
-[FBSSerialQueue _performNextFromRunLoopSource] + 43
15  CoreFoundation                	0x25a65dfa
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 9
16  CoreFoundation                	0x25a659e8 __CFRunLoopDoSources0 + 447
17  CoreFoundation                	0x25a63d56 __CFRunLoopRun + 789
18  CoreFoundation                	0x259b3224 CFRunLoopRunSpecific + 515
19  CoreFoundation                	0x259b3010 CFRunLoopRunInMode + 103
20  UIKit                         	0x2a08cc38 -[UIApplication _run] + 519
21  UIKit                         	0x2a087184 UIApplicationMain + 139
22  icdab_nsdata                  	0x000f8830 main + 26672 (main.m:14)
23  libdyld.dylib                 	0x2565b86e tlv_get_addr + 41
```

The format of this backtrace is the same as the thread backtrace, described later.

The purpose of the exception back trace section is to give more detail than that provided by the crashing thread.

The crashing thread in the above scenario had the thread backtrace:
```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x2572ec5c __pthread_kill + 8
1   libsystem_pthread.dylib       	0x257d8732 pthread_kill + 62
2   libsystem_c.dylib             	0x256c30ac abort + 108
3   libc++abi.dylib               	0x2521aae4 __cxa_bad_cast + 0
4   libc++abi.dylib               	0x2523369e default_terminate_handler+ 104094 () + 266
5   libobjc.A.dylib               	0x2523f0b0 _objc_terminate+ 28848 () + 192
6   libc++abi.dylib               	0x25230e16 std::__terminate(void (*)+ 93718 ()) + 78
7   libc++abi.dylib               	0x252308f8 __cxa_increment_exception_refcount + 0
8   libobjc.A.dylib               	0x2523ef5e objc_exception_rethrow + 42
9   CoreFoundation                	0x259b32ae CFRunLoopRunSpecific + 654
10  CoreFoundation                	0x259b3014 CFRunLoopRunInMode + 108
11  UIKit                         	0x2a08cc3c -[UIApplication _run] + 524
12  UIKit                         	0x2a087188 UIApplicationMain + 144
13  icdab_nsdata                  	0x000f8834 main + 26676 (main.m:14)
14  libdyld.dylib                 	0x2565b872 start + 2
```

If we only had the thread backtrace, we would know there was a casting problem `__cxa_bad_cast` but not much more.

A little bit of Internet searching reveals that `NSData` has a private helper class `_NSPlaceholderData`

What has happened here is that an `NSString` object was provided where an `NSData` object was expected.

### Crash Report Thread Section

The Crash Report continues with a dump of the thread backtraces as follows (formatted for ease of demonstration)

```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec
 __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288
 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c
 abort + 140
3   libsystem_c.dylib             	0x0000000183944000
 basename_r + 0
4   icdab_planets                 	0x0000000104e145bc
 -[PlanetViewController viewDidLoad] + 17852 (PlanetViewController.mm:33)
5   UIKit                         	0x000000018db56ee0
 -[UIViewController loadViewIfRequired] + 1020
6   UIKit                         	0x000000018db56acc
 -[UIViewController view] + 28
7   UIKit                         	0x000000018db47d60
 -[UIWindow addRootViewControllerViewIfPossible] + 136
8   UIKit                         	0x000000018db46b94
 -[UIWindow _setHidden:forced:] + 272
9   UIKit                         	0x000000018dbd46a8
-[UIWindow makeKeyAndVisible] + 48
10  UIKit                         	0x000000018db4a2f0
 -[UIApplication _callInitializationDelegatesForMainScene:transitionContext:]
  + 3660
11  UIKit                         	0x000000018db1765c
-[UIApplication _runWithMainScene:transitionContext:completion:] + 1680
12  UIKit                         	0x000000018e147a0c
__111-[__UICanvasLifecycleMonitor_Compatability
_scheduleFirstCommitForScene:transition:firstActivation:
completion:]_block_invoke + 784
13  UIKit                         	0x000000018db16e4c
+[_UICanvas _enqueuePostSettingUpdateTransactionBlock:] + 160
14  UIKit                         	0x000000018db16ce8
-[__UICanvasLifecycleMonitor_Compatability
_scheduleFirstCommitForScene:transition:firstActivation:completion:] + 240
15  UIKit                         	0x000000018db15b78
-[__UICanvasLifecycleMonitor_Compatability
activateEventsOnly:withContext:completion:] + 724
16  UIKit                         	0x000000018e7ab72c
__82-[_UIApplicationCanvas _transitionLifecycleStateWithTransitionContext:
completion:]_block_invoke + 296
17  UIKit                         	0x000000018db15268
-[_UIApplicationCanvas _transitionLifecycleStateWithTransitionContext:
completion:] + 432
18  UIKit                         	0x000000018e5909b8
__125-[_UICanvasLifecycleSettingsDiffAction performActionsForCanvas:
withUpdatedScene:settingsDiff:fromSettings:
transitionContext:]_block_invoke + 220
19  UIKit                         	0x000000018e6deae8
_performActionsWithDelayForTransitionContext + 112
20  UIKit                         	0x000000018db14c88
-[_UICanvasLifecycleSettingsDiffAction performActionsForCanvas:withUpdatedScene:
settingsDiff:fromSettings:transitionContext:] + 248
21  UIKit                         	0x000000018db14624
-[_UICanvas scene:didUpdateWithDiff:transitionContext:completion:] + 368
22  UIKit                         	0x000000018db1165c
-[UIApplication workspace:didCreateScene:withTransitionContext:completion:]
 + 540
23  UIKit                         	0x000000018db113ac
-[UIApplicationSceneClientAgent scene:didInitializeWithEvent:completion:] + 364
24  FrontBoardServices            	0x0000000186778470
-[FBSSceneImpl _didCreateWithTransitionContext:completion:] + 364
25  FrontBoardServices            	0x0000000186780d6c
__56-[FBSWorkspace client:handleCreateScene:withCompletion:]_block_invoke_2 + 224
26  libdispatch.dylib             	0x000000018386cae4
_dispatch_client_callout + 16
27  libdispatch.dylib             	0x00000001838741f4
_dispatch_block_invoke_direct$VARIANT$mp + 224
28  FrontBoardServices            	0x00000001867ac878
__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 36
29  FrontBoardServices            	0x00000001867ac51c
-[FBSSerialQueue _performNext] + 404
30  FrontBoardServices            	0x00000001867acab8
-[FBSSerialQueue _performNextFromRunLoopSource] + 56
31  CoreFoundation                	0x0000000183f23404
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
32  CoreFoundation                	0x0000000183f22c2c
__CFRunLoopDoSources0 + 276
33  CoreFoundation                	0x0000000183f2079c __CFRunLoopRun + 1204
34  CoreFoundation                	0x0000000183e40da8
CFRunLoopRunSpecific + 552
35  GraphicsServices              	0x0000000185e23020 GSEventRunModal + 100
36  UIKit                         	0x000000018de2178c UIApplicationMain + 236
37  icdab_planets                 	0x0000000104e14c94 main + 19604 (main.m:14)
38  libdyld.dylib                 	0x00000001838d1fc0 start + 4

Thread 1:
0   libsystem_pthread.dylib       	0x0000000183b9fb04 start_wqthread + 0

Thread 2:
0   libsystem_kernel.dylib        	0x0000000183a01d84 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08 start_wqthread + 4

Thread 3:
0   libsystem_pthread.dylib       	0x0000000183b9fb04 start_wqthread + 0

Thread 4:
0   libsystem_kernel.dylib        	0x0000000183a01d84 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08 start_wqthread + 4

Thread 5:
0   libsystem_kernel.dylib        	0x0000000183a01d84 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08 start_wqthread + 4

Thread 6 name:  com.apple.uikit.eventfetch-thread
Thread 6:
0   libsystem_kernel.dylib        	0x00000001839dfe08 mach_msg_trap + 8
1   libsystem_kernel.dylib        	0x00000001839dfc80 mach_msg + 72
2   CoreFoundation                	0x0000000183f22e40
__CFRunLoopServiceMachPort + 196
3   CoreFoundation                	0x0000000183f20908 __CFRunLoopRun + 1568
4   CoreFoundation                	0x0000000183e40da8
CFRunLoopRunSpecific + 552
5   Foundation                    	0x00000001848b5674
-[NSRunLoop+ 34420 (NSRunLoop) runMode:beforeDate:] + 304
6   Foundation                    	0x00000001848b551c
-[NSRunLoop+ 34076 (NSRunLoop) runUntilDate:] + 148
7   UIKit                         	0x000000018db067e4
-[UIEventFetcher threadMain] + 136
8   Foundation                    	0x00000001849c5efc
__NSThread__start__ + 1040
9   libsystem_pthread.dylib       	0x0000000183ba1220 _pthread_body + 272
10  libsystem_pthread.dylib       	0x0000000183ba1110 _pthread_body + 0
11  libsystem_pthread.dylib       	0x0000000183b9fb10 thread_start + 4

Thread 7:
0   libsystem_pthread.dylib       	0x0000000183b9fb04 start_wqthread + 0
```

The crash report will explicitly tell us which thread crashed.
```
Thread 0 Crashed:
```

Threads are numbered, and if they have a name we are told this:
```
Thread 0 name:  Dispatch queue: com.apple.main-thread
```

Most of our focus should be on the crashed thread; it is often thread 0.
Take note of the thread name.  Note no long duration tasks such as networking
may be done on the main thread, `com.apple.main-thread`, because that thread
is used to handle user interactions.

The references to `__workq_kernreturn` just indicate a thread waiting for work
so can be ignored unless there are a huge number of them.

Similarly, the reference to `mach_msg_trap` just indicate waiting for a message
to come in.

When looking at stack backtraces, stack frame 0, the top of the stack, comes first, and then calling frames are listed.
Therefore, the last thing being done is in frame 0.  

#### Stack backtrace items

Let us now focus on backtrace items for each thread.  For example:
```
20  UIKit                         	0x000000018db14c88
-[_UICanvasLifecycleSettingsDiffAction performActionsForCanvas:withUpdatedScene:
settingsDiff:fromSettings:transitionContext:] + 248
```

Column number | Meaning
--|--
1 | Stack frame number.  Ordered with 0 is most recently executed.
2 | Binary file executing.
3 | Execution position (frame 0), or return position (frame 1 onwards)
4+ | Symbolic function name or address with offset within the function

The frame numbers, as they could upwards takes us backwards in time in terms of program execution order.  The top of stack, or most recently run code is in frame 0.  One reason for writing code with meaningful function names is that the call stack describes what is going on conceptually.  Lots of small single-purpose functions will serve the needs of both diagnostics and maintainability and are highly recommended.

The second column in a back trace is the binary file.  We focus on our own binary mostly because framework code from Apple is generally very reliable.  Faults usually occur either directly in our code, or by faults caused by incorrect usage of Apple APIs.
Just because the code crashed in Apple provided code does not mean the fault is in Apple code.

The third column, the execution position is slightly tricky.  If it is for frame 0, it is the actual position in the code that was running.  If it is for any later frame, it is the position in the code we shall resume from once the child functions have returned.

The fourth column is the site at which the code is running (for frame 0), or the site which is making a function call (for later frames).  For symbolicated crashes, we will see the symbolic form for the address.  This will include a positional offset from the start of a function to reach the code calling the child function.  If we have only short functions, this offset will be a small value.  It means much less stepping through code, or much less reading through assembly code when performing diagnosis.  That is another reason for keeping our functions short.  If our crash is not symbolicated then we shall just see a memory address value.

Therefore with the example stack frame we have:

- Stack Frame 20.
- UIKit Binary File.
- `0x000000018db14c88` return address after frames 0 - 19 return.
- Call site is 248 bytes from the beginning of class
 `_UICanvasLifecycleSettingsDiffAction` method
 `performActionsForCanvas:withUpdatedScene:
settingsDiff:fromSettings:transitionContext:`

### Crash Report Thread State Section

iOS Crash Reports will be either from ARM-64 binaries (most common) or legacy ARM 32 bit binaries.

In each case we get similar looking information describing the state of the ARM registers.

One thing to look out for is the special hex code, `0xbaddc0dedeadbead` which means a non-initialized pointer.

#### 32-bit thread state

```
Thread 0 crashed with ARM Thread State (32-bit):
    r0: 0x00000000    r1: 0x00000000      r2: 0x00000000      r3: 0x00000000
    r4: 0x00000006    r5: 0x3c42f000      r6: 0x3b66d304      r7: 0x002054c8
    r8: 0x14d5f480    r9: 0x252348fd     r10: 0x90eecad7     r11: 0x14d5f4a4
    ip: 0x00000148    sp: 0x002054bc      lr: 0x257d8733      pc: 0x2572ec5c
  cpsr: 0x00000010
```

#### 64-bit thread state

```
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000028   x1: 0x0000000000000029   x2: 0x0000000000000008   x3: 0x0000000183a4906c
    x4: 0x0000000104440260   x5: 0x0000000000000047   x6: 0x000000000000000a   x7: 0x0000000138819df0
    x8: 0x0000000000000000   x9: 0x0000000000000000  x10: 0x0000000000000003  x11: 0xbaddc0dedeadbead
   x12: 0x0000000000000012  x13: 0x0000000000000002  x14: 0x0000000000000000  x15: 0x0000010000000100
   x16: 0x0000000183b9b8cc  x17: 0x0000000000000100  x18: 0x0000000000000000  x19: 0x00000001b5c241c8
   x20: 0x00000001c0071b00  x21: 0x0000000000000018  x22: 0x000000018e89b27a  x23: 0x0000000000000000
   x24: 0x00000001c4033d60  x25: 0x0000000000000001  x26: 0x0000000000000288  x27: 0x00000000000000e0
   x28: 0x0000000000000010   fp: 0x000000016bde54b0   lr: 0x000000010401ca04
    sp: 0x000000016bde53e0   pc: 0x000000010401c6c8 cpsr: 0x80000000
```


### Crash Report Binary Images section

The crash report has a section enumerating all the binary images loaded by the process that crashed.
It is usually a long list.  It highlights the fact that there are many supporting frameworks for our apps.
Most frameworks are private frameworks.  The iOS development kit might seem a huge set of APIs, but that is just the tip of the iceberg.

Here is an example list, edited for ease of demonstration:

```
Binary Images:

0x104018000 - 0x10401ffff icdab_as arm64
  <b82579f401603481990d1c1c9a42b773>
/var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/icdab_as

0x104030000 - 0x104037fff libswiftCoreFoundation.dylib arm64
  <81f66e04bab133feb3369b4162a68afc>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreFoundation.dylib


0x104044000 - 0x104057fff libswiftCoreGraphics.dylib arm64
  <f1f2287fb5153a28beea12ec2d547bf8>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreGraphics.dylib

0x104078000 - 0x10407ffff libswiftCoreImage.dylib arm64
  <9433fc53f72630dc8c53851703dd440b>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreImage.dylib

0x104094000 - 0x1040cffff dyld arm64
  <06dc98224ae03573bf72c78810c81a78> /usr/lib/dyld
```

The first part is where the image has been loaded into memory.
Here `icdab_as` has been loaded into the range `0x104018000` - `0x10401ffff`

The second part is the UUID of the binary.
Here `icdab_as` has UUID `b82579f401603481990d1c1c9a42b773`

This is important for matching a binary to its DSYM file in the Release Binary
case where the DWARF symbols are stripped out the binary and placed into a
separate DSYM file.

Here is an example of corresponding UUIDs seen in DSYM and application binaries:

```
$ dwarfdump --uuid icdab_as.app/icdab_as
icdab_as.app.dSYM/Contents/Resources/DWARF/icdab_as

UUID: 25BCB4EC-21DE-3CE6-97A8-B759F31501B7 (arm64) icdab_as.app/icdab_as

UUID: 25BCB4EC-21DE-3CE6-97A8-B759F31501B7 (arm64)
icdab_as.app.dSYM/Contents/Resources/DWARF/icdab_as
```
