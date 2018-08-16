# Runtime Environment Crashes

In this chapter, we show examples of where the runtime libraries have detected a problem and have caused a crash.

These crashes are distinguished by reporting Exception Type, `EXC_BREAKPOINT (SIGTRAP)`\index{signal!SIGTRAP}

We consider two examples.  Our first example shows how the runtime handles force unwrapping a nil optional.
Our second example shows how the runtime handles releasing a semaphore that is being waited on.
