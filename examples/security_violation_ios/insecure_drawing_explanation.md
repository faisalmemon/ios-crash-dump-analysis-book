## Insecure Drawing Crash

We can get an insecure drawing crash if our app tried to write to the screen when it was not allowed because, for example, the Lock Screen was being shown.

As an example we show the MobileSMS app crash with the following Crash Report, truncated for ease of demonstration:

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

Clearly we can see the Termination Code `0x2bad45ec`\index{0x2bad45ec} (spoken as "Too Bad For Security") and the `Termination Description`

```
SPRINGBOARD,
Process detected doing insecure drawing while in secure mode
```

We would not expect an Apple provided app, MobileSMS, to crash.  Looking carefully at the `Binary Images` section we can see that the Operating System has been "tweaked".  This phone has been jailbroken\index{operating system!jailbroken} due to the reference to `CydiaSubstrate`\index{CydiaSubstrate}.  We cannot safely rely on any of the apps as having their original design integrity.  Perhaps on this phone the MobileSMS app was tweaked to add extra functionality but has introduced a drawing related bug.
