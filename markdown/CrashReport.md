# The Crash Report

In this chapter we get into the details of what comprises a crash report.
Our main focus is the iOS crash report.  We also cover the macOS crash report,
which caries a slightly different structure but serves the same purpose.

When a crash occurs the `ReportCrash` program extracts information from the crashing process from the Operating System.  The result is a text file with a `.crash` extension.

When symbol information is available, Xcode will symbolicate the crash report to show symbolic names instead of machine addresses.  This improves the comprehensibility of the report.

Apple have a detailed document explaining the anatomy of a crash dump.  @tn2151

## System Diagnostics

Crash Reports are just one part of a much bigger diagnostic reporting story.

Ordinarily as application developers we don't need to look much further.  However, if our problems are potentially triggered by a unexplained series of events or a more complex system interaction with hardware or Apple provided system services, then not only do we need to look at our crash reports, we need to study the system diagnostics.

### Extracting System Diagnostic Information
When understanding the environment that gave rise to our crash, we may need to install Mobile Device Management Profiles (to switch on certain debugging subsystems), or create virtual network interfaces (for network sniffing).  Apple have a great web page covering each scenario.  @apple-sysdiag  

On iOS, the basic idea is that we install a profile which alters our device to produce more logging, then we reproduce the crash (or get the customer to do that).  Then we press a special key sequence on the device (for example, both volume buttons and the side button).  The system vibrates briefly to indicate it is running a program, `sysdiagnose` which extracts many log files.  Then we use iTunes to sync our device to retrieve the resultant `sysdiagnose_date_name.tar.gz` file.  Inside this archive file are many system and subsystem logs, and we can see when crashes occur and the context that gave rise to them.

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
Identifier|Bundle identifier from `Info.plist`
Version|CFBundleVersion; also CFBundleVersionString in brackets
Code Type|Target architecture of the process that crashed
Role|The process `task_role`.  An indicator if we were in the background, foreground, or was a console app.  Mainly affects the scheduling priority of the process.
Parent Process|Which process created the crashing process. `launchd` is a process launcher and is often the parent.
Coalition|Tasks are grouped into coalitions so they can pool together their consumption of resources @resource-management

The first thing to look at is the version.  Typically if we are a small team or an individual, we will not have the resources to diagnose crashes in older versions of our app, so the first thing might be to get the customer to install the latest version.

If we have got a lot of crashes then we might see it being a problem to one customer (common CrashReporter key seen) or lots of customers (so different CrashReporter keys are seen).  This may affect how we rank the priority of the crash.

The hardware model could be interesting.  It is iPad only devices, or iPhone only, or both?
Maybe our code has less testing or unique code paths for a given platform.

The hardware model might indicate an older device, which we have not tested on.

Whether the app crashed in the Foreground or Background (the Role) is interesting because most applications are not tested when they are backgrounded.  For example, we might receive a phone call, or have task switched between apps.

The Code Type (target architecture) is now mostly 64-bit ARM.  But we might see ARM being reported - the original 32-bit ARM.

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

Normally the baseband version is not interesting.  The presence of the baseband means we could get interrupted by a phone call (of course there is VOIP calling as well in any case).  iPad software is generally written to assume we're not going to get a phone call but iPads can be purchased with a cellular modem option.

### Crash Report Exception Section

A Crash Report will next have exception information:

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

What has happened is that the MachOS kernel has raised an Operating System Exception on the problematic process, which terminates the process.  The ReportCrash program then retrieves from the OS details of such an exception.

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
`EXC_CRASH (SIGQUIT)` |A process received a quit signal from another process that is managing it.  Typically this means a Keyboard extension took too long or used up too much memory.  App extensions are only only limited amounts of memory.
`EXC_CRASH (SIGKILL)` |The system killed our app (or app extension), usually because some resource limit had been reached.  The Termination Reason needs to be looked at to work out what policy violation was the reason for termination.
`EXC_BAD_ACCESS` or `SIGSEGV` or `SIGBUS` |Our program most likely tried to access a bad memory location or the address was good but we did not have the privilege to access it.  The memory might have been deallocated due to due memory pressure.
`EXC_BREAKPOINT (SIGTRAP)` |This is due to an `NSException` being raised (possibly by a library on our behalf) or `_NSLockError` or `objc_exception_throw` being called.  For example, this can be the Swift environment detecting an anomaly such as force unwrapping a nil optional
EXC_BAD_INSTRUCTION (SIGILL)|This is when the program code itself is faulty, not the memory it might be accessing.  This should be rare on iOS devices; a compiler or optimiser bug, or faulty hand written assembly code.  On Simulator it is a different story as using an undefined opcode is a technique used by the Swift runtime to stop on access to zombie objects (deallocated objects).

