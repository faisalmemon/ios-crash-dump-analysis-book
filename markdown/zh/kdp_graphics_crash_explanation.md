## Kindle Create 崩溃

Kindle Create是一款应用程序，作者可以利用手稿(比如 `docx` 文件)创建电子书。它通过 QuartzCore 库进行大量的绘制。 

在发布预览时，它发生崩溃并产生以下崩溃报告，为便于演示，将其截断：

```
Process:               Kindle Create [3010]
Path:                  /Applications/Kindle Create.app/
Contents/MacOS/Kindle Create
Identifier:            com.amazon.kc
Version:               1.10 (1.10)
Code Type:             X86 (Native)
Parent Process:        ??? [1]
Responsible:           Kindle Create [3010]
User ID:               501

Crashed Thread:        16  Dispatch queue:
 com.apple.root.default-qos

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Application Specific Information:
abort() called

Application Specific Signatures:
Graphics kernel error: 0xfffffffb

Thread 16 Crashed:: Dispatch queue: com.apple.root.default-qos
0   libsystem_kernel.dylib        	0xa73e7ed6
__pthread_kill + 10
1   libsystem_pthread.dylib       	0xa75a0427
pthread_kill + 363
2   libsystem_c.dylib             	0xa7336956
abort + 133
3   libGPUSupportMercury.dylib    	0xa2aa342d
 gpusGenerateCrashLog + 160
4   com.apple.AMDRadeonX4000GLDriver	0x180cbb00
 gpusKillClientExt + 23
5   libGPUSupportMercury.dylib    	0xa2aa4857
 gpusSubmitDataBuffers + 157
6   com.apple.AMDRadeonX4000GLDriver	0x180a293c
 glrATI_Hwl_SubmitPacketsWithToken + 143
7   com.apple.AMDRadeonX4000GLDriver	0x180fd9b0
 glrFlushContextToken + 68
8   libGPUSupportMercury.dylib    	0xa2aa88c8
 gldFlushContext + 24
9   GLEngine                      	0x9b416f5b
 glFlushRender_Exec + 37
10  com.apple.QuartzCore          	0x9c1c8412
 CA::(anonymous namespace)::IOSurface::detach() + 166
11  com.apple.QuartzCore          	0x9c1c7631
 CAOpenGLLayerDraw(CAOpenGLLayer*, double, CVTimeStamp const*,
    unsigned int) + 1988
12  com.apple.QuartzCore          	0x9c1c6c9a
 -[CAOpenGLLayer _display] + 618
13  com.apple.QuartzCore          	0x9c179f62
 -[CALayer display] + 158
14  com.apple.AppKit              	0x916106ac
 -[NSOpenGLLayer display] + 305
15  com.apple.QuartzCore          	0x9c1c9f77
 display_callback(void*, void*) + 59
16  com.apple.QuartzCore          	0x9c1c9efa
 CA::DispatchGroup::dispatch(bool) + 88
17  com.apple.QuartzCore          	0x9c1c9e9a
 CA::DispatchGroup::callback_0(void*) + 16
18  libdispatch.dylib             	0xa72565dd
 _dispatch_client_callout + 50
19  libdispatch.dylib             	0xa7263679
 _dispatch_queue_override_invoke + 779
20  libdispatch.dylib             	0xa725818b
 _dispatch_root_queue_drain + 660
21  libdispatch.dylib             	0xa7257ea5
 _dispatch_worker_thread3 + 100
22  libsystem_pthread.dylib       	0xa759cfa5
 _pthread_wqthread + 1356
23  libsystem_pthread.dylib       	0xa759ca32
 start_wqthread + 34

Thread 16 crashed with X86 Thread State (32-bit):
  eax: 0x00000000  ebx: 0xb0a79000  ecx: 0xb0a78acc
    edx: 0x00000000
  edi: 0xa75a02ca  esi: 0x0000002d  ebp: 0xb0a78af8
    esp: 0xb0a78acc
   ss: 0x00000023  efl: 0x00000206  eip: 0xa73e7ed6
      cs: 0x0000000b
   ds: 0x00000023   es: 0x00000023   fs: 0x00000023
      gs: 0x0000000f
  cr2: 0xa9847340

Logical CPU:     0
Error Code:      0x00080148
Trap Number:     132

Binary Images:

0x18099000 - 0x1815efff  com.apple.AMDRadeonX4000GLDriver
 (1.68.20 - 1.6.8)
 <DF3BB959-0C0A-3B6C-8E07-11B332128555>
  /System/Library/Extensions/AMDRadeonX4000GLDriver.bundle/
  Contents/MacOS/AMDRadeonX4000GLDriver

0xa2aa2000 - 0xa2aacfff  libGPUSupportMercury.dylib
 (16.7.4)
 <C71E29CF-D4C5-391D-8B7B-739FB0536387>
  /System/Library/PrivateFrameworks/GPUSupport.framework/
  Versions/A/Libraries/libGPUSupportMercury.dylib

```

