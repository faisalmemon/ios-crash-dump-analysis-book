# 系统诊断

崩溃报告仅仅是更大的系统诊断报告的一部分。

一般来说，作为应用程序的开发人员，我们比不需要再深入研究。但是，如果我们的问题可能是由一系列无法解释的事件或更加复杂的系统与硬件或 Apple 提供的系统服务的交互而引发的话，那么我们不仅需要查看崩溃报告，还需要研究系统诊断信息。

## 提取系统诊断信息
在我们复现崩溃环境时，我们可能需要安装移动设备管理配置文件（以打开某些调试子系统），或创建虚拟网络接口（用于网络嗅探）。苹果提供了一个涵盖每个场景的网页。@apple-sysdiag  

在 iOS 设备上，基本的思路是我们安装一个配置文件，该配置文件会更改设备以产生更多日志记录，然后重现崩溃（或是让客户进行这样的操作）。然后，我们按设备上的特殊键序列（例如，音量按钮和侧面按钮）。 设备会短暂振动，表明它正在运行程序 `sysdiagnose`\index{command!sysdiagnose}，该程序会提取许多日志文件。  这可能需要花费 10分钟来处理，并生成一个大文件（压缩的tar文件）。

然后，与Mac共享本地sysdiagnosis文件。我们点开菜单 `Settings > Privacy > Analytics and Improvements > Analytics Data`。 向下滚动以查找开头的文件 `sysdiagnose_YEAR.MONTH.DAY_*`.

![An example sysdiagnose log file](screenshots/sysdiagnose_example.jpeg)

一个 sysdiagnose 日志文件示例

选择此文件后，我们将得到一个空白屏幕，但这不是问题。 我们单击顶部工具栏中的 _Share_ 图标，然后选择适当的共享目标。

![Sharing the sysdiagnose log](screenshots/sysdiagnose_share.jpeg)

在此存档文件中，有许多系统和子系统日志，因此我们可以随时查看崩溃发生的原因。

在 macOS 上也可以使用等效方法。

## 资源配置文件日志

除了`sysdiagnose` 日志，我们可以看到我们的设备还有很多其他文件。这些信息可以让我们了解系统的总体运行状况。

### CPU 资源日志

`SUBSYSTEM.cpu_resource-YEAR.MONTH.DAY_*.ips.synced` 包含 _CPU Resource_ 配置文件日志。

这是一个来自 `apfs_defragd` 的例子，APFS\index{filesystem!APFS} 文件系统碎片整理程序。