When Termination Reason is present, we can look up the Code as follows:

Termination Code | Spoken As | Meaning
--|--|--
`0xdead10cc`  | Deadlock |We held a file lock or sqlite database lock before suspending.  We should release locks before suspending.
`0xbaaaaaad` | Bad | A stackshot was done of the entire system via the side and both volume buttons.  See earlier section on System Diagnostics
`0xbad22222` | Bad too (two) many times | VOIP was terminated as it resumed too frequently.  Also see with code using networking whilst in the background.  If our TCP connection is woken up too many times (say 15 wakes in 300 seconds) we get this crash.
`0x8badf00d` | Ate (eight) bad food | Our app took too long to perform a state change (starting up, shutting down, handling system message, etc.).  The watchdog timer noticed the policy violation and caused the termination.  The most common culprit is doing synchronous networking on the main thread.
`0xc00010ff` | Cool Off | The system detected a thermal event and kill off our app.  If it's just one device it could be a hardware issue, not a software problem in our app.  If it happens on other devices, check our app's power usage using Instruments.
`0x2bad45ec` | Too bad for security | There was a security violation. If the Termination Description says "Process detected doing insecure drawing while in secure mode" it means our app tried to write to the screen when it was not allowed because for example the Lock Screen was being shown.
#### Aborts
When we have a `SIGABRT` , we should look for what exceptions and assertions are present in our code from the stack trace of the crashed thread.

#### Memory Issues
When we have a memory issue, `EXC_BAD_ACCESS` , `SIGSEGV` or `SIGBUS`.  The faulty memory reference is the second number of the Exception Codes number pair.  For this type of problem, the diagnostics settings within Xcode for the target in the schema are relevant.  The address sanitiser should be switched on to see if it can spot the error.  If that cannot detect the issue, try each of the memory management settings, one at a time.

If Xcode shows a lot of memory is being used by the app, then it might be that memory we were relying upon has been freed by the system.  For this, switch on the Malloc Stack logging option, selecting All Allocation and Free History.  Then at some point during the app, the MemGraph button can be clicked, and then the allocation history of objects explored.

#### Exceptions
When we have a `EXC_BREAKPOINT` it can seem confusing.  The program may have been running standalone without a debugger so where did the breakpoint come from?  Typically we are running `NSException` code.  This will make the system signal the process with the trace trap signal and this makes any available debugger attach to the process to aid debugging.  So in the case where we were running the app under the debugger, even with breakpoints switched off, we would breakpoint in here so we can find out why there was a runtime exception.  In the case of normal app running, there is no debugger so we would just crash the app.

#### Illegal Instructions
When we have a `EXC_BAD_INSTRUCTION` , the exception codes (second number) will be the problematic assembly code.  This should be a rare condition.  It is worthwhile adjusting the optimisation level of the code at fault in the Build Settings because higher level optimisations can cause more exotic instructions to be emitted during build time, and hence a bigger chance for a compiler bug.  Alternatively the problem might be a lower level library which has hand assembly optimisations in it - such as a multimedia library.  Handwritten assembly can be the cause of bad instructions.

### Crash Report Filtered Syslog Section

The Crash Report continues with the syslog section:

```
Filtered syslog:
None found
```

This is an anomalous section because it is supposed to look at the process ID of the crashed process and then look to see if there are any syslog (System Log) entries for that process.  We have never seen filtered entries in a crash, and only see `None found` reported.

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

Similarly the reference to `mach_msg_trap` just indicate waiting for a message
to come in.

When looking at stack backtraces, stack frame 0, the top of the stack, comes first, and then calling frames are listed.
So the last thing being done is in frame 0.  The frame number is the first number in the stack backtrace line for a given thread.
The second frame, numbered 1, is code that called the function being executed in stack frame 0.  This repeats until reach the original code that was running when the thread commenced.

The second column in a back trace is the binary file.  We focus on our own binary mostly because framework code from Apple is generally very reliable.  Faults usually occur either directly in our code, or by faults caused by incorrect usage of Apple APIs.
Just because the code crashed in Apple provided code does not mean the fault is in Apple code.

The fourth column onwards is the address in memory after the code from the higher up stacks would leave the program once they have returned to the particular stack frame in question.  If in our binary, and our
libraries we do not see a symbolic address, but just hex offsets, then we have
not got a symbolicated crash report.  See earlier chapter on Symbolification.

The fifth column is the calling function relative to the parent function it is in.  The plus sign followed by an offset tells us how far into the parent function the call to the next function is.

Therefore with the example stack frame:
```
20  UIKit                         	0x000000018db14c88
-[_UICanvasLifecycleSettingsDiffAction performActionsForCanvas:withUpdatedScene:
settingsDiff:fromSettings:transitionContext:] + 248
```

We see :
