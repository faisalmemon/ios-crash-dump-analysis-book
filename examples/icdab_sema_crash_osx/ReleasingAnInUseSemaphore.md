## Releasing a semaphore that is in use

The `libdispatch` library\index{software!runtime library} has support for identifying runtime issues.
When such problems arise, the app is crashed with Exception Type, `EXC_BREAKPOINT (SIGTRAP)`

We use the `icdab_sema` example program to demonstrate a crash detected by `libdispatch` for the faulty use of semaphores\index{semaphore}. @icdabgithub

The `libdispatch`\index{command!libdispatch} library is the operating system library for managing concurrency (known as Grand Central Dispatch or GCD)\index{Grand Central Dispatch}.  The library is available as Open Source from Apple.  @libdispatchtar

The library abstracts away the details of how the Operating System provides access to multi-core\index{operating system!multi-core}  CPU resources.  During a crash, it supplies extra information to the crash report.  This means that if we wish to do so, we can find the code that detected the runtime issue.

### Crash example releasing a semaphore

The `icdab_sema` example program results in a crash upon launch.
The crash report is as follows (truncated for ease of demonstration):

```
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x00000001814076b8
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
Terminating Process: exc handler [0]
Triggered by Thread:  0

Application Specific Information:
BUG IN CLIENT OF LIBDISPATCH: Semaphore object deallocated while in use
Abort Cause 1

Filtered syslog:
None found

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libdispatch.dylib             	0x00000001814076b8
 _dispatch_semaphore_dispose$VARIANT$mp + 76
1   libdispatch.dylib             	0x00000001814067f0
 _dispatch_dispose$VARIANT$mp + 80
2   icdab_sema_ios                	0x00000001006ea98c
 use_sema + 27020 (main.m:18)
3   icdab_sema_ios                	0x00000001006ea9bc
 main + 27068 (main.m:22)
4   libdyld.dylib                 	0x0000000181469fc0
 start + 4

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x00000001c409df10   x1: 0x000000016f71ba4f
       x2: 0xffffffffffffffe0   x3: 0x00000001c409df20
    x4: 0x00000001c409df80   x5: 0x0000000000000044
       x6: 0x000000018525c984   x7: 0x0000000000000400
    x8: 0x0000000000000001   x9: 0x0000000000000000
      x10: 0x000000018140766c  x11: 0x000000000001dc01
   x12: 0x000000000001db00  x13: 0x0000000000000001
     x14: 0x0000000000000000  x15: 0x0001dc010001dcc0
   x16: 0x000000018140766c  x17: 0x0000000181404b58
     x18: 0x0000000000000000  x19: 0x00000001b38f4c80
   x20: 0x0000000000000000  x21: 0x0000000000000000
     x22: 0x00000001c409df10  x23: 0x0000000000000000
   x24: 0x0000000000000000  x25: 0x0000000000000000
     x26: 0x0000000000000000  x27: 0x0000000000000000
   x28: 0x000000016f71bb18   fp: 0x000000016f71ba70
      lr: 0x00000001814067f0
    sp: 0x000000016f71ba40   pc: 0x00000001814076b8
     cpsr: 0x80000000
```

### Faulty semaphore code

The code to reproduce the semaphore problem is based upon an Xcode project that uses Manual Reference Counting (MRC)\index{Objective-C!manual reference counting}.  This is a legacy setting but one that can be encountered whilst integrating with legacy code bases.  At the project level, it is option "Objective-C Automatic Reference Counting"\index{Xcode!ARC setting} set to NO.  This allows us to then make direct calls to the `dispatch_release`\index{command!dispatch release} API.

The code is as follows:

```
#import <Foundation/Foundation.h>

void use_sema() {
    dispatch_semaphore_t aSemaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore, DISPATCH_TIME_FOREVER);
    // dispatch_semaphore_signal(aSemaphore);
    dispatch_release(aSemaphore);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        use_sema();
    }
    return 0;
}
```

### Using application specific crash report information

In our example, the `Application Specific Information` section of the crash report directly explains the problem.

```
BUG IN CLIENT OF LIBDISPATCH: Semaphore object deallocated while in use
```

We just need to signal the semaphore to avoid the problem.

If we had a more unusual problem or wanted to understand it at a deeper level, we could look up the source code of the library and find the diagnostic message in the code.

Here is the relevant library code:

```
void
_dispatch_semaphore_dispose(dispatch_object_t dou,
		DISPATCH_UNUSED bool *allow_free)
{
	dispatch_semaphore_t dsema = dou._dsema;

	if (dsema->dsema_value < dsema->dsema_orig) {
		DISPATCH_CLIENT_CRASH(dsema->dsema_orig - dsema->dsema_value,
				"Semaphore object deallocated while in use");
	}

	_dispatch_sema4_dispose(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);
}
```

Here we can see the library causing a crash through the `DISPATCH_CLIENT_CRASH` macro.

### Semaphore Crash Lessons Learnt

Manual Reference Counting\index{Objective-C!manual reference counting} should be avoided in modern application code.

When crashes occur via runtime libraries\index{software!runtime library}, we need to go back to the API specification to find out how we are violating the API contract that resulted in a crash.  The Application Specific Information in the Crash Report should help focus our attention when re-reading the API document, studying working sample code, and looking into the detail level of the source code of the runtime library (when available).

Where MRC\index{Objective-C!manual reference counting} code has been carried forwards from a legacy code base, a design pattern should be used to wrap the code that is MRC based, and offer a clean API into it.  Then the rest of the program can use Automatic Reference Counting\index{Objective-C!automatic reference counting} (ARC).  This will contain the problem, and allow the new code to benefit from ARC.  It is possible also to mark specific files as being MRC.  The compiler flag option, `-fno-objc-arc`, needs to be set for the file.  It is found within _Build Phases -> Compile Sources_ area of Xcode.

If the legacy\index{software!legacy} code does not need enhancement, it is best to leave it alone, and just wrap it with a facade\index{software!facade} API. We can then write some test cases for that API.  Code that is not actively updated tends to only give rise to bugs when it is used in new ways.  Sometimes the staff with knowledge of legacy code has left the project, so making updates can be risky by less knowledgeable staff.

It is great if legacy\index{software!legacy} code can be replaced over time.  Normally a business justification is needed.  One strategy is to break down a legacy module into smaller pieces.  If this is done strategically, then one of the smaller pieces can be re-worked, with modern coding practices.  It becomes a win-win when such a module is enhanced to solve a new customer need as well.
