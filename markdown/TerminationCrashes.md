# Application Termination Crashes

In this chapter, we study application termination crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_CRASH (SIGKILL)`\index{signal!SIGKILL} in their Crash Report.

An application can be designed to catch signals sent to it.  Typically in UNIX\index{trademark!UNIX} systems, when a SIGHUP\index{signal!SIGHUP} was sent it would make the program re-read its configuration file, by convention.  By design, SIGSTOP and SIGKILL signals cannot be caught.
