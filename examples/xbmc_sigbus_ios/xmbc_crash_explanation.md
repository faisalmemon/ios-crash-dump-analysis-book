### xmbmc crash

The `xmbc` app is a utility app that behaves like a television media player remote control.

During startup the application crashed with the following Crash Report, truncated for ease of demonstration:

```
Incident Identifier: 396B3641-5F74-4B01-9E62-FE24A2C12E92
CrashReporter Key:   14aa0286b8b087d8b6a1ca75201a3f7d8c52d5bd
Hardware Model:      iPad1,1
Process:         XBMC [5693]
Path:            /var/mobile/Applications/
94088F35-1CDB-47CD-9D3C-328E39C2589F/XBMC.app/XBMC
Identifier:      XBMC
Version:         ??? (???)
Code Type:       ARM (Native)
Parent Process:  launchd [1]

Date/Time:       2011-04-10 11:52:44.575 +0200
OS Version:      iPhone OS 4.3.1 (8G4)
Report Version:  104

Exception Type:  EXC_BAD_ACCESS (SIGBUS)
Exception Codes: 0x00000032, 0x047001b0
Crashed Thread:  4

Thread 4 Crashed:
0   dyld                          	0x2fe1c8a0 strcmp + 0
1   dyld                          	0x2fe0ce32
 ImageLoaderMachO::parseLoadCmds() + 30
2   dyld                          	0x2fe1262c
 ImageLoaderMachOCompressed::instantiateFromFile(char const*, int,
    unsigned char const*, unsigned long long, unsigned long long,
     stat const&, unsigned int, unsigned int, linkedit_data_command const*,
      ImageLoader::LinkContext const&) + 228
3   dyld                          	0x2fe0da14
 ImageLoaderMachO::instantiateFromFile(char const*, int,
    unsigned char const*, unsigned long long, unsigned long long,
     stat const&, ImageLoader::LinkContext const&) + 348
4   dyld                          	0x2fe052e8
 dyld::loadPhase6(int, stat const&, char const*,
    dyld::LoadContext const&) + 576
5   dyld                          	0x2fe053fe
 dyld::loadPhase5stat(char const*, dyld::LoadContext const&, stat*,
    int*, bool*, std::vector<char const*, std::allocator<char const*> >*) + 174
6   dyld                          	0x2fe055b4
 dyld::loadPhase5(char const*, char const*, dyld::LoadContext const&,
    std::vector<char const*, std::allocator<char const*> >*) + 232
7   dyld                          	0x2fe057fe
 dyld::loadPhase4(char const*, char const*, dyld::LoadContext const&,
    std::vector<char const*, std::allocator<char const*> >*) + 302
8   dyld                          	0x2fe064b2
 dyld::loadPhase3(char const*, char const*, dyld::LoadContext const&,
    std::vector<char const*, std::allocator<char const*> >*) + 2514
9   dyld                          	0x2fe065d0
 dyld::loadPhase1(char const*, char const*, dyld::LoadContext const&,
    std::vector<char const*, std::allocator<char const*> >*) + 88
10  dyld                          	0x2fe06798
 dyld::loadPhase0(char const*, char const*, dyld::LoadContext const&,
    std::vector<char const*, std::allocator<char const*> >*) + 368
11  dyld                          	0x2fe0688e
 dyld::load(char const*, dyld::LoadContext const&) + 178
12  dyld                          	0x2fe08916 dlopen + 574
13  libdyld.dylib                 	0x3678b4ae dlopen + 30
14  XBMC                          	0x002276d4
 SoLoader::Load() (SoLoader.cpp:57)
15  XBMC                          	0x0002976c
 DllLoaderContainer::LoadDll(char const*, bool) (DllLoaderContainer.cpp:250)
16  XBMC                          	0x000299ce
 DllLoaderContainer::FindModule(char const*, char const*,
    bool) (DllLoaderContainer.cpp:147)
17  XBMC                          	0x00029cca
 DllLoaderContainer::LoadModule(char const*, char const*,
    bool) (DllLoaderContainer.cpp:115)
18  XBMC                          	0x0010c1a4
 CSectionLoader::LoadDLL(CStdStr<char> const&, bool,
    bool) (SectionLoader.cpp:138)
19  XBMC                          	0x000e9b10
 DllDynamic::Load() (DynamicDll.cpp:52)
20  XBMC                          	0x002096c6
 ADDON::CAddonMgr::Init() (AddonManager.cpp:215)
21  XBMC                          	0x004e447a
 CApplication::Create() (Application.cpp:644)
22  XBMC                          	0x00510e42
 -[XBMCEAGLView runAnimation:] (XBMCEAGLView.mm:312)
23  Foundation                    	0x3505b382
 -[NSThread main] + 38
24  Foundation                    	0x350cd5c6 __NSThread__main__ + 966
25  libsystem_c.dylib             	0x3035530a _pthread_start + 242
26  libsystem_c.dylib             	0x30356bb4 thread_start + 0

Thread 4 crashed with ARM Thread State:
    r0: 0x047001b0    r1: 0x2fe20ef0      r2: 0x01fe5f04      r3: 0x2fe116d1
    r4: 0x00000001    r5: 0x01a46740      r6: 0x00000000      r7: 0x01fe5264
    r8: 0x01a3f0fc    r9: 0x00000012     r10: 0x01fe6e60     r11: 0x00000007
    ip: 0x2fe262f8    sp: 0x01fe5234      lr: 0x2fe0ce39      pc: 0x2fe1c8a0
  cpsr: 0x00000010

Binary Images:
      0x1000 -   0xd98fff +XBMC armv7
        <d446ccbaefe96d237cfa331a4d8216b9>
         /var/mobile/Applications/94088F35-1CDB-47CD-9D3C-328E39C2589F/
         XBMC.app/XBMC
  0x2fe00000 - 0x2fe25fff  dyld armv7
    <8dbdf7bab30e355b81e7b2e333d5459b>
     /usr/lib/dyld
```

