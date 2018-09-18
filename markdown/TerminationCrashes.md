# Application Termination Crashes

In this chapter, we study application termination crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_CRASH (SIGKILL)`\index{signal!SIGKILL} in their Crash Report.

An application can be designed to catch signals sent to it.  Typically in UNIX\index{trademark!UNIX} systems, server processes, called daemons, are designed to catch the SIGHUP\index{signal!SIGHUP} signal.  When it is received, the process would re-read its configuration file.

However, some signals, by design, cannot be caught.  These are the SIGSTOP\index{signal!SIGSTOP} and SIGKILL\index{signal!SIGKILL} signals.
