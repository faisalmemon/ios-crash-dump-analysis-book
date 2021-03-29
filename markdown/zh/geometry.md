## “非数字” 错误

在本节中，我们将展示由于错误的浮点数据而导致的崩溃。

我们以 macOS 上的 `securityAgent` 崩溃为例。 

我们看到的崩溃报告如下，为了便于演示而对报告内容进行截断：

```
Process:               SecurityAgent [99429]
Path:                  /System/Library/Frameworks/
Security.framework/Versions/A/MachServices/
SecurityAgent.bundle/Contents/
MacOS/SecurityAgent
Identifier:            com.apple.SecurityAgent
Version:               9.0 (55360.50.13)
Build Info:            SecurityAgent-55360050013000000~642
Code Type:             X86-64 (Native)
Parent Process:        launchd [1]
Responsible:           SecurityAgent [99429]
User ID:               92

Date/Time:             2018-06-18 21:39:08.261 +0100
OS Version:            Mac OS X 10.13.4 (17E202)
Report Version:        12
Anonymous UUID:        00CC683B-425F-ABF0-515A-3ED73BACDDB5

Sleep/Wake UUID:       8D3EF33B-B78C-4C76-BB7B-2F2AC3A11CEB

Time Awake Since Boot: 350000 seconds
Time Since Wake:       42 seconds

System Integrity Protection: enabled

Crashed Thread:        0  Dispatch queue:
 com.apple.main-thread

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Application Specific Information:
*** Terminating app due to uncaught exception
'CALayerInvalidGeometry', reason:
 'CALayer bounds contains NaN: [nan nan; 1424 160]'
terminating with uncaught exception of type NSException
abort() called

Application Specific Backtrace 1:
0   CoreFoundation                      0x00007fff4590132b
 __exceptionPreprocess + 171
1   libobjc.A.dylib                     0x00007fff6cf7bc76
objc_exception_throw + 48
2   CoreFoundation                      0x00007fff45992dcd
+[NSException raise:format:] + 205
3   QuartzCore                          0x00007fff50ba1a72
_ZN2CA5Layer10set_boundsERKNS_4RectEb + 230
4   QuartzCore                          0x00007fff50ba190b
-[CALayer setBounds:] + 251
5   AppKit                              0x00007fff42e5ccad
-[_NSClipViewBackingLayer setBounds:] + 105
6   AppKit                              0x00007fff42e20bf0
 -[NSView(NSInternal) _updateLayerGeometryFromView] + 712
7   AppKit                              0x00007fff42eef7a2
-[NSView translateOriginToPoint:] + 191
8   AppKit                              0x00007fff42eef383
-[NSClipView _immediateScrollToPoint:] + 536
9   AppKit                              0x00007fff432c4de9
-[NSScrollAnimationHelper _doFinalAnimationStep] + 147
10  AppKit                              0x00007fff43226da2
-[NSAnimationHelper _stopRun] + 44
11  AppKit                              0x00007fff42eef089
-[NSClipView scrollToPoint:] + 202
12  AppKit                              0x00007fff42f2ab7f
-[NSScrollView scrollClipView:toPoint:] + 75
13  AppKit                              0x00007fff42ed5929
-[NSClipView _scrollTo:animateScroll:
flashScrollerKnobs:] + 1273
14  AppKit                              0x00007fff434d5750
 -[_NSScrollingConcurrentMainThreadSynchronizer
_scrollToCanonicalOrigin] + 935
15  AppKit                              0x00007fff43071d74
 -[_NSScrollingConcurrentMainThreadSynchronizer
_synchronize:completionHandler:] + 174
16  AppKit                              0x00007fff43071c94
 __80-[_NSScrollingConcurrentMainThreadSynchronizer
initWithSharedData:constantData:]_block_invoke + 145
17  libdispatch.dylib                   0x00007fff6db5be08
_dispatch_client_callout + 8
18  libdispatch.dylib                   0x00007fff6db6eed1
_dispatch_continuation_pop + 472
19  libdispatch.dylib                   0x00007fff6db5e0d1
_dispatch_source_invoke + 620
20  libdispatch.dylib                   0x00007fff6db67271
_dispatch_main_queue_callback_4CF + 776
21  CoreFoundation                      0x00007fff458b9c69
 __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__ + 9
22  CoreFoundation                      0x00007fff4587be4a
 __CFRunLoopRun + 2586
23  CoreFoundation                      0x00007fff4587b1a3
CFRunLoopRunSpecific + 483
24  HIToolbox                           0x00007fff44b63d96
RunCurrentEventLoopInMode + 286
25  HIToolbox                           0x00007fff44b63b06
ReceiveNextEventCommon + 613
26  HIToolbox                           0x00007fff44b63884
 _BlockUntilNextEventMatchingListInModeWithFilter + 64
27  AppKit                              0x00007fff42e16a73
 _DPSNextEvent + 2085
28  AppKit                              0x00007fff435ace34
 -[NSApplication(NSEvent) _nextEventMatchingEventMask:
 untilDate:inMode:dequeue:] + 3044
29  AppKit                              0x00007fff42e0b885
 -[NSApplication run] + 764
30  AppKit                              0x00007fff42ddaa72
 NSApplicationMain + 804
31  SecurityAgent                       0x00000001007bb8b8
 main + 475
32  libdyld.dylib                       0x00007fff6db95015
 start + 1

Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	0x00007fff6dce5b6e
 __pthread_kill + 10
1   libsystem_pthread.dylib       	0x00007fff6deb0080
 pthread_kill + 333
2   libsystem_c.dylib             	0x00007fff6dc411ae
 abort + 127
3   libc++abi.dylib               	0x00007fff6bb45f8f
 abort_message + 245
4   libc++abi.dylib               	0x00007fff6bb4612b
default_terminate_handler() + 265
5   libobjc.A.dylib               	0x00007fff6cf7dea3
 _objc_terminate() + 97
6   libc++abi.dylib               	0x00007fff6bb617c9
 std::__terminate(void (*)()) + 8
7   libc++abi.dylib               	0x00007fff6bb61843
 std::terminate() + 51
8   libdispatch.dylib             	0x00007fff6db5be1c
_dispatch_client_callout + 28
9   libdispatch.dylib             	0x00007fff6db6eed1
 _dispatch_continuation_pop + 472
10  libdispatch.dylib             	0x00007fff6db5e0d1
_dispatch_source_invoke + 620
11  libdispatch.dylib             	0x00007fff6db67271
_dispatch_main_queue_callback_4CF + 776
12  com.apple.CoreFoundation      	0x00007fff458b9c69
 __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__ + 9
13  com.apple.CoreFoundation      	0x00007fff4587be4a
 __CFRunLoopRun + 2586
14  com.apple.CoreFoundation      	0x00007fff4587b1a3
CFRunLoopRunSpecific + 483
15  com.apple.HIToolbox           	0x00007fff44b63d96
RunCurrentEventLoopInMode + 286
16  com.apple.HIToolbox           	0x00007fff44b63b06
ReceiveNextEventCommon + 613
17  com.apple.HIToolbox           	0x00007fff44b63884
 _BlockUntilNextEventMatchingListInModeWithFilter + 64
18  com.apple.AppKit              	0x00007fff42e16a73
 _DPSNextEvent + 2085
19  com.apple.AppKit              	0x00007fff435ace34
 -[NSApplication(NSEvent)
 _nextEventMatchingEventMask:untilDate:inMode:dequeue:]
  + 3044
20  com.apple.AppKit              	0x00007fff42e0b885
-[NSApplication run] + 764
21  com.apple.AppKit              	0x00007fff42ddaa72
 NSApplicationMain + 804
22  com.apple.SecurityAgent       	0x00000001007bb8b8
 main + 475
23  libdyld.dylib                 	0x00007fff6db95015
 start + 1
```