```
{"share_with_app_devs":1,"app_version":"","bug_type":"202","times
tamp":"2020-10-19 23:49:02.00 +0100","os_version":"iPhone OS 14.2
 (18B5072f)","slice_uuid":"047D42ED-E41C-38AE-81BE-E4ABCF05A703",
"is_first_party":1,"build_version":"","incident_id":"05D98B49-C8B
1-4F18-B494-491D76B2AA3C","app_name":"apfs_defragd","name":"apfs_
defragd"}
Date/Time:        2020-10-19 23:46:29.268 +0100
End time:         2020-10-19 23:48:59.680 +0100
OS Version:       iPhone OS 14.2 (Build 18B5072f)
Architecture:     arm64e
Report Version:   32
Incident Identifier: 05D98B49-C8B1-4F18-B494-491D76B2AA3C
Share With Devs:  Yes

Data Source:      Microstackshots
Shared Cache:     D949F5BB-14F3-3223-9E0F-EB9B0E5D53E8 slid base
 address 0x191410000, slide 0x11410000

Command:          apfs_defragd
Path:            
 /System/Library/Filesystems/apfs.fs/apfs_defragd
Version:          ??? (???)
Parent:           UNKNOWN [1]
PID:              7877

Event:            cpu usage
Action taken:     none
CPU:              90 seconds cpu time over 150 seconds (60% cpu
 average), exceeding limit of 50% cpu over 180 seconds
CPU limit:        90s
Limit duration:   180s
CPU used:         90s
CPU duration:     150s
Duration:         150.41s
Duration Sampled: 119.32s
Steps:            23

Hardware model:   iPhone12,1
Active cpus:      6

Heaviest stack for the target process:
  18  ??? (libsystem_pthread.dylib + 14340) [0x1db258804]
  18  ??? (libdispatch.dylib + 89464) [0x19146ad78]
  18  ??? (libdispatch.dylib + 48220) [0x191460c5c]
  18  ??? (libdispatch.dylib + 45324) [0x19146010c]
  18  ??? (libdispatch.dylib + 15792) [0x191458db0]
  18  ??? (libdispatch.dylib + 8780) [0x19145724c]
  18  ??? (apfs_defragd + 18536) [0x104f30868]
  18  ??? (apfs_defragd + 177336) [0x104f574b8]
  18  ??? (apfs_defragd + 176680) [0x104f57228]
  18  ??? (apfs_defragd + 19380) [0x104f30bb4]
  16  ??? (apfs_defragd + 10128) [0x104f2e790]
  16  ??? (AppleFSCompression + 18424) [0x1c8e0a7f8]
  16  ??? (AppleFSCompression + 43828) [0x1c8e10b34]
  6   ??? (AppleFSCompression + 44780) [0x1c8e10eec]
  2   ??? (libz.1.dylib + 47196) [0x1dae8885c]


Powerstats for:   apfs_defragd [7877]
UUID:             047D42ED-E41C-38AE-81BE-E4ABCF05A703
Path:            
 /System/Library/Filesystems/apfs.fs/apfs_defragd
Architecture:     arm64e
Parent:           UNKNOWN [1]
UID:              0
Sudden Term:      Tracked (allows idle exit)
Footprint:        120.84 MB
Start time:       2020-10-19 23:47:00.334 +0100
End time:         2020-10-19 23:48:58.707 +0100
Num samples:      18 (78%)
Primary state:    10 samples Non-Frontmost App, Non-Suppressed,
 Kernel mode, Effective Thread QoS Background, Requested Thread
 QoS Background, Override Thread QoS Unspecified
User Activity:    18 samples Idle, 0 samples Active
Power Source:     0 samples on Battery, 18 samples on AC
  18  ??? (libsystem_pthread.dylib + 14340) [0x1db258804]
    18  ??? (libdispatch.dylib + 89464) [0x19146ad78]
.
.

  Binary Images:
           0x104f2c000 -                ???  apfs_defragd        
     <047D42ED-E41C-38AE-81BE-E4ABCF05A703>
 /System/Library/Filesystems/apfs.fs/apfs_defragd
.
.

Powerstats for:   PerfPowerServicesExtended
UUID:             AC943755-DBF7-306D-8D54-5F1FA7D45C1A
Path:             /usr/bin/PerfPowerServicesExtended
Architecture:     arm64e
Start time:       2020-10-19 23:47:41.119 +0100
End time:         2020-10-19 23:48:19.856 +0100
Num samples:      3 (13%)
Primary state:    2 samples Non-Frontmost App, Non-Suppressed,
 User mode, Effective Thread QoS Background, Requested Thread QoS
 Background, Override Thread QoS Unspecified
User Activity:    3 samples Idle, 0 samples Active
Power Source:     0 samples on Battery, 3 samples on AC
  3  ??? (libsystem_pthread.dylib + 14340) [0x1db258804]
    3  ??? (libdispatch.dylib + 89464) [0x19146ad78]
.
.

  Binary Images:
           0x104e78000 -                ???
 PerfPowerServicesExtended <AC943755-DBF7-306D-8D54-5F1FA7D45C1A>
  /usr/bin/PerfPowerServicesExtended
           0x191455000 -        0x191497fff  libdispatch.dylib   
      <187D8E52-371D-33F2-B0D4-C6D154917885>
 /usr/lib/system/libdispatch.dylib
.
.
```

### 磁盘利用率日志

`SUBSYSTEM.diskwrites_resource-YEAR.MONTH.DAY_*.ips.synced` 包含 _Disk Utilization_ 配置文件日志。

