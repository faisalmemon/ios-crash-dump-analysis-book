## Kindle Create Crash

Kindle Create\index{trademark!Kindle Create} is an application used by authors to create e-books from manuscripts, such as `docx` files.  It makes heavy use of graphics via the QuartzCore\index{library!QuartzCore} library.

When previewing for publication it crashed with the following crash report, truncated for ease of demonstration:

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

Crashed Thread:        16  Dispatch queue: com.apple.root.default-qos

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Application Specific Information:
abort() called

Application Specific Signatures:
Graphics kernel error: 0xfffffffb

Thread 16 Crashed:: Dispatch queue: com.apple.root.default-qos
0   libsystem_kernel.dylib        	0xa73e7ed6 __pthread_kill + 10
1   libsystem_pthread.dylib       	0xa75a0427 pthread_kill + 363
2   libsystem_c.dylib             	0xa7336956 abort + 133
3   libGPUSupportMercury.dylib    	0xa2aa342d gpusGenerateCrashLog + 160
4   com.apple.AMDRadeonX4000GLDriver	0x180cbb00 gpusKillClientExt + 23
5   libGPUSupportMercury.dylib    	0xa2aa4857 gpusSubmitDataBuffers + 157
6   com.apple.AMDRadeonX4000GLDriver	0x180a293c
 glrATI_Hwl_SubmitPacketsWithToken + 143
7   com.apple.AMDRadeonX4000GLDriver	0x180fd9b0 glrFlushContextToken + 68
8   libGPUSupportMercury.dylib    	0xa2aa88c8 gldFlushContext + 24
9   GLEngine                      	0x9b416f5b glFlushRender_Exec + 37
10  com.apple.QuartzCore          	0x9c1c8412
 CA::(anonymous namespace)::IOSurface::detach() + 166
11  com.apple.QuartzCore          	0x9c1c7631
 CAOpenGLLayerDraw(CAOpenGLLayer*, double, CVTimeStamp const*,
    unsigned int) + 1988
12  com.apple.QuartzCore          	0x9c1c6c9a -[CAOpenGLLayer _display] + 618
13  com.apple.QuartzCore          	0x9c179f62 -[CALayer display] + 158
14  com.apple.AppKit              	0x916106ac -[NSOpenGLLayer display] + 305
15  com.apple.QuartzCore          	0x9c1c9f77
 display_callback(void*, void*) + 59
16  com.apple.QuartzCore          	0x9c1c9efa
 CA::DispatchGroup::dispatch(bool) + 88
17  com.apple.QuartzCore          	0x9c1c9e9a
 CA::DispatchGroup::callback_0(void*) + 16
18  libdispatch.dylib             	0xa72565dd _dispatch_client_callout + 50
19  libdispatch.dylib             	0xa7263679
 _dispatch_queue_override_invoke + 779
20  libdispatch.dylib             	0xa725818b _dispatch_root_queue_drain + 660
21  libdispatch.dylib             	0xa7257ea5 _dispatch_worker_thread3 + 100
22  libsystem_pthread.dylib       	0xa759cfa5 _pthread_wqthread + 1356
23  libsystem_pthread.dylib       	0xa759ca32 start_wqthread + 34

Thread 16 crashed with X86 Thread State (32-bit):
  eax: 0x00000000  ebx: 0xb0a79000  ecx: 0xb0a78acc  edx: 0x00000000
  edi: 0xa75a02ca  esi: 0x0000002d  ebp: 0xb0a78af8  esp: 0xb0a78acc
   ss: 0x00000023  efl: 0x00000206  eip: 0xa73e7ed6   cs: 0x0000000b
   ds: 0x00000023   es: 0x00000023   fs: 0x00000023   gs: 0x0000000f
  cr2: 0xa9847340

Logical CPU:     0
Error Code:      0x00080148
Trap Number:     132

Binary Images:

0x18099000 - 0x1815efff  com.apple.AMDRadeonX4000GLDriver (1.68.20 - 1.6.8)
 <DF3BB959-0C0A-3B6C-8E07-11B332128555>
  /System/Library/Extensions/AMDRadeonX4000GLDriver.bundle/
  Contents/MacOS/AMDRadeonX4000GLDriver

