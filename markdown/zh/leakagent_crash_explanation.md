### LeakAgent 崩溃

苹果提供了 `LeakAgent` 程序作为其内存诊断工具的一部分。 它在 Xcode Instruments 中使用。

以下是崩溃报告， `LeakAgent` 发生了崩溃，为了便于演示而对报告内容进行截断：

```
Incident Identifier: 11ED1987-1BC9-4F44-900C-AD07EE6F7E26
CrashReporter Key:   b544a32d592996e0efdd7f5eaafd1f4164a2e13c
Hardware Model:      iPad6,3
Process:             LeakAgent [3434]
Path:                /Developer/Library/PrivateFrameworks/
DVTInstrumentsFoundation.framework/LeakAgent
Identifier:          LeakAgent
Version:             ???
Code Type:           ARM-64 (Native)
Role:                Unspecified
Parent Process:      DTServiceHub [1592]
Coalition:           com.apple.instruments.deviceservice
 [463]


Date/Time:           2018-07-19 14:16:57.6977 +0100
Launch Time:         2018-07-19 14:16:56.7734 +0100
OS Version:          iPhone OS 11.3 (15E216)
Baseband Version:    n/a
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at
 0x0000000000000000
VM Region Info: 0 is not in any region.
  Bytes before following region: 4371873792
      REGION TYPE                      START - END
                   [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT        0000000104958000-0000000104964000
       [   48K] r-x/r-x SM=COW  ...ork/LeakAgent

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [0]
Triggered by Thread:  4

Thread 4 name:  Dispatch queue:
DTXChannel serializer queue [x1.c0]
Thread 4 Crashed:
0   libswiftDemangle.dylib        	
0x0000000104f871dc 0x104f70000 + 94684
1   libswiftDemangle.dylib        	
0x0000000104f8717c 0x104f70000 + 94588
2   libswiftDemangle.dylib        	
0x0000000104f86200 0x104f70000 + 90624
3   libswiftDemangle.dylib        	
0x0000000104f84948 0x104f70000 + 84296
4   libswiftDemangle.dylib        	
0x0000000104f833a4 0x104f70000 + 78756
5   libswiftDemangle.dylib        	
0x0000000104f73290 0x104f70000 + 12944
6   CoreSymbolication             	
0x000000019241d638 demangle + 112
7   CoreSymbolication             	
0x00000001923d16cc
 TRawSymbol<Pointer64>::name+ 54988 () + 72
8   CoreSymbolication             	
0x0000000192404ff4
 TRawSymbolOwnerData<Pointer64>::
 symbols_for_name(CSCppSymbolOwner*, char const*,
    void + 266228 (_CSTypeRef) block_pointer) + 156
9   CoreSymbolication             	
0x00000001923d9734
 CSSymbolOwnerGetSymbolWithName + 116
10  Symbolication                 	
0x000000019bb2e7f4
 -[VMUObjectIdentifier _targetProcessSwiftReflectionVersion]
  + 120
11  Symbolication                 	
0x000000019bb2f9d8
 -[VMUObjectIdentifier loadSwiftReflectionLibrary] + 36
12  Symbolication                 	
0x000000019bb29ff0
 -[VMUObjectIdentifier initWithTask:symbolicator:scanner:]
  + 436
13  Symbolication                 	
0x000000019baede10
 -[VMUTaskMemoryScanner _initWithTask:options:] + 2292
14  Symbolication                 	
0x000000019baee304
 -[VMUTaskMemoryScanner initWithTask:options:] + 72
15  LeakAgent                     	
0x000000010495b270 0x104958000 + 12912
16  CoreFoundation                	
0x0000000183f82580 __invoking___ + 144
17  CoreFoundation                	0x0000000183e61748
 -[NSInvocation invoke] + 284
18  DTXConnectionServices         	
0x000000010499f230 0x104980000 + 127536
19  DTXConnectionServices         	
0x00000001049947a4 0x104980000 + 83876
20  libdispatch.dylib             	0x000000018386cb24
 _dispatch_call_block_and_release + 24
21  libdispatch.dylib             	0x000000018386cae4
 _dispatch_client_callout + 16
22  libdispatch.dylib             	0x0000000183876a38
 _dispatch_queue_serial_drain$VARIANT$mp + 608
23  libdispatch.dylib             	0x0000000183877380
 _dispatch_queue_invoke$VARIANT$mp + 336
24  libdispatch.dylib             	0x0000000183877d4c
 _dispatch_root_queue_drain_deferred_wlh$VARIANT$mp + 340
25  libdispatch.dylib             	0x000000018388011c
 _dispatch_workloop_worker_thread$VARIANT$mp + 668
26  libsystem_pthread.dylib       	0x0000000183b9fe70
 _pthread_wqthread + 860
27  libsystem_pthread.dylib       	
0x0000000183b9fb08 start_wqthread + 4

Thread 4 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   
    x2: 0xfffffffffffffff6
       x3: 0x0000000000000041
    x4: 0x0000000000000000   x5: 0x0000000104f97950   
    x6: 0x0000000000000006
       x7: 0x00000000ffffffff
    x8: 0x00000001050589d0   x9: 0x0000000104f840d8  
    x10: 0xffffffffffffd544
      x11: 0x0000000000000a74
   x12: 0x0000000000000002  x13: 0x00000000000002aa  
   x14: 0x00000000000002aa
     x15: 0x00000000000003ff
   x16: 0x0000000183b96360  x17: 0x0000000000200000  
   x18: 0x0000000000000000
     x19: 0x000000016b6d1ba0
   x20: 0x00000001050589a0  x21: 0x0000000000000000  
   x22: 0x0000000000000000
     x23: 0x0000000000000001
   x24: 0x00000000ffffffff  x25: 0x0000000000000006  
   x26: 0x0000000104f97950
     x27: 0x0000000000000000
   x28: 0x0000000000000009   fp: 0x000000016b6d19c0   
   lr: 0x0000000104f8717c
    sp: 0x000000016b6d1930   pc: 0x0000000104f871dc
    cpsr: 0x60000000
```

我们可以看到出错的内核地址是`0x0000000000000000`，所以它是一个空指针解引用。我们崩溃的调用站点是一个分解符号的 Swift 库。Xcode 工具试图从它在 iPad 上看到的活动中提供人类可读的对象类型定义。

如果我们是用户并视图分析我们的应用程序，然后在`LeakAgent`中遇到此错误，那么我们需要尝试找出避免该问题的方法。

由于问题是由于符号化造成的，所以明智的做法是清除构建目录，然后进行一次干净的构建。有时，Xcode更新会将我们切换到不兼容的新目标文件格式。 值得与另一个项目（可能是微不足道的测试程序）一起检查性能。 还有其他内存分析工具，例如我们正在运行的方案的诊断选项，因此可以用不同的方式进行内存分析。 有关更多信息，请参见下一章内存诊断 。
