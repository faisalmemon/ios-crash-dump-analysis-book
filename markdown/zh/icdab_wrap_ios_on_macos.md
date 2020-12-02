### `icdab_wrap` iOS 应用程序在 macOS 上崩溃

如果我们在 Apple Silicon Mac 上运行 iOS 应用 `icdab_wrap` ，它可以正常加载，是因为 macOS 提供了 `UIKit` 框架，而 `icdab_wrap` 也假定该框架已存在。该应用程序是为了来演示一个问题，解包 Nil 可选项。

崩溃时，我们可以看到：
```
Code Type:             ARM-64 (Native)
Parent Process:        ??? [1]
Responsible:           icdab_wrap [2802]
User ID:               501
```

这表明应用程序正在运行原生代码，而不是翻译过的代码。

```
Date/Time:             2020-11-14 11:58:17.668 +0000
OS Version:            Mac OS X 10.16 (20A5343i)
Report Version:        12
Anonymous UUID:        0118DF8D-2876-0263-8668-41B1482DDC38
```

这表明我们很明显的是在 Mac 上运行。

```
System Integrity Protection: enabled

Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BREAKPOINT (SIGTRAP)
Exception Codes:       EXC_ARM_BREAKPOINT at 0x00000001c6c8f1f0
 (brk 1)
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Trace/BPT trap: 5
Termination Reason:    Namespace SIGNAL, Code 0x5
Terminating Process:   exc handler [2802]

Application Specific Information:
dyld3 mode
Fatal error: Unexpectedly found nil while implicitly unwrapping
 an Optional value: file icdab_wrap/PlanetViewController.swift,
 line 45
```

这说明程序崩溃时正在解包 Nil 可选项。

```
Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   libswiftCore.dylib                  0x00000001c6c8f1f0
 closure #1 in closure #1 in closure #1 in
 _assertionFailure(_:_:file:line:flags:) + 404
1   libswiftCore.dylib                  0x00000001c6c8f1f0
 closure #1 in closure #1 in closure #1 in
 _assertionFailure(_:_:file:line:flags:) + 404
2   libswiftCore.dylib                  0x00000001c6c8e660
 _assertionFailure(_:_:file:line:flags:) + 488
3   www.perivalebluebell.icdab-wrap     0x0000000104937da4
 PlanetViewController.imageDownloaded(_:) + 196
 (PlanetViewController.swift:45)
.
.
.

16  com.apple.AppKit                    0x0000000189740824
 _DPSNextEvent + 880
17  com.apple.AppKit                    0x000000018973f1fc
 -[NSApplication(NSEvent)
 _nextEventMatchingEventMask:untilDate:inMode:dequeue:] + 1300
18  com.apple.AppKit                    0x00000001897313c4
 -[NSApplication run] + 600
19  com.apple.AppKit                    0x0000000189703550
 NSApplicationMain + 1064
20  com.apple.AppKit                    0x00000001899e92f8
 _NSApplicationMainWithInfoDictionary + 24
21  com.apple.UIKitMacHelper            0x00000001bd9a6038
 UINSApplicationMain + 476
22  com.apple.UIKitCore                 0x00000001d333d1b0
 UIApplicationMain + 2108
23  www.perivalebluebell.icdab-wrap     0x0000000104933a38 main +
 88 (AppDelegate.swift:12)
24  libdyld.dylib                       0x00000001c758ca50 start
 + 4
```

这表明当程序被加载时 `libdyld.dylib`，它所期望的 UIKit `UIKitCore` 是通过 `UIKitMacHelper` 支持层实现的。