0xa2aa2000 - 0xa2aacfff  libGPUSupportMercury.dylib (16.7.4)
 <C71E29CF-D4C5-391D-8B7B-739FB0536387>
  /System/Library/PrivateFrameworks/GPUSupport.framework/
  Versions/A/Libraries/libGPUSupportMercury.dylib

```

From the stack backtrace we see that the OpenGL\index{OpenGL} pipeline was flushed.
This caused `com.apple.AMDRadeonX4000GLDriver` to detect a problem with the
commands and trigger a crash.  We see that the code contributes custom information to the crash report.

```
3   libGPUSupportMercury.dylib    	0xa2aa342d gpusGenerateCrashLog + 160
```

We can use the Hopper\index{Hopper} Disassembler and
reverse engineering\index{software!reverse engineering} tool here.  
By locating the binary on our Mac,
we can ask Hopper to not only dissemble the code in question, but to also produce pseudocode\index{pseudocode}.
For most developers, keeping an understanding of assembly code fresh in the mind is difficult because assembly code\index{software!assembly code} is rarely hand written nowadays.  This is why the pseudocode output is most valuable.

We first find the location of the binary from the `Binary Images` section of the crash report.
```
/System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/Libraries/libGPUSupportMercury.dylib
```

Traversing the file hierarchy can be cumbersome for system binaries as they are deeply nested in the file system.

If Hopper is **already running**, a quick way to select the correct file is to use the command line\index{command!hopper}.

```
'/Applications/Hopper Disassembler v4.app/Contents/MacOS/hopper' \
 -e /System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/
 Libraries/libGPUSupportMercury.dylib
```

If Hopper is not running, we can launch it.  Alongside we can launch the Finder program and select 'Go To Folder' to select the folder `/System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/Libraries/`

![](screenshots/finder_support_mercury.png)

Then we can simply drag `libGPUSupportMercury.dylib` from the Finder into the main panel of the Hopper App and it will start processing the file.

![](screenshots/drag_file_to_hopper.png)

We need to select the architecture to disassemble.  It must match what we are diagnosing.
From the crash report, we can see that it is a `Code Type` `X86 (Native)`.\index{CPU!32-bit X86}
This means we need to select the 32-bit architecture option in Hopper.

![](screenshots/hopper_32bit.png)

The we click Next, and then OK.

After a moment, the file will be processed.  Then we can select _Navigate -> Go To Address or Symbol_
and provide the address `_gpusGenerateCrashLog`  Note, we have a leading underscore.  The C compiler puts that in automatically before generating the object file.  Historically it was done that way so that hand written assembly code would not conflict with C programming language symbols during linking\index{linker!underscore policy}.

In the default view, Hopper will show the disassembly for the function.

![](screenshots/hopper_diss.png)

By selecting the pseudocode button, shown circled in red, we get Hopper to produce a more easily understandable description of the function.

![](screenshots/hopper_pseudocode.png)

Here is the output of hopper:

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
     rdx = "Graphics kernel error: 0x%08x\n";
   }  
   else {
     rdx = "Graphics hardware encountered an error and was reset: 0x%08x\n";
   }  
   sprintf_l(var_A0, 0x0, rdx);
   *0xc680 = var_A0;
   rax = abort();
 }
 return rax;
}

```

Here we can see two alternatives.  Either we just report:
`"Graphics kernel error: 0x%08x\n"`

or we report:
`"Graphics hardware encountered an error and was reset: 0x%08x\n"`

In fact, we see the following in the crash report:
```
Application Specific Signatures:
Graphics kernel error: 0xfffffffb
```

Unfortunately, it is not clear what this error means.  We need the author of the app to switch on OpenGL command level logging in order to understand what drawing command was rejected by the graphics driver.

Using a different Mac with a different graphics card would be an interesting experiment to understand if we have a driver-specific issue or a general OpenGL problem.
