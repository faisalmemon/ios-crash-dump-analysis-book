# The Crash Report

In this chapter we get into the details of what comprises a crash report.

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

The Code Type (target architecture) is now mostly 64-bit ARM.  But you might see ARM being reported - the original 32-bit ARM.  There could be a 64-bit specific issue.

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

What has happened is that the MachOS kernel has raised an Operating System Exception on the problematic process, which terminates the process.  The ReportCrash program then retrieves from the OS details of such an exception.

These items are explained by the following table:

Entry|Meaning
--|--
Exception Type|The type of exception in Mach OS. @exception-types
Exception Codes|These codes encode the kind of exception, such as trying to trying to access an invalid address, and supporting information.  @exception-types
Exception Note|Either this says `SIMULATED (this is NOT a crash)` because the process will killed by the watchdog timer, or it says `EXC_CORPSE_NOTIFY` because the process crashed
Triggered by Thread|The thread in the process that caused the crash


In this section the most important item is the exception type.

Exception Type|Meaning
--|--
EXC_CRASH (SIGABRT)|Our program raised a programming language exception such as a failed assertion and this caused the OS to Abort our app
EXC_BAD_ACCESS or SIGSEGV or SIGBUS|Our program most likely tried to access a bad memory location or alternatively the address was good but we did not have the privilege to access it.

When we have a SIGABRT, we should look for what exceptions and assertions are present in our code from the stack trace of the crashed thead.

When we have a memory issue, we should look at what was the address at fault.  Note the CR2 register described in a later section carries the address which caused the problem.  For making progress on these issues, we should use the Xcode Diagnostics options for memory debugging.  There is an option to switch on the Address Sanitiser.  If this does not catch the problem, it is then trying the 