In this crash, we accessed bad memory at location `0x047001b0` as reported by the second value in the Crash Report Exception Codes section:
```
Exception Codes: 0x00000032, 0x047001b0
```

Note, this also appears as the value for register `r0` (often this is the case)

This is higher than the XBMC app binary image range, and lower than the `dyld`\index{command!dyld} range
according to the binary images section of the Crash Report.

This address must be mapped in, but we do not know what segment\index{memory!segment} it is mapped into from the Crash Report.

We can see this application can dynamically configure.  From the backtrace we see:
```
13  libdyld.dylib                 	0x3678b4ae dlopen + 30
14  XBMC                          	0x002276d4
 SoLoader::Load() (SoLoader.cpp:57)
```

It is calling the dynamic loader\index{file!dynamic loader} to load extra code based upon a configuration determined by an "AddOn" manager:
```
20  XBMC                          	0x002096c6
 ADDON::CAddonMgr::Init() (AddonManager.cpp:215)
```

The easiest way to diagnose such a problem is for the application to log its configuration before attempting to load optional software frameworks at runtime.  Possibly, application bundle\index{application!bundle} is missing the library we desire.

Sometimes we are integrating third party libraries that have dynamic code loading within them.  In such cases, we need to use the Xcode diagnostics facilities.

We do not have the source code for the XBMC application.  However, there is an open source example demonstrating the use of the dynamic loader.
@dynamicloadingeg

When we run this program, we can see informative messages in its use of the dynamic loader, as coded by the app.
Furthermore, can switch on _Dynamic Linker API Usage_ by editing the Scheme settings as follows:

![](screenshots/dynamic_loading.png)

When this program is launched, we can see how it dynamically loads modules.  We get system-generated messages in addition to our app messages.  The system messages do not have a timestamp prefix, but the app messages do.

Here is a trimmed debug log to show the kind of output we see:

