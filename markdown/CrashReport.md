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

The basic idea is that you install a profile which alters your device to produce more logging, then you reproduce the crash (or get the customer to do that).  Then you press a special key sequence on the device (for example, both volume buttons and the side button).  The system vibrates briefly to indicate it is running a program, `sysdiagnose` which extracts many log files.  Then you use iTunes to sync your device to retrieve the resultant `sysdiagnose_date_name.tar.gz` file.  Inside this archive file are many system and subsystem logs, and you can see when crashes occur and the context that gave rise to them.

## Guided tour of a crash report

Here we go through each section of the crash report and explain the fields. @tn2151

### Header Section

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
