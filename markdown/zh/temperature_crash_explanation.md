## 设备过热崩溃

如果设备温度过高，iOS 可能会使应用程序崩溃。使用 `Exception Code` `0xc00010ff` 进行分类。

例如，iTrainAlarm 应用程序发生终止，并生成以下崩溃报告，为了便于演示，该报告已被截断：

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
0   libsystem_kernel.dylib          0x35782010
 mach_msg_trap + 20
1   libsystem_kernel.dylib          0x35782206
 mach_msg + 50
2   AppSupport                      0x360d68c4
 CPDMTwoWayMessage + 140
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
 -[CPDistributedMessagingCenter
  sendMessageAndReceiveReplyName:userInfo:] + 42
7   libstatusbar.dylib              0x01997c1c
 0x1995000 + 11292
8   libstatusbar.dylib              0x01997da8
 0x1995000 + 11688
9   libstatusbar.dylib              0x01997d88
 0x1995000 + 11656
10  CoreFoundation                  0x33c337f8
__CFNotificationCenterAddObserver_block_invoke_0 + 116
11  CoreFoundation                  0x33c33904
____CFXNotificationPostToken_block_invoke_0 + 124
12  CoreFoundation                  0x33c3bb2a
__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 6
13  CoreFoundation                  0x33c3b158
 __CFRunLoopDoBlocks + 152
14  CoreFoundation                  0x33c3a37a
 __CFRunLoopRun + 1426
15  CoreFoundation                  0x33bbd4d6
 CFRunLoopRunSpecific + 294
16  CoreFoundation                  0x33bbd39e
 CFRunLoopRunInMode + 98
17  GraphicsServices                0x3832ffc6
 GSEventRunModal + 150
18  UIKit                           0x3162073c
 UIApplicationMain + 1084
19  iTrainAlarm                     0x000ffffc
 main (main.m:16)
20  iTrainAlarm                     0x000fffa0
 start + 32

Unknown thread crashed with unknown flavor: 5, state_count: 1
```

从 `Exception Codes:` 部分我们看到异常代码 `0xc00010ff`。可以读作"Cool Off"。 

这里表露的崩溃报告信息，显然与温度有关。目前还不清楚这个问题是特定于当前运行的应用程序、硬件的健康状况，还是发生问题时设备所在的环境。并没有已知的某些代码在运行时会产生大量热量。要解决这个问题，使用分析故障排除是合适的。例如，即使在寒冷的情况下，同一设备上的其他应用程序也发生此崩溃，那么我们可能会怀疑硬件传感器发生故障。 我们需要完整地了解问题在哪里出现，而不是在哪里没出现，以取得良好的假设。

最后，崩溃报告指出：
```
Unknown thread crashed with unknown flavor: 5, state_count: 1
```

这同样可以在系统因资源相关原因终止应用程序的情况下看到。

通过查阅 Darwin XNU 代码中的线程编码，我们可以看到:
```
#define THREAD_STATE_NONE		5
```

@threadstatus

这就意味着这不是什么值得关注的事情。崩溃报告工具工具可以进行改进以识别并报告该线程。
