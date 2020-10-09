# Failed Crashes

In this chapter we discuss _Failed_ Crashes.  That is those crashes which did not end up with a proper crash report returned to us.
Sometimes this happens due to the third party crash reporting framework we might have linked to our binary that crashed.  In this chapter we focus on first party reasons for failed crashes, and explain some scenarios that can be the cause.

## Signal handling failures

When a program is being debugged, it is conceptually in a similar state to when it is crashed.  That is because we want to go into the process and inspect its state (or potentially change the program by inserting breakpoints).  In iOS 13.5 (fixed in iOS 14.x), there is a glitch where if an application tells the Operating System it is expecting to be debugged, then when the system wants to kill it off as a result of a crash 
it finds that it cannot kill the app.  Instead, the entire platform jams up and needs a reset.

If we have an application we has some anti-reverse engineering, or anti-debugging functionality, perhaps through framework, we might end up in this situation because making an app pretend it is already being debugged is a common technique to preventing a debugger attaching.

The application `icdab_pt` demonstrates the problem.  @icdabgithub

```
#define SIZE 4096
#define SHM_NAME "map-jit-memory"

#define PT_TRACE_ME 0
int ptrace(int, pid_t, caddr_t, int); // private method

+ (void)crashThenStallCrashReporting:(BOOL)stall {
    int fd = open(SHM_NAME, O_RDWR | O_CREAT, 0666);
    int result = ftruncate(fd, SIZE);
    
    // we are not privileged so this will not be successful
    void *buf1 = mmap(0,
                      SIZE,
                      PROT_READ | PROT_WRITE,
                      MAP_JIT,
                      fd,
                      0);
    
    if (stall) {
        ptrace(PT_TRACE_ME, 0, NULL, 0);
    }
    
    // trigger crash by accessing a bad buffer
    strcpy(buf1, "Modified buffer");
    
    result = munmap(buf1, SIZE);
    result = shm_unlink(SHM_NAME);
}
```

The above code causes the same disruption to crash reporting on a simulator as it does on target hardware.
For the sake of convenience, we focus on the simulator target as it is easy to reset, and to compare different OS versions.

When we run on iOS 13.5\index{iOS!13.5} we find that the system hangs when passed in `YES`, but crashes properly when passed `NO`.  On iOS 14.x\index{iOS!14.x} we immediately get a crash in both circumstances.

For more background information, see @jitios.
