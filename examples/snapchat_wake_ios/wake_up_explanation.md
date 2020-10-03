## Wake Up Crash

The iOS platform limits the number of Wake Ups.  When a CPU interrupt occurs, the CPU wakes up to service some task.  Typically it is when there is some IO to process, such as inbound networking data.  If the platform wakes up too frequently, it can drain the battery.  Therefore, the rate of wake ups is limited by the Operating System.

The following Crash Report, truncated for ease of demonstration, shows the `Snapchat`\index{trademark!Snapchat} app being terminated:

```
Incident Identifier: 79C39D6B-E4CA-4047-B96D-7EEED2B57B46
CrashReporter Key:   52be47ab0a43fb240756d6f5a1e1bcf4aa53c568
Hardware Model:      iPhone7,2
Process:             Snapchat [3151]
Path:                /private/var/mobile/Containers/
Bundle/Application/3E13B779-FFA3-491C-A018-F39E620553D4/
Snapchat.app/Snapchat
Identifier:          com.toyopagroup.picaboo
Version:             9.11.0.1 (9.11.0)
Code Type:           ARM-64 (Native)
Parent Process:      launchd [1]
Date/Time:           2015-07-05 20:00:52.228 +0200
Launch Time:         2015-07-05 19:42:01.054 +0200
OS Version:          iOS 8.3 (12F70)
Report Version:      105
Exception Type:      EXC_RESOURCE
Exception Subtype:   WAKEUPS
Exception Message:   
(Limit 150/sec) Observed 195/sec over 300 secs
Triggered by Thread: 21

Thread 21 name:  Dispatch queue:
 com.apple.avfoundation.videodataoutput.bufferqueue
Thread 21:
0       libsystem_kernel.dylib        	0x193c9ce0c
 0x193c9c000 + 0xe0c
 	// mach_msg_trap + 0x8
1       libsystem_kernel.dylib        	0x193c9cc84
 0x193c9c000 + 0xc84
 	// mach_msg + 0x44
2       IOKit                         	0x182efdec0
 0x182ea8000 + 0x55ec0
	// io_connect_method + 0x168
3       IOKit                         	0x182eadfd8
 0x182ea8000 + 0x5fd8
	// IOConnectCallMethod + 0xe4
4       IOSurface                     	0x18bae515c
 0x18bae4000 + 0x115c
	// IOSurfaceClientLookup + 0xcc
5       IOSurface                     	0x18bae90ec
 0x18bae4000 + 0x50ec
	// IOSurfaceLookup + 0x10
6       CoreMedia                     	0x18252d9c8
 0x1824dc000 + 0x519c8
	// rqReceiverDequeue + 0x64
7       CoreMedia                     	0x18252dd38
 0x1824dc000 + 0x51d38
	// __FigRemoteQueueReceiverSetHandler_block_invoke2 +
 0xa0
8       libdispatch.dylib             	0x193b71950
 0x193b70000 + 0x1950
	// _dispatch_client_callout + 0xc
9       libdispatch.dylib             	0x193b8800c
 0x193b70000 + 0x1800c
	// _dispatch_source_latch_and_call + 0x800
10      libdispatch.dylib             	0x193b73ab8
 0x193b70000 + 0x3ab8
	// _dispatch_source_invoke + 0x11c
11      libdispatch.dylib             	0x193b7c2d0
 0x193b70000 + 0xc2d0
	// _dispatch_queue_drain + 0x7d4
12      libdispatch.dylib             	0x193b74a58
 0x193b70000 + 0x4a58
	// _dispatch_queue_invoke + 0x80
13      libdispatch.dylib             	0x193b7e314
 0x193b70000 + 0xe314
	// _dispatch_root_queue_drain + 0x2cc
14      libdispatch.dylib             	0x193b7fc48
 0x193b70000 + 0xfc48
	// _dispatch_worker_thread3 + 0x68
15      libsystem_pthread.dylib       	0x193d51228
 0x193d50000 + 0x1228
	// _pthread_wqthread + 0x32c
16      libsystem_pthread.dylib       	0x193d50eec
 0x193d50000 + 0xeec
 	// start_wqthread + 0x0

Thread 21 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000003   
    x2: 0x000000000000005c
       x3: 0x00000000000010bc
    x4: 0x0000000000017c37   x5: 0x0000000000000000   
    x6: 0x0000000000000000
       x7: 0x0000000000000000
    x8: 0x00000000fffffbbf   x9: 0x0000000000000b31  
    x10: 0x000000010f67fba0
      x11: 0x0000000000000000
   x12: 0x0000000000000000  x13: 0x0000000000000001  
   x14: 0x0000000000000001
     x15: 0x0000000000000000
   x16: 0xffffffffffffffe1  x17: 0x0000000000000000  
   x18: 0x0000000000000000
     x19: 0x0000000000000000
   x20: 0x0000000000000000  x21: 0x0000000000017c37  
   x22: 0x00000000000010bc
     x23: 0x000000010f67ea20
   x24: 0x0000000000000003  x25: 0x000000000000005c  
   x26: 0x0000000000000003
     x27: 0x000000010f67fbac
   x28: 0x0000000000000000  fp: 0x000000010f67e9f0   
   lr: 0x0000000193c9cc88
    sp: 0x000000010f67e9a0   pc: 0x0000000193c9ce0c
    cpsr: 0x80000000
Bad magic 0x8B3F36FC
Microstackshots: 1
(from 1970-01-01 01:03:20 +0100 to 1970-01-01 01:03:20 +0100)
  1 ??? [0x16fddb870]
    1 CoreFoundation 0x181bd4000 + 906872
    [0x181cb1678]
      1 ??? [0x16fddab60]
        1 CoreFoundation 0x181bd4000 + 915236
        [0x181cb3724]
          1 ??? [0x16fddab00]
            1 libsystem_kernel.dylib 0x193c9c000 + 3208
            [0x193c9cc88]
              1 ??? [0x16fddaab0]
                1 libsystem_kernel.dylib 0x193c9c000 + 3596
                 [0x193c9ce0c]
                 *1 ??? [0xffffff80020144a4]
```

Similar to a CPU resource limit crash, we get an indication of the limit reached:
```
Exception Type:      EXC_RESOURCE
Exception Subtype:   WAKEUPS
Exception Message:   (Limit 150/sec) Observed 195/sec over
 300 secs
```

We also get a `Bad magic` value in the Crash Report followed by a snapshot of what was running at the point of termination.

We can see many threads running, related to Networking, Audio, and Video.  We can guess that this application does its own heavy lifting in terms of presenting a video feed and this system level type code is either faulty or has a performance problem.