```
Binary Images:
       0x10492c000 -        0x10493bfff
 +www.perivalebluebell.icdab-wrap (1.0 - 1)
 <E9A2E2CC-E879-37B0-820C-F336DF2AACDA>
 /Users/USER/Library/Developer/Xcode/DerivedData/icdab-gbtgrhpqeh
gqogaglrpuvzajteku/Build/Products/Debug-iphoneos/icdab_wrap.app/i
cdab_wrap
       0x104a1c000 -        0x104a27fff 
 libobjc-trampolines.dylib (817)
 <4A2C66DE-9358-3AE9-A69F-36687DB19CE3>
 /usr/lib/libobjc-trampolines.dylib
       0x104b34000 -        0x104baffff  dyld (828)
 <7A9F335B-50E3-3018-A9CC-26E57B61D907> /usr/lib/dyld
.
.

       0x189700000 -        0x18a400fff  com.apple.AppKit (6.9 -
 2004.102) <96941AAC-01D7-36E7-9253-2C1187864719>
 /System/Library/Frameworks/AppKit.framework/Versions/C/AppKit
.
.

       0x1bd77f000 -        0x1bd9a1fff  com.apple.UIFoundation
 (1.0 - 714) <D3335C2E-2366-30AD-A5F3-6058164D69EE>
 /System/Library/PrivateFrameworks/UIFoundation.framework/Version
s/A/UIFoundation
       0x1bd9a2000 -        0x1bda37fff  com.apple.UIKitMacHelper
 (1.0 - 3979.1.400) <F2F6D8F7-8178-3113-856E-F99614A4F13E>
 /System/Library/PrivateFrameworks/UIKitMacHelper.framework/Versi
ons/A/UIKitMacHelper
       0x1bda38000 -        0x1bda4bfff  com.apple.UIKitServices
 (1.0 - 1) <D8C4D101-A04C-37E6-87A3-6AD9ADFEC787>
 /System/Library/PrivateFrameworks/UIKitServices.framework/Versio
ns/A/UIKitServices
.
.

       0x1c9b1b000 -        0x1c9b1bfff 
 com.apple.MobileCoreServices (1112.0.10 - 1112.0.10)
 <992DAEC7-6964-3686-A910-4365B353D925>
 /System/iOSSupport/System/Library/Frameworks/MobileCoreServices.
framework/Versions/A/MobileCoreServices
.
.

       0x1d333a000 -        0x1d462ffff  com.apple.UIKitCore (1.0
 - 3979.1.400) <023078DD-44DA-3A11-82CA-12F8412661A2>
 /System/iOSSupport/System/Library/PrivateFrameworks/UIKitCore.fr
amework/Versions/A/UIKitCore
.
.

       0x1d72fa000 -        0x1d7337fff  libswiftUIKit.dylib (15)
 <68377BCA-6493-3E34-920E-0765BD07F2A7>
 /System/iOSSupport/usr/lib/swift/libswiftUIKit.dylib
```

在大多数情况下，这些崩溃可以像在 iOS 上崩溃一样直接进行分析。问题很有可能是由于不同的物理环境导致的。例如，iOS 设备具有陀螺仪，而 macOS 设备则没有。

### 在 Mac 上支持 iOS 应用程序

Apple 提供了在 Mac 上部署 iOS 应用程序的最佳实践指南。@iosOnMac你可以进行如下操作：

1. 如果确定自己的 iOS 应用程序不适合 macOS。在 App Store Connect\index{App Store Connect} 中可以取消配置。
2. 允许在 iOS 上安装的应用程序安装在 macOS 上，但是添加检查可用的可选硬件功能。
3. 增强该应用程序，使 Mac 用户更易于使用替代功能。 例如，添加iOS键盘支持。
4. 添加代码以检测 _iOS-on-Mac_ 的场景。\index{iOS on Mac}
5. 通过 Mac Catalyst \index{Mac Catalyst}  技术连接到Mac。这意味着首先得拥有一个出色的iPadOS应用。
6. 编写纯原生 macOS 应用程序。

例如，在应用程序 `icdab_gyro` 我们将展示如何检测 _iOS-on-Mac_ 的场景：

```
        let info = ProcessInfo()
        if #available(iOS 14.0, *) {
            if info.isiOSAppOnMac {
                print("We are an iOS app running on a Mac")
            }
        }
```

此外，当使用陀螺仪时
```
var motion = CMMotionManager()
```

并仅在可用时使用陀螺仪：
```
if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = 1.0 / 60.0
          self.motion.startGyroUpdates()
.
.
```
