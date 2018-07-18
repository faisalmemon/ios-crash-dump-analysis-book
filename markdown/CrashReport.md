# The Crash Report

When a crash occurs the `ReportCrash` program extracts information from the crashing process from the Operating System.  The result is a text file with a `.crash` extension.

When symbol information is available, Xcode will symbolicate the crash report to show symbolic names instead of machine addresses.  This improves the comprehensibility of the report.

Apple have a detailed document explaining the anatomy of a crash dump.  @tn2151

## System Diagnostics

Note that Crash Reports are just one part of a much bigger diagnostic reporting story.
Ordinarily as application developers we don't need to look much further.  However, if your problems are potentially triggered by a unexplained series of events or a more complex system interaction with hardware or Apple provided system services, then not only do you need to look at your crash reports, you need to study the system diagnostics.

### Extracting System Diagnostic Information
When understanding the environment that gave rise to your crash, you may need to install Mobile Device Management Profiles (to switch on certain debugging subsystems), or create virtual network interfaces (for network sniffing).  Apple have a great web page covering each scenario.  @apple-sysdiag  

The basic idea is that you install a profile which alters your device to produce more logging, then you reproduce the crash (or get the customer to do that).  Then you press a special key sequence on the device (for example, both volume buttons and the side button).  The system vibrates briefly to indicate it is running a program, `sysdiagnose` which extracts many log files.  Then you use iTunes to sync your device to retrieve the resultant `sysdiagnose_date_name.tar.gz` file.  Inside this archive file are many system and subsystem logs, and you can see when crashes occur and the context that gave rise to them.

## Guided tour of a crash report
