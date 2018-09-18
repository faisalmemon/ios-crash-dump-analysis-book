## Temperature Crash

The iOS platform can crash an app if the temperature gets too high.  It is classified using an `Exception Code` `0xc00010ff`

For example the iTrainAlarm app was terminated with the following Crash Report, truncated for ease of demonstration:

```
Exception Type:  00000020
Exception Codes: 0xc00010ff
Highlighted Thread:  0

Application Specific Information:
Topmost application

Thermal Level:       16
Thermal Sensors:     11336 29078 5149 3419 3437

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0:
0   libsystem_kernel.dylib          0x35782010 mach_msg_trap + 20
1   libsystem_kernel.dylib          0x35782206 mach_msg + 50
2   AppSupport                      0x360d68c4 CPDMTwoWayMessage + 140
3   AppSupport                      0x360d52f0
-[CPDistributedMessagingCenter _sendMessage:userInfoData:
oolKey:oolData:makeServer:receiveReply:nonBlocking:error:] + 408
4   AppSupport                      0x360d59a6
-[CPDistributedMessagingCenter _sendMessage:userInfo:
receiveReply:error:toTarget:selector:context:nonBlocking:] + 870
5   AppSupport                      0x360d3cfc
 -[CPDistributedMessagingCenter _sendMessage:userInfo:
 receiveReply:error:toTarget:selector:context:] + 56
6   AppSupport                      0x360d3b8a
 -[CPDistributedMessagingCenter sendMessageAndReceiveReplyName:userInfo:] + 42
7   libstatusbar.dylib              0x01997c1c 0x1995000 + 11292
8   libstatusbar.dylib              0x01997da8 0x1995000 + 11688
9   libstatusbar.dylib              0x01997d88 0x1995000 + 11656
10  CoreFoundation                  0x33c337f8
__CFNotificationCenterAddObserver_block_invoke_0 + 116
11  CoreFoundation                  0x33c33904
____CFXNotificationPostToken_block_invoke_0 + 124
12  CoreFoundation                  0x33c3bb2a
__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 6
13  CoreFoundation                  0x33c3b158 __CFRunLoopDoBlocks + 152
14  CoreFoundation                  0x33c3a37a __CFRunLoopRun + 1426
15  CoreFoundation                  0x33bbd4d6 CFRunLoopRunSpecific + 294
16  CoreFoundation                  0x33bbd39e CFRunLoopRunInMode + 98
17  GraphicsServices                0x3832ffc6 GSEventRunModal + 150
18  UIKit                           0x3162073c UIApplicationMain + 1084
19  iTrainAlarm                     0x000ffffc main (main.m:16)
20  iTrainAlarm                     0x000fffa0 start + 32

Unknown thread crashed with unknown flavor: 5, state_count: 1
```

From the `Exception Codes:` we see the code `0xc00010ff`\index{0xc00010ff}.  This is read as "Cool Off".

The Crash Report, shown here, is clearly to do with temperature.  It is not clear whether the problem is specific to the app currently running, the health of the hardware, or the environment the device was in at the time of the problem.  None of the code running is known to generate large amounts of heat.  To fix this issue, Analytic Troubleshooting is appropriate.  For example, if this crash happens to other apps on the same device even when it is cold, we can suspect a hardware sensor failure.  We need a complete picture of where the problem is seen versus not present to make progress with a good hypothesis.

Finally, the Crash Report notes:
```
Unknown thread crashed with unknown flavor: 5, state_count: 1
```

This can been seen for cases where the system terminates the app for resource related reasons.

From looking up the thread flavor in the Darwin XNU code, we see:
```
#define THREAD_STATE_NONE		5
```

@threadstatus

So it just means that this is not something of concern.  The Crash Report tool could do with improvement to identify this thread flavor, and report it.