这次崩溃是一个很好的示例，崩溃报告的信息部分提示了具体的错误信息。我们马上就知道在我们的层边界中有NAN（不是数字）浮点值，这就是中止的原因。

```
'CALayer bounds contains NaN: [nan nan; 1424 160]'
```

可能尚未初始化数据结构，或者发生了除零的情况。几何代码通常会创建宽高比。在启动或转折情况下，我们的帧可能为零，从而导致除以零错误，从而在我们的数据结构中产生NAN值。

我们注意到 Quartz（几何图形框架）使用了一些长函数。 在堆栈回溯中，我们看到：

```
3   QuartzCore                          0x00007fff50ba1a72
_ZN2CA5Layer10set_boundsERKNS_4RectEb + 230
```

作为一项学术练习，我们可以指出在许多错误处理案例中，哪一个在这里发挥作用。我们这里的回溯并不是叶子调用，所以偏移量是函数调用返回后将继续进行计算的地址。

使用 Hopper 工具，我们可以搜索符号
```
__ZN2CA5Layer10set_boundsERKNS_4RectEb
```
在二进制文件中
```
/System/Library/Frameworks/QuartzCore.framework/
Versions/A/QuartzCore
```

请注意，在搜索功能名称时，我们需要在功能名称前添加一个额外的下划线。 这是由于 C 语言编译器导致的。

我们看到
```
__ZN2CA5Layer10set_boundsERKNS_4RectEb:        
// CA::Layer::set_bounds(CA::Rect const&, bool)
0000000000008e36 push       rbp
                    ; CODE XREF=-[CALayer setBounds:]+246,
                    __ZN2CA5Layer10set_boundsERKNS_4RectEb+750
0000000000008e37 mov        rbp, rsp
0000000000008e3a push       r15
```

从十六进制地址8e36，如果我们加上230，就能得到 0x8f1c。查看反编译以后的代码：

```
0000000000008edd  mov   rdi, qword [objc_cls_ref_NSException]
       ; argument "instance" for method _objc_msgSend
0000000000008ee4  movsd xmm0, qword [r12]
0000000000008eea  movsd xmm1, qword [r12+8]
0000000000008ef1  movsd xmm2, qword [r12+0x10]
0000000000008ef8  movsd xmm3, qword [r12+0x18]
0000000000008eff  mov   rsi, qword [0x27a338]
      ; @selector(raise:format:),
                       argument "selector"
                       for method _objc_msgSend
0000000000008f06  lea   rdx, qword
[cfstring_CALayerInvalidGeometry]
      ; @"CALayerInvalidGeometry"
0000000000008f0d  lea   rcx, qword
 [cfstring_CALayer_bounds_contains_NaN____g__g___g__g_]
      ; @"CALayer bounds contains NaN: [%g %g; %g %g]"
0000000000008f14  mov   al, 0x4
0000000000008f16  call  qword [_objc_msgSend_24d4f8]
      ; _objc_msgSend

                     loc_8f1c:
0000000000008f1c  call  __ZN2CA11Transaction13ensure_compatEv
       ; CA::Transaction::ensure_compat(),
        CODE XREF=__ZN2CA5Layer10set_boundsERKNS_4RectEb+61,
         __ZN2CA5Layer10set_boundsERKNS_4RectEb+70,
          __ZN2CA5Layer10set_boundsERKNS_4RectEb+137,
           __ZN2CA5Layer10set_boundsERKNS_4RectEb+147
```

我们可以看到 8f1c 是下一个函数调用（返回之后）。问题函数的调用在地址 8f16 处完成。我们还可以看到崩溃报告中提供的字符串文本。
`"CALayer bounds contains NaN: [%g %g; %g %g]"`