从堆栈回溯中可以看到 OpenGL 管道已刷新。
这导致 `com.apple.AMDRadeonX4000GLDriver` 检测到命令问题并触发崩溃。 我们看到该代码为崩溃报告提供了自定义信息。

```
3   libGPUSupportMercury.dylib    	0xa2aa342d
 gpusGenerateCrashLog + 160
```

我们可以在这里使用 Hopper 脱壳和逆向工程工具。

通过在我们的Mac上找到二进制文件，我们可以要求Hopper不仅分解有问题的代码，而且还生成伪代码。对于大多数开发人员来说，很难立即了解汇编代码，因为当今很少使用汇编代码。这就是伪代码最有价值的原因。

我们首先从崩溃报告的 `Binary Images`  部分找到二进制文件的位置。
```
/System/Library/PrivateFrameworks/GPUSupport.framework/
Versions/A/Libraries/libGPUSupportMercury.dylib
```

对于系统二进制文件而言，遍历文件层次结构可能会很麻烦，因为它们深深地嵌套在文件系统中。

如果 Hopper 已经**正在运行**，那么快速选择正确文件的方法是使用命令行。

```
'/Applications/Hopper Disassembler v4.app/Contents/
MacOS/hopper' -e /System/Library/PrivateFrameworks/
GPUSupport.framework/Versions/A/Libraries/
libGPUSupportMercury.dylib
```

如果Hopper没有运行，我们可以启动它。我们可以启动 Finder 程序并选择 'Go To Folder' 以选择文件夹
```
/System/Library/PrivateFrameworks/GPUSupport.framework/
Versions/A/Libraries/
```

![](screenshots/finder_support_mercury.png)

然后，我们可以简单地将`libGPUSupportMercury.dylib`从 Finder 中拖到 Hopper 应用的主面板中，它将开始处理文件。

![](screenshots/drag_file_to_hopper.png)

我们需要选择要脱壳的体系结构。 它必须与我们正在诊断的内容匹配。从崩溃报告中我们可以看到它是 `Code Type` `X86 (Native)`，这意味着我们需要在 Hopper 中选择32位体系结构选项。

![](screenshots/hopper_32bit.png)

然后我们点击 Next，然后点击 OK

片刻之后，文件将被处理。 然后我们可以选择 _Navigate -> Go To Address or Symbol_ 并提供地址 `_gpusGenerateCrashLog` 。注意，下划线是在前面的。 C 编译器会在生成目标文件之前自动将其放入。 在过去，这样做是为了使手写的汇编代码在链接期间不会与C 语言符号冲突。

在默认视图中，Hopper 将显示该功能的反汇编代码。

![](screenshots/hopper_diss.png)

通过选择伪代码按钮（用红色圆圈显示），我们可以使 Hopper 生成对该功能的更容易理解的描述。

![](screenshots/hopper_pseudocode.png)

这是 Hopper 的输出：

```
int _gpusGenerateCrashLog(int arg0, int arg1, int arg2) {
 rdi = arg0;
 r14 = arg2;
 rbx = arg1;
 if (*0xc678 != 0x0) {
   rax = *___stack_chk_guard;
   if (rax != *___stack_chk_guard) {
     rax = __stack_chk_fail();
   }  
 }
 else {
   if (rdi != 0x0) {
     IOAccelDeviceGetName(*(rdi + 0x230), 0x0, 0x14);
   }  
   if ((rbx & 0x20000000) == 0x0) {
     rdx =
     "Graphics kernel error: 0x%08x\n";
   }  
   else {
     rdx =
  "Graphics hardware encountered an error and was reset:
   0x%08x\n";
   }  
   sprintf_l(var_A0, 0x0, rdx);
   *0xc680 = var_A0;
   rax = abort();
 }
 return rax;
}

```

在这里，我们可以看到两种报文。一种是 ：
```
"Graphics kernel error: 0x%08x\n"
```

另一种是:
```
"Graphics hardware encountered an error and was reset: 0x%08x\n"
```

实际上，我们在崩溃报告中看到以下内容：
```
Application Specific Signatures:
Graphics kernel error: 0xfffffffb
```

不幸的是，尚不清楚此错误是什么意思。 我们需要应用程序的作者打开OpenGL命令级日志记录，以便了解图形驱动程序拒绝了哪些绘图命令。

通过使用不同的 Mac 和显卡配置将会是实验变得很有趣。让我们判断这是一个是特定的驱动问题，或一个通用的 OpenGL 问题。
