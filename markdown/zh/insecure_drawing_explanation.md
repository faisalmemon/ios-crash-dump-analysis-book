## 不安全的绘制崩溃

如果应用在不安全的情况下尝试再屏幕上进行绘制，例如当前设备已经锁屏，那么我们可能会得到一个不安全的绘制崩溃。

例如，MobileSMS 应用程序发生终止，并生成以下崩溃报告，为了便于演示，该报告已被截断：

```
Incident Identifier: B076D47C-165E-4515-8E24-2C00CD307E2E
CrashReporter Key:   475d4ae82bdeca1824ec71225197c429060bb0e3
Hardware Model:      iPhone9,3
Process:             MobileSMS [3093]
Path:                /Applications/MobileSMS.app/MobileSMS
Identifier:          com.apple.MobileSMS
Version:             1.0 (5.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           com.apple.MobileSMS [799]


Date/Time:           2018-05-06 10:26:42.2201 +0300
Launch Time:         2018-05-06 10:25:13.9579 +0300
OS Version:          iPhone OS 11.1.2 (15B202)
Baseband Version:    2.01.03
Report Version:      104

Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace SPRINGBOARD, Code 0x2bad45ec
Termination Description:
 SPRINGBOARD,
  Process detected doing insecure drawing while in secure mode
Triggered by Thread:  0

Filtered syslog:
None found

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0       CoreUI                        	0x189699354
 0x189622000 + 0x77354
	// -[CUICatalog
   _resolvedRenditionKeyFromThemeRef:withBaseKey:scaleFactor:
  deviceIdiom:deviceSubtype:displayGamut:layoutDirection:
  sizeClassHorizontal:
  sizeClassVertical:memoryClass:graphicsClass:
  graphicsFallBackOrder:iconSizeIndex:] + 0x824
1       CoreUI                        	0x1896993c0
 0x189622000 + 0x773c0
	// -[CUICatalog
   _resolvedRenditionKeyFromThemeRef:withBaseKey:scaleFactor:
  deviceIdiom:deviceSubtype:displayGamut:layoutDirection:
  sizeClassHorizontal:
  sizeClassVertical:memoryClass:graphicsClass:
  graphicsFallBackOrder:
  iconSizeIndex:] + 0x890
2       CoreUI                        	0x189698b2c
 0x189622000 + 0x76b2c
	// -[CUICatalog
  _resolvedRenditionKeyForName:scaleFactor:
  deviceIdiom:deviceSubtype:displayGamut:layoutDirection:
  sizeClassHorizontal:
  sizeClassVertical:memoryClass:graphicsClass:
  graphicsFallBackOrder:
  withBaseKeySelector:] + 0x134

.
.
.


55      UIKit                         	0x18b6982e8
 0x18b625000 + 0x732e8
	// UIApplicationMain + 0xd0
56      MobileSMS (*)                 	0x10004cdd8
 0x10002c000 + 0x20dd8
	// 0x00020d58 + 0x80
57      libdyld.dylib                 	0x181be656c
 0x181be5000 + 0x156c
	// start + 0x4

Binary Images (dpkg):
0x1000a8000 - 0x1000affff + TweakInject.dylib arm64
  <5e43b90a0c4336c38fe56ac76a7ec1d9>
   /usr/lib/TweakInject.dylib
   {"install_date":"2018-04-23 09:31:57 +0300",
   "name":"Tweak Injector",
   "identifier":"org.coolstar.tweakinject",
   "version":"1.0.6"}
0x100224000 - 0x100237fff + libcolorpicker.dylib arm64
  <62b3bd5a87e03646a7feda66fc69a70c>
  /usr/lib/libcolorpicker.dylib
   {"install_date":"2018-04-25 23:17:08 +0300",
   "name":"libcolorpicker",
   "identifier":"org.thebigboss.libcolorpicker",
   "version":"1.6-1"}
0x100244000 - 0x10024bfff + CydiaSubstrate arm64
  <766a34171a3c362cae719390c6a8d715>
  /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
   {"install_date":"2018-04-23 09:31:57 +0300",
   "name":
   "Substrate Compatibility Layer",
   "identifier":"mobilesubstrate",
   "version":"99.0"}
0x100254000 - 0x100267fff + libsubstitute.0.dylib arm64
  <4aa77c47f1ec362dab77d70748383ef3>
   /usr/lib/libsubstitute.0.dylib
   {"install_date":"2018-04-23 09:31:57 +0300",
   "name":"Substitute",
   "identifier":"com.ex.libsubstitute",
   "version":"0.0.6-coolstar"}
0x1002c0000 - 0x1002c7fff + librocketbootstrap.dylib arm64
  <937a654a197136fda4826d3943045632>
  /usr/lib/librocketbootstrap.dylib
   {"install_date":"2018-04-23 09:31:57 +0300",
   "name":"RocketBootstrap",
   "identifier":"com.rpetrich.rocketbootstrap",
   "version":"1.0.6"}

Binary Images (App Store):

Binary Images (Other):
0x10002c000 - 0x10007bfff   MobileSMS arm64
  <38a8f6a396ce3d5f99600cacce041555>
   /Applications/MobileSMS.app/MobileSMS
0x100104000 - 0x100143fff   dyld arm64  
<92368d6f78863cc88239f2e3ec79bba8> /usr/lib/dyld
```

显然，我们可以看到终止代码`0x2bad45ec`（读作 “Too Bad For Security”，对安全性来说太糟糕了）和 `Termination Description`。

```
SPRINGBOARD,
Process detected doing insecure drawing while in secure mode
```

我们并不期望 Apple 提供的应用程序 MobileSMS 会发生崩溃。仔细查看 `Binary Images` 部分，我们可以看到应用程序进行了 "tweaked"。由于崩溃报告中出现了 `CydiaSubstrate`，我们可以认定该手机已经越狱了。 我们不能安全的依赖这些需要具有原始设计完整性任何应用程序。也许在这款手机上，MobileSMS 应用程序进行了调整，并添加了额外的功能，但引入了一个绘制相关的 bug。

