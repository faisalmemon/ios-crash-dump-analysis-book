### xbmc 崩溃

`xbmc` 应用程序是一款实用程序应用程序，其作用类似于电视媒体播放器的遥控器。

在启动过程中，应用程序发生崩溃并产生以下崩溃报告，为便于演示，该报告已被截断：

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
 ImageLoaderMachOCompressed::instantiateFromFile
 (char const*, int,
    unsigned char const*, unsigned long long,
     unsigned long long,
     stat const&, unsigned int, unsigned int,
      linkedit_data_command const*,
      ImageLoader::LinkContext const&) + 228
3   dyld                          	0x2fe0da14
 ImageLoaderMachO::instantiateFromFile
 (char const*, int,
    unsigned char const*, unsigned long long,
     unsigned long long,
     stat const&, ImageLoader::LinkContext const&) + 348
4   dyld                          	0x2fe052e8
 dyld::loadPhase6(int, stat const&, char const*,
    dyld::LoadContext const&) + 576
5   dyld                          	0x2fe053fe
 dyld::loadPhase5stat(char const*,
    dyld::LoadContext const&, stat*,
    int*, bool*, std::vector<char const*,
    std::allocator<char const*> >*) + 174
6   dyld                          	0x2fe055b4
 dyld::loadPhase5(char const*, char const*,
    dyld::LoadContext const&,
    std::vector<char const*,
     std::allocator<char const*> >*) + 232
7   dyld                          	0x2fe057fe
 dyld::loadPhase4(char const*, char const*,
   dyld::LoadContext const&,
    std::vector<char const*,
    std::allocator<char const*> >*) + 302
8   dyld                          	0x2fe064b2
 dyld::loadPhase3(char const*, char const*,
   dyld::LoadContext const&,
    std::vector<char const*,
    std::allocator<char const*> >*) + 2514
9   dyld                          	0x2fe065d0
 dyld::loadPhase1(char const*, char const*,
   dyld::LoadContext const&,
    std::vector<char const*,
    std::allocator<char const*> >*) + 88
10  dyld                          	0x2fe06798
 dyld::loadPhase0(char const*, char const*,
   dyld::LoadContext const&,
    std::vector<char const*,
    std::allocator<char const*> >*) + 368
11  dyld                          	0x2fe0688e
 dyld::load(char const*, dyld::LoadContext const&) + 178
12  dyld                          	0x2fe08916 dlopen + 574
13  libdyld.dylib                 	0x3678b4ae dlopen + 30
14  XBMC                          	0x002276d4
 SoLoader::Load() (SoLoader.cpp:57)
15  XBMC                          	0x0002976c
 DllLoaderContainer::LoadDll(char const*, bool)
  (DllLoaderContainer.cpp:250)
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
24  Foundation                    	
0x350cd5c6 __NSThread__main__ + 966
25  libsystem_c.dylib             	
0x3035530a _pthread_start + 242
26  libsystem_c.dylib             	
0x30356bb4 thread_start + 0

Thread 4 crashed with ARM Thread State:
    r0: 0x047001b0    r1: 0x2fe20ef0      r2: 0x01fe5f04
          r3: 0x2fe116d1
    r4: 0x00000001    r5: 0x01a46740      r6: 0x00000000
         r7: 0x01fe5264
    r8: 0x01a3f0fc    r9: 0x00000012     r10: 0x01fe6e60
         r11: 0x00000007
    ip: 0x2fe262f8    sp: 0x01fe5234      lr: 0x2fe0ce39
          pc: 0x2fe1c8a0
  cpsr: 0x00000010

Binary Images:
      0x1000 -   0xd98fff +XBMC armv7
        <d446ccbaefe96d237cfa331a4d8216b9>
         /var/mobile/Applications/
         94088F35-1CDB-47CD-9D3C-328E39C2589F/
         XBMC.app/XBMC
  0x2fe00000 - 0x2fe25fff  dyld armv7
    <8dbdf7bab30e355b81e7b2e333d5459b>
     /usr/lib/dyld
```

在此崩溃案例中，我们通过崩溃报告异常代码部分的第二个值说明了在位置`0x047001b0` 处的错误内存：
```
Exception Codes: 0x00000032, 0x047001b0
```

注意，这也显示为寄存器 `r0` 的值（通常是这种情况）

这个值高于 XBMC 应用程序的二进制映射范围，低于崩溃报告的二进制映射部分中的 `dyld` 范围。

该地址必须映射到其中，但我们不知道崩溃报告将其映射到哪个段。

我们可以看到该应用程序可以动态配置。 从回溯中我们可以看到：
```
13  libdyld.dylib                 	0x3678b4ae dlopen + 30
14  XBMC                          	0x002276d4
 SoLoader::Load() (SoLoader.cpp:57)
