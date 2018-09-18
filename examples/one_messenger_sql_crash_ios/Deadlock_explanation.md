## Deadlock Crash

If a SQLite file is locked before an app suspends, the app is crashed.  A Deadlock Termination Reason is supplied in the Crash Report.

As an example we show the OneMessenger app crash with the following Crash Report, truncated for ease of demonstration:

```
Incident Identifier: A176CFB8-6BB7-4515-A4A2-82D2B962E097
CrashReporter Key:   f02957b828fe4090389c1282ca8e38393b4e133d
Hardware Model:      iPhone9,4
Process:             OneMessenger [10627]
Path:                /private/var/containers/Bundle/Application/
03E067E9-E2C1-43F4-AC53-4E4F58131FF3/OneMessenger.app/OneMessenger
Identifier:          com.onem.adhoc
Version:             158 (1.0.4)
Code Type:           ARM-64 (Native)
Role:                Non UI
Parent Process:      launchd [1]
Coalition:           com.onem.adhoc [3747]


Date/Time:           2017-05-10 17:37:48.6201 -0700
Launch Time:         2017-05-10 17:37:46.7161 -0700
OS Version:          iPhone OS 10.3.1 (14E304)
Report Version:      104

Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace SPRINGBOARD, Code 0xdead10cc
Triggered by Thread:  0

Thread 0 name:
Thread 0 Crashed:
0   libsystem_kernel.dylib          0x000000018a337224
 mach_msg_trap + 8
1   libsystem_kernel.dylib          0x000000018a33709c
 mach_msg + 72 (mach_msg.c:103)
2   CoreFoundation                  0x000000018b308e88
 __CFRunLoopServiceMachPort + 192 (CFRunLoop.c:2527)
3   CoreFoundation                  0x000000018b306adc
 __CFRunLoopRun + 1060 (CFRunLoop.c:2870)
4   CoreFoundation                  0x000000018b236d94
 CFRunLoopRunSpecific + 424 (CFRunLoop.c:3113)
5   GraphicsServices                0x000000018cca0074
GSEventRunModal + 100 (GSEvent.c:2245)
6   UIKit                           0x00000001914ef130
 UIApplicationMain + 208 (UIApplication.m:4089)
7   OneMessenger                    0x00000001004ff1b0
 main + 88 (main.m:16)
8   libdyld.dylib                   0x000000018a24559c
 start + 4

Thread 16 name:
Thread 16:
0   libsystem_kernel.dylib          0x000000018a3394dc
 fsync + 8
1   libsqlite3.dylib                0x000000018b8b704c
unixSync + 220 (sqlite3.c:33772)
2   libsqlite3.dylib                0x000000018b8b6a5c
sqlite3PagerCommitPhaseOne + 1428 (sqlite3.c:18932)
3   libsqlite3.dylib                0x000000018b8a35a0
sqlite3BtreeCommitPhaseOne + 180 (sqlite3.c:66409)
4   libsqlite3.dylib                0x000000018b872d68
sqlite3VdbeHalt + 2508 (sqlite3.c:77161)
5   libsqlite3.dylib                0x000000018b89cb7c
sqlite3VdbeExec + 56292 (sqlite3.c:82886)
6   libsqlite3.dylib                0x000000018b88e0e0
sqlite3_step + 528 (sqlite3.c:80263)
7   OneMessenger                    0x00000001003fc2bc
__25+[DataBase executeQuery:]_block_invoke + 72 (DataBase.m:1072)
8   libdispatch.dylib               0x000000018a2129e0
_dispatch_call_block_and_release + 24 (init.c:963)
9   libdispatch.dylib               0x000000018a2129a0
_dispatch_client_callout + 16 (object.m:473)
10  libdispatch.dylib               0x000000018a220ad4
_dispatch_queue_serial_drain + 928 (inline_internal.h:2431)
11  libdispatch.dylib               0x000000018a2162cc
_dispatch_queue_invoke + 884 (queue.c:4853)
12  libdispatch.dylib               0x000000018a220fa8
_dispatch_queue_override_invoke + 344 (queue.c:4890)
13  libdispatch.dylib               0x000000018a222a50
_dispatch_root_queue_drain + 540 (inline_internal.h:2468)
14  libdispatch.dylib               0x000000018a2227d0
_dispatch_worker_thread3 + 124 (queue.c:5550)
15  libsystem_pthread.dylib         0x000000018a41b1d0
_pthread_wqthread + 1096 (pthread.c:2196)
16  libsystem_pthread.dylib         0x000000018a41ad7c
 start_wqthread + 4
```

Here we can see, in Thread 16, the app clearly uses SQLite.   We see the termination reason:

```
Termination Reason: Namespace SPRINGBOARD, Code 0xdead10cc
```

Note how the word Deadlock is written as hexspeak 0xdead10cc\index{0xdead10cc}.