这是一个来自 `assetd` 的例子，Asset 管理软件。
```
{"share_with_app_devs":1,"app_version":"","bug_type":"145","times
tamp":"2020-10-18 02:55:57.00 +0100","os_version":"iPhone OS 14.2
 (18B5072f)","slice_uuid":"6192DA47-C99E-33F4-8FC5-CF071E4EE26B",
"is_first_party":1,"build_version":"","incident_id":"BB4403D7-A0C
F-4C50-AEA6-EFF26FACF690","app_name":"assetsd","name":"assetsd"}
Date/Time:        2020-10-17 23:26:36.891 +0100
End time:         2020-10-18 02:55:56.835 +0100
OS Version:       iPhone OS 14.2 (Build 18B5072f)
Architecture:     arm64e
Report Version:   32
Incident Identifier: BB4403D7-A0CF-4C50-AEA6-EFF26FACF690
Share With Devs:  Yes

Data Source:      Microstackshots
Shared Cache:     D949F5BB-14F3-3223-9E0F-EB9B0E5D53E8 slid base
 address 0x191410000, slide 0x11410000

Command:          assetsd
Path:            
 /System/Library/Frameworks/AssetsLibrary.framework/Support/asset
sd
Version:          ??? (???)
Parent:           launchd [1]
PID:              124

Event:            disk writes
Action taken:     none
Writes:           1073.75 MB of file backed memory dirtied over
 12560 seconds (85.49 KB per second average), exceeding limit of
 12.43 KB per second over 86400 seconds
Writes limit:     1073.74 MB
Limit duration:   86400s
Writes caused:    1073.75 MB
Writes duration:  12560s
Duration:         12559.94s
Duration Sampled: 12460.16s
Steps:            81 ( (10.49 MB/step))

Hardware model:   iPhone12,1
Active cpus:      6


Heaviest stack for the target process:
  6  ??? (libsystem_pthread.dylib + 14340) [0x1db258804]
  6  ??? (libdispatch.dylib + 89464) [0x19146ad78]
  6  ??? (libdispatch.dylib + 48220) [0x191460c5c]
  6  ??? (libdispatch.dylib + 45324) [0x19146010c]
  6  ??? (libdispatch.dylib + 15792) [0x191458db0]
  6  ??? (libdispatch.dylib + 8780) [0x19145724c]
  6  ??? (AssetsLibraryServices + 240248) [0x1a3090a78]
  6  ??? (PhotoLibraryServices + 5982616) [0x1a2eda998]
  6  ??? (PhotoLibraryServices + 5903404) [0x1a2ec742c]
  5  ??? (libsqlite3.dylib + 272472) [0x1ab453858]
  5  ??? (libsqlite3.dylib + 335252) [0x1ab462d94]
  5  ??? (libsqlite3.dylib + 147268) [0x1ab434f44]
  5  ??? (libsqlite3.dylib + 365168) [0x1ab46a270]
  5  ??? (libsqlite3.dylib + 450844) [0x1ab47f11c]
  5  ??? (libsqlite3.dylib + 778840) [0x1ab4cf258]
  5  ??? (libsqlite3.dylib + 452760) [0x1ab47f898]
  5  ??? (libsystem_kernel.dylib + 172372) [0x1becf8154]


Powerstats for:   assetsd [124]
UUID:             6192DA47-C99E-33F4-8FC5-CF071E4EE26B
Path:            
 /System/Library/Frameworks/AssetsLibrary.framework/Support/asset
sd
Architecture:     arm64e
Parent:           launchd [1]
UID:              501
Sudden Term:      Tracked (allows idle exit)
Footprint:        19.98 MB
Start time:       2020-10-18 02:54:02.699 +0100
End time:         2020-10-18 02:55:24.063 +0100
Num samples:      6 (7%)
Primary state:    6 samples Non-Frontmost App, Non-Suppressed,
 Kernel mode, Effective Thread QoS Background, Requested Thread
 QoS Utility, Override Thread QoS Unspecified
User Activity:    6 samples Idle, 0 samples Active
Power Source:     0 samples on Battery, 6 samples on AC
  6  ??? (libsystem_pthread.dylib + 14340) [0x1db258804]
.
.

  Binary Images:
           0x104bf4000 -                ???  assetsd             
    <6192DA47-C99E-33F4-8FC5-CF071E4EE26B>
 /System/Library/Frameworks/AssetsLibrary.framework/Support/asset
sd
           0x191455000 -        0x191497fff  libdispatch.dylib   
    <187D8E52-371D-33F2-B0D4-C6D154917885>
 /usr/lib/system/libdispatch.dylib
.
.
```

### Jetsam 报告

`Jetsam` 一词最初是一个航海术语，指船只将不想要的东西扔进海里，以减轻船的重量。在 iOS 中，`Jetsam` \index{Memory!Jetsam}\index{Jetsam} 是将当前应用从内存中弹出以满足当前最重要应用需求的系统。

与 macOS 相比，激进（积极）的内存管理是 iOS 的一个特点，macOS 对内存使用有非常宽松的限制。通俗来说，移动设备是内存受限的设备。然而，随着移动设备的功能越来越强大，特别是 iPad\index{iPad} 设备，这种差异已经越来越小。现在，Apple Watch\index{Apple Watch} 被认为是内存受限的设备。然而，`Jetsam`  严格的内存管理系统为我们提供了良好的服务，在给定的 RAM 量下保证最佳的用户体验。 

最好把 `Jetsam` 看作是正常的行为，从内存中弹出并不一定是我们应用程序设计的错误。我们本来可以在后台运行，当用户使用拍照功能进行大量的拍照和图像特效时，内存使用量会增加。

