## `icdab_camera` iOS app crash on macOS

If we run the `icdab_camera` iOS app natively on an Apple Silicon Mac, it will launch because macOS provides the `UIKit` framework that it assumes is present.  This app is written to demonstrate a privacy violation crash, seen in earlier chapters.  Upon crashing we see:

```
Process:               icdab_camera [62970]
Path:                  /private/var/folders/*/icdab_camera.app/icdab_camera
Identifier:            perivalebluebell.com.icdab-camera
Version:               1.0 (1)
Code Type:             ARM-64 (Native)
Parent Process:        ??? [1]
Responsible:           icdab_camera [62970]
User ID:               501
```

Note how the Code Type is ARM-64.  We are running native binaries here.

```
Date/Time:             2020-11-12 20:24:32.496 +0000
OS Version:            Mac OS X 10.16 (20A5343i)
Report Version:        12
Anonymous UUID:        0118DF8D-2876-0263-8668-41B1482DDC38

Sleep/Wake UUID:       D0E45C20-ABB6-45F6-905A-D6173910795F

Time Awake Since Boot: 500000 seconds

System Integrity Protection: enabled

Notes:                 Translocated Process
```

Here we see an interesting line item, `Translocated Process`.  This gives us a clue that the crashed thread was running in a special environment.
