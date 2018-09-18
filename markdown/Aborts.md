# Application Abort Crashes

In this chapter, we study application abort crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_CRASH (SIGABRT)`\index{signal!SIGABRT} in their Crash Report.

We look at a range of crashes obtained by searching the Internet.

## General principles

Many Operating System language support modules, and libraries, have code to detect fatal programming errors.
In such circumstances, the application requests that the Operating System terminate the app.  This gives rise to a `SIGABRT` crash.

There is not one particular reason for `SIGABRT`.  Instead, we look at a variety of examples so that we can see the kinds of situation where they arise.

Sometimes the particular abort also supplies information in the `Application Specific Information` area of the Crash Report.  If this does not reveal the details we require, it is often possible to locate the module that raised the abort, and reverse engineer the code to understand what specifically was the syndrome.