如果我们经常从内存中弹出，我们必须考虑我们是否在后台使用了过多的内存； 我们的目标应该是不超过 50 MB或更小。我们还应该编写程序方法来保存上下文、销毁缓存和保存状态，以便从保存的状态恢复。然后我们应该 Hook 在这样的功能，当我们从系统得到一个内存警告消息时，如 `AppDelegate` 中的 `applicationDidReceiveMemoryWarning:` \index{applicationDidReceiveMemoryWarning}  的回调 ，执行该方法。

Apple 记录了 `Jetsam` 事件可能发生的各种原因，以及如何避免它们的内存管理技术。@jetsamreport

并没有实际的文档说明这种限制，但是通常应用程序比应用程序扩展拥有有更多的后台内存使用。应用程序扩展有各种类型的扩展，每一种都有自己的限制。例如，一个照片编辑应用程序扩展会有很大的限制，因为它通常是一个重量级的图像处理程序。

在 Jetsam 报告中首先要查找的是 *reason* 字段。

Jetsam Reason|Meaning
--|--
`per-process-limit`| 已达到常驻内存限制。 该限制因应用程序或扩展程序的类型而异。 
`vm-pageshortage`| 内核希望提供干净的页面给另一个进程，但是已经用完了，因此杀死了我们的进程。 
`vnode-limit`| 内核已经用完了 vnode（UNIX文件的一种泛化），因此正在终止我们释放更多vnode的进程。 
`highwater`|进程使用过多的物理内存。
`fc-thrashing`| 对内存映射文件的过多随机访问导致了文件缓存的碎片/抖动。 
`jettisoned`| Jetsam 的其他原因。 

实际上，我们还没有见过 `fc-thrashing` 或 `jettisoned `的情况，但是它们仍然是可能的。


Jetsam 报告被命名 `JetsamEvent-YEAR.MONTH.DAY_*.ips.synced`.

下面是一个例子报告说明了 `highwater` 事件的 `wifianalyticsd`：

```
{"bug_type":"298","timestamp":"2020-10-15 17:29:58.79
 +0100","os_version":"iPhone OS 14.2
 (18B5061e)","incident_id":"B04A36B1-19EC-4895-B203-6AE21BE52B02"
}
{
  "crashReporterKey" :
 "d3e622273dd1296e8599964c99f70e07d25c8ddc",
  "kernel" : "Darwin Kernel Version 20.1.0: Mon Sep 21 00:09:01
 PDT 2020; root:xnu-7195.40.113.0.2~22\/RELEASE_ARM64_T8030",
  "product" : "iPhone12,1",
  "incident" : "B04A36B1-19EC-4895-B203-6AE21BE52B02",
  "date" : "2020-10-15 17:29:58.79 +0100",
  "build" : "iPhone OS 14.2 (18B5061e)",
  "timeDelta" : 7,
  "memoryStatus" : {
  "compressorSize" : 96635,
  "compressions" : 3009015,
  "decompressions" : 2533158,
  "zoneMapCap" : 1472872448,
  "largestZone" : "APFS_4K_OBJS",
  "largestZoneSize" : 41271296,
  "pageSize" : 16384,
  "uncompressed" : 257255,
  "zoneMapSize" : 193200128,
  "memoryPages" : {
    "active" : 45459,
    "throttled" : 0,
    "fileBacked" : 34023,
    "wired" : 49236,
    "anonymous" : 55900,
    "purgeable" : 12,
    "inactive" : 40671,
    "free" : 5142,
    "speculative" : 3793
  }
},
  "largestProcess" : "AppStore",
  "genCounter" : 1,
  "processes" : [
  {
    "uuid" : "7607487f-d2b1-3251-a2a6-562c8c4be18c",
    "states" : [
      "daemon",
      "idle"
    ],
    "age" : 3724485992920,
    "purgeable" : 0,
    "fds" : 25,
    "coalition" : 68,
    "rpages" : 229,
    "priority" : 0,
    "physicalPages" : {
      "internal" : [
        6,
        183
      ]
    },
    "pid" : 350,
    "cpuTime" : 0.066796999999999995,
    "name" : "SBRendererService",
    "lifetimeMax" : 976
  },
.
.
{
  "uuid" : "f71f1e2b-a7ca-332d-bf87-42193c153ef8",
  "states" : [
    "daemon",
    "idle"
  ],
  "lifetimeMax" : 385,
  "killDelta" : 13595,
  "age" : 94337735133,
  "purgeable" : 0,
  "fds" : 50,
  "genCount" : 0,
  "coalition" : 320,
  "rpages" : 382,
  "priority" : 1,
  "reason" : "highwater",
  "physicalPages" : {
    "internal" : [
      327,
      41
    ]
  },
  "pid" : 2527,
  "idleDelta" : 41601646,
  "name" : "wifianalyticsd",
  "cpuTime" : 0.634077
},
.
.
```