```
2018-08-18 12:26:51.989237+0100 ios-dynamic-loading-framework[2962:109722]
 App started
2018-08-18 12:26:51.992187+0100 ios-dynamic-loading-framework[2962:109722]
 Before referencing CASHello in DynamicFramework1
dlopen(DynamicFramework1.framework/DynamicFramework1, 0x00000001)
2018-08-18 12:26:52.002234+0100 ios-dynamic-loading-framework[2962:109722]
 Loading CASHello in dynamic-framework-1
  dlopen(DynamicFramework1.framework/DynamicFramework1) ==> 0x600000157ce0
2018-08-18 12:26:52.002398+0100 ios-dynamic-loading-framework[2962:109722]
 Loaded CASHello in DynamicFramework1
dlclose(0x600000157ce0)
2018-08-18 12:26:52.002560+0100 ios-dynamic-loading-framework[2962:109722]
 CASHello from DynamicFramework1 still loaded after dlclose()
2018-08-18 12:26:52.002642+0100 ios-dynamic-loading-framework[2962:109722]
 Before referencing CASHello in DynamicFramework2
dlopen(DynamicFramework2.framework/DynamicFramework2, 0x00000001)
objc[2962]: Class CASHello is implemented in both /Users/faisalm/Library/
Developer/Xcode/DerivedData/
ios-dynamic-loading-framework-ednexaanxalgpudjcqeuejsdmhlq/Build
/Products/Debug-iphonesimulator/
DynamicFramework1.framework/DynamicFramework1 (0x1229cb178) and
 /Users/faisalm/Library/Developer/Xcode/DerivedData/
ios-dynamic-loading-framework-ednexaanxalgpudjcqeuejsdmhlq/Build
/Products/Debug-iphonesimulator/DynamicFramework2.framework/DynamicFramework2
 (0x1229d3178). One of the two will be used. Which one is undefined.
2018-08-18 12:26:52.012601+0100 ios-dynamic-loading-framework[2962:109722]
 Loading CASHello in dynamic-framework-2
  dlopen(DynamicFramework2.framework/DynamicFramework2) ==> 0x600000157d90
2018-08-18 12:26:52.012792+0100 ios-dynamic-loading-framework[2962:109722]
 Loaded CASHello in DynamicFramework2
dlclose(0x600000157d90)
2018-08-18 12:26:52.012921+0100 ios-dynamic-loading-framework[2962:109722]
 CASHello from DynamicFramework2 still loaded after dlclose()
```

Here is the relevant source code for loading `DynamicFramework1`

```
-(void)loadCASHelloFromDynamicFramework1
{
    void *framework1Handle = dlopen(
      "DynamicFramework1.framework/DynamicFramework1", RTLD_LAZY);

    if (NSClassFromString(@"CASHello"))
    {
        NSLog(@"Loaded CASHello in DynamicFramework1");
    }
    else
    {
        NSLog(@"Could not load CASHello in DynamicFramework1");
    }

    dlclose(framework1Handle);

    if (NSClassFromString(@"CASHello"))
    {
        NSLog(@"CASHello from DynamicFramework1 still loaded after dlclose()");
    }
    else
    {
        NSLog(@"Unloaded DynamicFramework1");
    }
}
```

Here is the `viewDidLoad` code that calls it:
```
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Loading the first dynamic library here works fine :)
    NSLog(@"Before referencing CASHello in DynamicFramework1");
    [self loadCASHelloFromDynamicFramework1];

    /*
     Loading the second framework will give a message in the console saying
     that both classes will be loaded and referencing the class will result
     in undefined behavior.
    */

    NSLog(@"Before referencing CASHello in DynamicFramework2");
    [self loadCASHelloFromDynamicFramework2];
}
```

In general, if our app crashes before it even has run any code in our app, then it is good to switch on the Dynamic Loader diagnostic flags.  There might be a deployment\index{software!deployment} issue (not bundling the correct libraries) or code signing\index{software!code signing} issue.
