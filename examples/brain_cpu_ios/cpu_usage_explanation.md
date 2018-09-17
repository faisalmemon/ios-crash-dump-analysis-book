## CPU Usage Crash

The iOS platform can update itself.  Here is an example where it has used up too much CPU time in performing the update.

The following Crash Report, truncated for ease of demonstration, shows the `UpdateBrainService` being terminated:

```
Incident Identifier: 92F40C53-6BB8-4E13-A4C2-CF2F1C85E8DF
CrashReporter Key:   69face25f1299fdcbbe337b89e6a9f649818ba13
Hardware Model:      iPad4,4
Process:             com.apple.MobileSoftwareUpdate.UpdateBrainService [147]
Path:                /private/var/run/com.apple.xpcproxy.RoleAccount.staging/
com.apple.MobileSoftwareUpdate.UpdateBrainService.16777219.47335.xpc/
com.apple.MobileSoftwareUpdate.UpdateBrainService
Identifier:          com.apple.MobileSoftwareUpdate.UpdateBrainService
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Parent Process:      launchd [1]

Date/Time:           2015-02-03 20:14:05.504 -0800
Launch Time:         2015-02-03 20:11:35.306 -0800
OS Version:          iOS 8.1.2 (12B440)
Report Version:      105

Exception Type:  EXC_RESOURCE
Exception Subtype: CPU
Exception Message: (Limit 50%) Observed 60% over 180 secs
Triggered by Thread:  2

Thread 2 name:  Dispatch queue: com.apple.root.default-qos
Thread 2 Attributed:
0   libsystem_kernel.dylib        	0x0000000196b9b1ec 0x196b98000 + 12780
1   ...reUpdate.UpdateBrainService	0x000000010008ac70 0x100080000 + 44144
2   ...reUpdate.UpdateBrainService	0x0000000100083678 0x100080000 + 13944
3   ...reUpdate.UpdateBrainService	0x000000010008b8e0 0x100080000 + 47328
4   ...reUpdate.UpdateBrainService	0x00000001000831e8 0x100080000 + 12776
5   ...reUpdate.UpdateBrainService	0x0000000100093478 0x100080000 + 78968
6   ...reUpdate.UpdateBrainService	0x000000010008e368 0x100080000 + 58216
7   ...reUpdate.UpdateBrainService	0x0000000100094548 0x100080000 + 83272
8   ...reUpdate.UpdateBrainService	0x000000010008ebb0 0x100080000 + 60336
9   libdispatch.dylib             	0x0000000196a713a8 0x196a70000 + 5032
10  libdispatch.dylib             	0x0000000196a71368 0x196a70000 + 4968
11  libdispatch.dylib             	0x0000000196a7d408 0x196a70000 + 54280
12  libdispatch.dylib             	0x0000000196a7e758 0x196a70000 + 59224
13  libsystem_pthread.dylib       	0x0000000196c4d2e0 0x196c4c000 + 4832
14  libsystem_pthread.dylib       	0x0000000196c4cfa4 0x196c4c000 + 4004

Thread 2 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2: 0xffffffffffffffe8
       x3: 0x00000001004991c8
    x4: 0x0000000000000007   x5: 0x0000000000000018   x6: 0x0000000000000000
       x7: 0x0000000000000000
    x8: 0x2f6a6f72706c2e73   x9: 0x6166654448435354  x10: 0x5361746144746c75
      x11: 0x614264656b636174
   x12: 0x6166654448435354  x13: 0x5361746144746c75  x14: 0x614264656b636174
     x15: 0x007473696c702e72
   x16: 0x0000000000000154  x17: 0x00000001000cd2b1  x18: 0x0000000000000000
     x19: 0x000000010049963c
   x20: 0x0000000100499630  x21: 0x0000000000000000  x22: 0x000000014f001280
     x23: 0x0000000100499640
   x24: 0x000000014f001330  x25: 0x00000001004991a7  x26: 0x0000000100498c70
     x27: 0x000000019a75d0a8
   x28: 0x000000014f001330  fp: 0x0000000100499600   lr: 0x000000010008ac74
    sp: 0x0000000100498c50   pc: 0x0000000196b9b1ec cpsr: 0x80000000

Bad magic 0x86857EF8
Microstackshots: 1
(from 1969-12-31 20:33:03 -0800 to 1969-12-31 20:33:03 -0800)
  1 ??? [0x16fd7fab0]
    1 CoreFoundation 0x1858ec000 + 37028 [0x1858f50a4]
      1 ??? [0x16fd7f970]
        1 CoreFoundation 0x1858ec000 + 900644 [0x1859c7e24]
          1 ??? [0x16fd7ec60]
            1 CoreFoundation 0x1858ec000 + 909008 [0x1859c9ed0]
              1 ??? [0x16fd7ec00]
                1 libsystem_kernel.dylib 0x196b98000 + 3320 [0x196b98cf8]
                  1 ??? [0x16fd7ebb0]
                    1 libsystem_kernel.dylib 0x196b98000 + 3708 [0x196b98e7c]
                     *1 ??? [0xffffff8002012f08]
```

Here it is quite clear that too much CPU resource was taken up by the `UpdateBrainService` program.
```
Exception Type:  EXC_RESOURCE
Exception Subtype: CPU
Exception Message: (Limit 50%) Observed 60% over 180 secs
```

The `Microstackshots` section of the report presumably tells us a sample of the stack at the time of termination.
It seems that the `Bad magic` value reported varies but generally seems to be present with `EXC_RESOURCE` crashes.