```

它正在调用动态加载程序，并根据 “AddOn” 管理器确定配置加载额外的代码：
```
20  XBMC                          	0x002096c6
 ADDON::CAddonMgr::Init() (AddonManager.cpp:215)
```

诊断此类问题的最简单方法是让应用程序在尝试在运行时加载可选软件框架之前记录其配置。 应用程序包可能缺少我们想要的库。

有时我们会集成第三方库，这些库中具有动态代码加载功能。 在这种情况下，我们需要使用 Xcode 诊断工具。

我们没有XBMC应用程序的源代码。 但是，有一个开源示例演示了动态加载程序的使用。 @dynamicloadingeg

当我们运行该程序时，我们可以在应用程序编码的动态加载程序的使用中看到有用的消息。
此外，我们可以通过如下修改 Scheme 设置,  _Dynamic Linker API Usage_  :

![](screenshots/dynamic_loading.png)

启动该程序后，我们可以看到它如何动态加载模块。 除了我们的应用程序消息外，我们还会收到系统生成的消息。 系统消息没有时间戳前缀，但应用程序消息却有。

这是一个经过修剪的调试日志，显示了我们看到的输出类型:

```
2018-08-18 12:26:51.989237+0100
 ios-dynamic-loading-framework[2962:109722]
 App started
2018-08-18 12:26:51.992187+0100
 ios-dynamic-loading-framework[2962:109722]
 Before referencing CASHello in DynamicFramework1
dlopen(DynamicFramework1.framework/DynamicFramework1, 0x00000001)
2018-08-18 12:26:52.002234+0100
 ios-dynamic-loading-framework[2962:109722]
 Loading CASHello in dynamic-framework-1
  dlopen(DynamicFramework1.framework/DynamicFramework1) ==>
   0x600000157ce0
2018-08-18 12:26:52.002398+0100
 ios-dynamic-loading-framework[2962:109722]
 Loaded CASHello in DynamicFramework1
dlclose(0x600000157ce0)
2018-08-18 12:26:52.002560+0100
 ios-dynamic-loading-framework[2962:109722]
 CASHello from DynamicFramework1 still loaded after dlclose()
2018-08-18 12:26:52.002642+0100
 ios-dynamic-loading-framework[2962:109722]
 Before referencing CASHello in DynamicFramework2
dlopen(DynamicFramework2.framework/DynamicFramework2, 0x00000001)
objc[2962]: Class CASHello is implemented in both
 /Users/faisalm/Library/
Developer/Xcode/DerivedData/
ios-dynamic-loading-framework-ednexaanxalgpudjcqeuejsdmhlq/Build
/Products/Debug-iphonesimulator/
DynamicFramework1.framework/DynamicFramework1 (0x1229cb178)
 and
 /Users/faisalm/Library/Developer/Xcode/DerivedData/
ios-dynamic-loading-framework-ednexaanxalgpudjcqeuejsdmhlq/Build
/Products/Debug-iphonesimulator/DynamicFramework2.framework/
DynamicFramework2
 (0x1229d3178).
 One of the two will be used. Which one is undefined.
2018-08-18 12:26:52.012601+0100
 ios-dynamic-loading-framework[2962:109722]
 Loading CASHello in dynamic-framework-2
  dlopen(DynamicFramework2.framework/DynamicFramework2) ==>
   0x600000157d90
2018-08-18 12:26:52.012792+0100
 ios-dynamic-loading-framework[2962:109722]
 Loaded CASHello in DynamicFramework2
dlclose(0x600000157d90)
2018-08-18 12:26:52.012921+0100
 ios-dynamic-loading-framework[2962:109722]
 CASHello from DynamicFramework2 still loaded after dlclose()
```

这是加载 `DynamicFramework1`的相关源代码。

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
        NSLog(
  @"CASHello from DynamicFramework1 still loaded after dlclose()"
        );
    }
    else
    {
        NSLog(@"Unloaded DynamicFramework1");
    }
}
```

这是在的 `viewDidLoad` 中调用它的代码：
```
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Loading the first dynamic library here works fine :)
    NSLog(@"Before referencing CASHello in DynamicFramework1");
    [self loadCASHelloFromDynamicFramework1];

    /*
     Loading the second framework will give a message in
      the console saying that both classes will be loaded
      and referencing the class will result in undefined
      behavior.
    */

    NSLog(@"Before referencing CASHello in DynamicFramework2");
    [self loadCASHelloFromDynamicFramework2];
}
```

通常，如果我们的应用在运行任何代码之前就崩溃了，那么最好打开 Dynamic Loader 诊断选项。这可能是部署问题（未捆绑正确的库）或代码签名问题。
