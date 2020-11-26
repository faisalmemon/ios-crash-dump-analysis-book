# 系统诊断

崩溃报告仅仅是更大的系统诊断报告的一部分。

一般来说，作为应用程序的开发人员，我们比不需要再深入研究。但是，如果我们的问题可能是由一系列无法解释的事件或更加复杂的系统与硬件或 Apple 提供的系统服务的交互而引发的话，那么我们不仅需要查看崩溃报告，还需要研究系统诊断信息。

## 提取系统诊断信息
在我们复现崩溃环境时，我们可能需要安装移动设备管理配置文件（以打开某些调试子系统），或创建虚拟网络接口（用于网络嗅探）。苹果提供了一个涵盖每个场景的网页。  @apple-sysdiag  

在 iOS 设备上，基本的思路是我们安装一个配置文件，该配置文件会更改设备以产生更多日志记录，然后重现崩溃（或是让客户进行这样的操作）。然后，我们按设备上的特殊键序列（例如，音量按钮和侧面按钮）。 设备会短暂振动，表明它正在运行程序 `sysdiagnose`\index{command!sysdiagnose}，该程序会提取许多日志文件。  这可能需要花费 10分钟来处理，并生成一个大文件（压缩的tar文件）。

然后，与Mac共享本地sysdiagnosis文件。我们点开菜单 `Settings > Privacy > Analytics and Improvements > Analytics Data`。 向下滚动以查找开头的文件 `sysdiagnose_YEAR.MONTH.DAY_*`.

![An example sysdiagnose log file](screenshots/sysdiagnose_example.jpeg)

选择此文件后，我们将得到一个空白屏幕，但这不是问题。 我们单击顶部工具栏中的 _Share_ 图标，然后选择适当的共享目标。

![Sharing the sysdiagnose log](screenshots/sysdiagnose_share.jpeg)

在此存档文件中，有许多系统和子系统日志，因此我们可以随时查看崩溃发生的原因。

在 macOS 上也可以使用等效方法。

## Resource Profile logs

Alongside the `sysdiagnose` logs we see that our device will have many other files.  These give insights into the general health of the system.

### CPU Resource logs

`SUBSYSTEM.cpu_resource-YEAR.MONTH.DAY_*.ips.synced` covers _CPU Resource_ profile logs.

Here is an example from `apfs_defragd`, the APFS\index{filesystem!APFS} filesystem defragmenter.

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

### Disk Utilization Logs

`SUBSYSTEM.diskwrites_resource-YEAR.MONTH.DAY_*.ips.synced` covers _Disk Utilization_ profile logs.

Here is an example from `assetd`, the Asset Manager.
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

The term "Jetsam" is originally a Nautical term, where a ship would throw off unwanted items into the sea, to lighten the ship.  In iOS, Jetsam\index{Memory!Jetsam}\index{Jetsam} is the system that ejects applications from memory in order to service the needs of the current foremost app.

Aggressive memory management is a hallmark of iOS as compared to macOS which has very liberal limits on memory usage.  Mobile Devices have traditionally been memory constrained devices.  However, as Mobile Devices become more capable, in particular iPad\index{iPad} devices, the difference is reduced.  In modern times, it is the Apple Watch\index{Apple Watch} that is considered a memory constrained device.  Nevertheless, the strict memory management system of Jetsam serves us well to keep the user experience optimal for a given amount of RAM.

It is best to think of Jetsam as a normal behavior, and being ejected from memory is not necessarily a fault of the design of our app.  We could have been running in the background consuming a modest amount of memory when the user used the Camera app and did a burst of photo taking and image effects that drove up memory usage.

If we get ejected from memory frequently, we must consider whether we are using too much memory in the background; we should aim for about 50 MB or less.  We should also write our app to save context, destroy caches, and save state so it can then be resumed from the saved state.  Then we should hook in such functionality whenever we get a message from the system indicating memory pressure, such as the `applicationDidReceiveMemoryWarning:`\index{applicationDidReceiveMemoryWarning} callback in our `AppDelegate`.

Apple document the various reasons that a Jetsam event can occur, and memory management techniques to avoid them.  @jetsamreport

The actual limits are not documented, but generally apps can have more background memory use than app extensions.  App extensions come in various types of extension, each with their own limits.  For example, a photo editing Application Extension\index{Application Extension} will have a large limit due to it generally being a heavy-weight image processing program.

The first thing to look for in a Jetsam report is the *reason* field.

Jetsam Reason|Meaning
--|--
`per-process-limit`|  The resident memory limit was reached.  The limit varies depending type of the app, or app extension.
`vm-pageshortage`| The kernel wants to give clean pages to another process but has run out of them, so killed our process.
`vnode-limit`| The kernel has run out of vnodes (a generalization of UNIX files) so is killing our process to free some more vnodes.
`highwater`|Too much physical memory used by process.
`fc-thrashing`| Too much random access to memory mapped files causing fragmentation/thrashing of the file cache.
`jettisoned`|  Some other reason for the Jetsam.

In practice, we have not seen `fc-thrashing` or `jettisoned` but they remain a possibility.


Jetsam reports are named `JetsamEvent-YEAR.MONTH.DAY_*.ips.synced`.

Here is an example report showing a "highwater" event for `wifianalyticsd`:

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
