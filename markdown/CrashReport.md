# The Crash Report

In this chapter we get into the details of what comprises a crash report.
Our main focus is the iOS crash report.  We also cover the macOS crash report,
which caries a slightly different structure but serves the same purpose.

When a crash occurs the `ReportCrash` program extracts information from the crashing process from the Operating System.  The result is a text file with a `.crash` extension.

When symbol information is available, Xcode will symbolicate the crash report to show symbolic names instead of machine addresses.  This improves the comprehensibility of the report.

Apple have a detailed document explaining the anatomy of a crash dump.  @tn2151

## System Diagnostics

Crash Reports are just one part of a much bigger diagnostic reporting story.

Ordinarily as application developers we don't need to look much further.  However, if your problems are potentially triggered by a unexplained series of events or a more complex system interaction with hardware or Apple provided system services, then not only do you need to look at your crash reports, you need to study the system diagnostics.

### Extracting System Diagnostic Information
When understanding the environment that gave rise to your crash, you may need to install Mobile Device Management Profiles (to switch on certain debugging subsystems), or create virtual network interfaces (for network sniffing).  Apple have a great web page covering each scenario.  @apple-sysdiag  

On iOS, the basic idea is that you install a profile which alters your device to produce more logging, then you reproduce the crash (or get the customer to do that).  Then you press a special key sequence on the device (for example, both volume buttons and the side button).  The system vibrates briefly to indicate it is running a program, `sysdiagnose` which extracts many log files.  Then you use iTunes to sync your device to retrieve the resultant `sysdiagnose_date_name.tar.gz` file.  Inside this archive file are many system and subsystem logs, and you can see when crashes occur and the context that gave rise to them.

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

The first thing to look at is the version.  Typically if you are a small team or individual, you will not have the resources to diagnose crashes in older versions of your app, so the first thing might be to get the customer to install the latest version.

If you have got a lot of crashes then you might see it being a problem to one customer (common CrashReporter key seen) or lots of customers (so different CrashReporter keys are seen).  This may affect how you rank the priority of the crash.

The hardware model could be interesting.  It is iPad only devices, or iPhone only, or both?
Maybe your code has less testing or unique code paths for a given platform.

The hardware model might indicate an older device, which we have not tested on.

Whether the app crashed in the Foreground or Background (the Role) is interesting because most applications are not tested when they are backgrounded.  For example, you might receive a phone call, or have task switched between apps.

The Code Type (target architecture) is now mostly 64-bit ARM.  But you might see ARM being reported - the original 32-bit ARM.

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

Normally the baseband version is not interesting.  The presence of the baseband means you could get interrupted by a phone call (of course there is VOIP calling as well in any case).  iPad software is generally written to assume you're not going to get a phone call but iPads can be purchased with a cellular modem option.

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
`EXC_CRASH (SIGKILL)` |The system killed your app (or app extension), usually because some resource limit had been reached.  The Termination Reason needs to be looked at to work out what policy violation was the reason for termination.
`EXC_BAD_ACCESS` or `SIGSEGV` or `SIGBUS` |Our program most likely tried to access a bad memory location or the address was good but we did not have the privilege to access it.  The memory might have been deallocated due to due memory pressure.
`EXC_BREAKPOINT (SIGTRAP)` |This is due to an `NSException` being raised (possibly by a library on your behalf) or `_NSLockError` or `objc_exception_throw` being called.  For example, this can be the Swift environment detecting an anomaly such as force unwrapping a nil optional
EXC_BAD_INSTRUCTION (SIGILL)|This is when the program code itself is faulty, not the memory it might be accessing.  This should be rare on iOS devices; a compiler or optimiser bug, or faulty hand written assembly code.  On Simulator it is a different story as using an undefined opcode is a technique used by the Swift runtime to stop on access to zombie objects (deallocated objects).

When Termination Reason is present, we can look up the Code as follows:

Termination Code | Spoken As | Meaning
--|--
`0xdead10cc`  | Deadlock |We held a file lock or sqlite database lock before suspending.  We should release locks before suspending.
`0xbaaaaaad` | Bad | A stackshot was done of the entire system via the side and both volume buttons.  See earlier section on System Diagnostics
`0xbad22222` | Bad too (two) many times | VOIP was terminated as it resumed too frequently.  Also see with code using networking whilst in the background.  If your TCP connection is woken up too many times (say 15 wakes in 300 seconds) you get this crash.
`0x8badf00d` | Ate (eight) bad food | Our app took too long to perform a state change (starting up, shutting down, handling system message, etc.).  The watchdog timer noticed the policy violation and caused the termination.  The most common culprit is doing synchronous networking on the main thread.
`0xc00010ff` | Cool Off | The system detected a thermal event and kill off your app.  If it's just one device it could be a hardware issue, not a software problem in your app.  If it happens on other devices, check your app's power usage using Instruments.
`0x2bad45ec` | Too bad for security | There was a security violation. If the Termination Description says "Process detected doing insecure drawing while in secure mode" it means your app tried to write to the screen when it was not allowed because for example the Lock Screen was being shown.
#### Aborts
When we have a `SIGABRT` , we should look for what exceptions and assertions are present in our code from the stack trace of the crashed thread.

#### Memory Issues
When we have a memory issue, `EXC_BAD_ACCESS` , `SIGSEGV` or `SIGBUS`.  The faulty memory reference is the second number of the Exception Codes number pair.  For this type of problem, the diagnostics settings within Xcode for the target in the schema are relevant.  The address sanitiser should be switched on to see if it can spot the error.  If that cannot detect the issue, try each of the memory management settings, one at a time.

If Xcode shows a lot of memory is being used by the app, then it might be that memory we were relying upon has been freed by the system.  For this, switch on the Malloc Stack logging option, selecting All Allocation and Free History.  Then at some point during the app, the MemGraph button can be clicked, and then the allocation history of objects explored.

#### Exceptions
When we have a `EXC_BREAKPOINT` it can seem confusing.  The program may have been running standalone without a debugger so where did the breakpoint come from?  Typically we are running `NSException` code.  This will make the system signal the process with the trace trap signal and this makes any available debugger attach to the process to aid debugging.  So in the case where we were running the app under the debugger, even with breakpoints switched off, we would breakpoint in here so we can find out why there was a runtime exception.  In the case of normal app running, there is no debugger so we would just crash the app.

#### Illegal Instructions
When we have a `EXC_BAD_INSTRUCTION` , the exception codes (second number) will be the problematic assembly code.  This should be a rare condition.  It is worthwhile adjusting the optimisation level of the code at fault in the Build Settings because higher level optimisations can cause more exotic instructions to be emitted during build time, and hence a bigger chance for a compiler bug.  Alternatively the problem might be a lower level library which has hand assembly optimisations in it - such as a multimedia library.  Handwritten assembly can be the cause of bad instructions.
