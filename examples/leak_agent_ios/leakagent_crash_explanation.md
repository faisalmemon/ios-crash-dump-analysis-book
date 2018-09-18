### LeakAgent crash

The `LeakAgent`\index{command!LeakAgent} program is provided by Apple as part of its memory diagnostics\index{memory!diagnostics} tools.  It is used in Xcode Instruments\index{Xcode!Instruments}.

Here is a Crash Report where it has crashed, truncated for ease of demonstration:

```
Incident Identifier: 11ED1987-1BC9-4F44-900C-AD07EE6F7E26
CrashReporter Key:   b544a32d592996e0efdd7f5eaafd1f4164a2e13c
Hardware Model:      iPad6,3
Process:             LeakAgent [3434]
Path:                /Developer/Library/PrivateFrameworks/
DVTInstrumentsFoundation.framework/LeakAgent
Identifier:          LeakAgent
Version:             ???
Code Type:           ARM-64 (Native)
Role:                Unspecified
Parent Process:      DTServiceHub [1592]
Coalition:           com.apple.instruments.deviceservice [463]


Date/Time:           2018-07-19 14:16:57.6977 +0100
Launch Time:         2018-07-19 14:16:56.7734 +0100
OS Version:          iPhone OS 11.3 (15E216)
Baseband Version:    n/a
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
VM Region Info: 0 is not in any region.
  Bytes before following region: 4371873792
      REGION TYPE                      START - END
                   [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                 0000000104958000-0000000104964000
       [   48K] r-x/r-x SM=COW  ...ork/LeakAgent

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [0]
Triggered by Thread:  4

Thread 4 name:  Dispatch queue: DTXChannel serializer queue [x1.c0]
Thread 4 Crashed:
0   libswiftDemangle.dylib        	
0x0000000104f871dc 0x104f70000 + 94684
1   libswiftDemangle.dylib        	
0x0000000104f8717c 0x104f70000 + 94588
2   libswiftDemangle.dylib        	
0x0000000104f86200 0x104f70000 + 90624
3   libswiftDemangle.dylib        	
0x0000000104f84948 0x104f70000 + 84296
4   libswiftDemangle.dylib        	
0x0000000104f833a4 0x104f70000 + 78756
5   libswiftDemangle.dylib        	
0x0000000104f73290 0x104f70000 + 12944
6   CoreSymbolication             	
0x000000019241d638 demangle + 112
7   CoreSymbolication             	
0x00000001923d16cc
 TRawSymbol<Pointer64>::name+ 54988 () + 72
8   CoreSymbolication             	
0x0000000192404ff4
 TRawSymbolOwnerData<Pointer64>::
 symbols_for_name(CSCppSymbolOwner*, char const*,
    void + 266228 (_CSTypeRef) block_pointer) + 156
9   CoreSymbolication             	
0x00000001923d9734
 CSSymbolOwnerGetSymbolWithName + 116
10  Symbolication                 	
0x000000019bb2e7f4
 -[VMUObjectIdentifier _targetProcessSwiftReflectionVersion] + 120
11  Symbolication                 	
0x000000019bb2f9d8
 -[VMUObjectIdentifier loadSwiftReflectionLibrary] + 36
12  Symbolication                 	
0x000000019bb29ff0
 -[VMUObjectIdentifier initWithTask:symbolicator:scanner:] + 436
13  Symbolication                 	
0x000000019baede10
 -[VMUTaskMemoryScanner _initWithTask:options:] + 2292
14  Symbolication                 	
0x000000019baee304
 -[VMUTaskMemoryScanner initWithTask:options:] + 72
15  LeakAgent                     	
0x000000010495b270 0x104958000 + 12912
16  CoreFoundation                	
0x0000000183f82580 __invoking___ + 144
17  CoreFoundation                	0x0000000183e61748
 -[NSInvocation invoke] + 284
18  DTXConnectionServices         	
0x000000010499f230 0x104980000 + 127536
19  DTXConnectionServices         	
0x00000001049947a4 0x104980000 + 83876
20  libdispatch.dylib             	0x000000018386cb24
 _dispatch_call_block_and_release + 24
21  libdispatch.dylib             	0x000000018386cae4
 _dispatch_client_callout + 16
22  libdispatch.dylib             	0x0000000183876a38
 _dispatch_queue_serial_drain$VARIANT$mp + 608
23  libdispatch.dylib             	0x0000000183877380
 _dispatch_queue_invoke$VARIANT$mp + 336
24  libdispatch.dylib             	0x0000000183877d4c
 _dispatch_root_queue_drain_deferred_wlh$VARIANT$mp + 340
25  libdispatch.dylib             	0x000000018388011c
 _dispatch_workloop_worker_thread$VARIANT$mp + 668
26  libsystem_pthread.dylib       	0x0000000183b9fe70
 _pthread_wqthread + 860
27  libsystem_pthread.dylib       	
0x0000000183b9fb08 start_wqthread + 4

Thread 4 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   
    x2: 0xfffffffffffffff6
       x3: 0x0000000000000041
    x4: 0x0000000000000000   x5: 0x0000000104f97950   
    x6: 0x0000000000000006
       x7: 0x00000000ffffffff
    x8: 0x00000001050589d0   x9: 0x0000000104f840d8  
    x10: 0xffffffffffffd544
      x11: 0x0000000000000a74
   x12: 0x0000000000000002  x13: 0x00000000000002aa  
   x14: 0x00000000000002aa
     x15: 0x00000000000003ff
   x16: 0x0000000183b96360  x17: 0x0000000000200000  
   x18: 0x0000000000000000
     x19: 0x000000016b6d1ba0
   x20: 0x00000001050589a0  x21: 0x0000000000000000  
   x22: 0x0000000000000000
     x23: 0x0000000000000001
   x24: 0x00000000ffffffff  x25: 0x0000000000000006  
   x26: 0x0000000104f97950
     x27: 0x0000000000000000
   x28: 0x0000000000000009   fp: 0x000000016b6d19c0   
   lr: 0x0000000104f8717c
    sp: 0x000000016b6d1930   pc: 0x0000000104f871dc
    cpsr: 0x60000000
```

We can see that the kernel address at fault is `0x0000000000000000` so it's a NULL pointer dereference.
The call site where we crash is a Swift library that demangles\index{Swift!symbol demangle} symbols.  The Xcode instrument is trying to provide human readable object type definitions from the activity it has seen on the iPad.

If we were the user trying to profile our app, and hit this bug in the `LeakAgent`, we would need to try and figure out a way to avoid the problem.

Since the problem is due to symbolification\index{symbolification}, it may be wise to clear our build directory and then do a clean build.  Sometimes an Xcode update switches us to a new object file format that is incompatible.  It is worthwhile checking profiling with another project, perhaps a trivial test program.  There are alternative memory analysis facilities, such as the Diagnostics Tab for the scheme we are running,
so memory analysis\index{memory!diagnostics} could be done in a different way.  See the later chapter, Memory Diagnostics, for further information.
