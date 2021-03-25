## `icdab_ptr` PAC 崩溃

在具有 A13 仿生芯片\index{CPU!A13 Bionic}的 iPhone 11\index{trademark!iPhone 11}上，运行`icdab_ptr` 程序时会得到以下崩溃信息。@icdabgithub

```
Incident Identifier: DA9FE0C7-6127-4660-A214-5DF5D432DBD9
CrashReporter Key:   d3e622273dd1296e8599964c99f70e07d25c8ddc
Hardware Model:      iPhone12,1
Process:             icdab_ptr [2125]
Path:               
 /private/var/containers/Bundle/Application/32E9356D-AF19-4F30-BB
87-E4C056468063/icdab_ptr.app/icdab_ptr
Identifier:          perivalebluebell.com.icdab-ptr
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           perivalebluebell.com.icdab-ptr [1288]

Date/Time:           2020-10-14 23:09:20.9645 +0100
Launch Time:         2020-10-14 23:09:20.6958 +0100
OS Version:          iPhone OS 14.2 (18B5061e)
Release Type:        Beta
Baseband Version:    2.02.00
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x2000000100ae9df8 ->
 0x0000000100ae9df8 (possible pointer authentication failure)
VM Region Info: 0x100ae9df8 is in 0x100ae4000-0x100aec000;  bytes
 after start: 24056  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE]
 PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  __TEXT                   100ae4000-100aec000 [   32K]
 r-x/r-x SM=COW  ...app/icdab_ptr
      __DATA_CONST             100aec000-100af0000 [   16K]
 r--/rw- SM=COW  ...app/icdab_ptr

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [2125]
Triggered by Thread:  0

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   icdab_ptr                           0x0000000100ae9df8
 nextInterestingJumpToFunc + 24056 (ViewController.m:26)
1   icdab_ptr                           0x0000000100ae9cf0
 -[ViewController viewDidLoad] + 23792 (ViewController.m:35)
2   UIKitCore                           0x00000001aca4cda0
 -[UIViewController
 _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 108
3   UIKitCore                           0x00000001aca515fc
 -[UIViewController loadViewIfRequired] + 956
4   UIKitCore                           0x00000001aca519c0
 -[UIViewController view] + 32
.
.

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000103809718   x1: 0x0000000103809718   x2:
 0x0000000000000000   x3: 0x00000000000036c8
    x4: 0x00000000000062dc   x5: 0x000000016f319b20   x6:
 0x0000000000000031   x7: 0x0000000000000700
    x8: 0x045d340100ae9df8   x9: 0x786bdebd0a110081  x10:
 0x0000000103809718  x11: 0x00000000000007fd
   x12: 0x0000000000000001  x13: 0x00000000d14208c1  x14:
 0x00000000d1621000  x15: 0x0000000000000042
   x16: 0xe16d9e01bf21b57c  x17: 0x00000002057e0758  x18:
 0x0000000000000000  x19: 0x0000000102109620
   x20: 0x0000000000000000  x21: 0x0000000209717000  x22:
 0x00000001f615ffcb  x23: 0x0000000000000001
   x24: 0x0000000000000001  x25: 0x00000001ffac7000  x26:
 0x0000000282c599a0  x27: 0x00000002057a44a8
   x28: 0x00000001f5cfa024   fp: 0x000000016f319dd0   lr:
 0x0000000100ae9cf0
    sp: 0x000000016f319da0   pc: 0x0000000100ae9df8 cpsr:
 0x60000000
   esr: 0x82000004 (Instruction Abort) Translation fault

Binary Images:
0x100ae4000 - 0x100aebfff icdab_ptr arm64e 
 <83e44566e30039258fd14db647344501>
 /var/containers/Bundle/Application/32E9356D-AF19-4F30-BB87-E4C05
6468063/icdab_ptr.app/icdab_ptr
```

首先，我们注意到的点是崩溃发生在 `ViewController.m:26`
```
0   icdab_ptr                           0x0000000100ae9df8
 nextInterestingJumpToFunc + 24056 (ViewController.m:26)
```

在我们的源代码里有：
```
24 // this function's address is where we will be jumping to
25 static void nextInterestingJumpToFunc(void) {
26     NSLog(@"Simple nextInterestingJumpToFunc\n");
27 }
```

这个程序的目的是通过指针运算来计算`nextInterestingJumpToFunc` 函数的地址，然后跳转到它。它成功地做到了，然后崩溃了。从上一节我们知道这是因为我们故意使用了从 `interestingJumpToFunc `函数借用的函数地址 PAC。

崩溃报告系统会对指针进行拆解，以推导出所给的错误指针的有效指针地址。 我们有：
```
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x2000000100ae9df8 ->
 0x0000000100ae9df8 (possible pointer authentication failure)
VM Region Info: 0x100ae9df8 is in 0x100ae4000-0x100aec000;  bytes
 after start: 24056  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE]
 PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  __TEXT                   100ae4000-100aec000 [   32K]
 r-x/r-x SM=COW  ...app/icdab_ptr
      __DATA_CONST             100aec000-100af0000 [   16K]
 r--/rw- SM=COW  ...app/icdab_ptr
```

我们的指针 `0x2000000100ae9df8` 指向程序的文本区域 `0x0000000100ae9df8`，但是指针的高 24 位不正确，因此显示了消息 `（可能的指针身份验证失败）`，并导致了`SIGSEGV`。 注意，PAC是一个特殊值 `0x200000`，大概是代表 `无效PAC`的值。

从上一节中，我们知道可以通过下面的代码检查程序中 PAC：
```
blraaz  x8
```

我们的 `x8` 寄存器是 `0x045d340100ae9df8`，所以估计出错误的 PAC 是 `0x045d34`。

## 指针验证机制调试技巧

在本节中，我们将指出在架构构 `armv8e` 目标上运行调试器时的一些区别。我们还将展示如何将崩溃报告与调试会话匹配。

当我们打印出指针时，我们得到了去掉 PAC 值的指针。例如，对于指针`0x36f93010201ddf8`，我们的 `result` 变量，我们会得到：
```
(lldb) po result
(actual=0x000000010201ddf8 icdab_ptr`nextInterestingJumpToFunc at
 ViewController.m:25)
```

该值来自产生以下输出的执行
```
ptr addresses as uintptr_t are 0x36f93010201ddd8
 0xc7777b010201ddf8
delta is 0xc407e80000000020 clean_delta is 0x20
ptrFn result is 0x36f93010201ddf8
```

通过调试器进行连接时，看不到崩溃分析报告。 但是，如果我们分离调试器：
```
(lldb) detach
```
系统将继续运行，并出发崩溃，然后生成报告。

```
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x200000010201ddf8 ->
 0x000000010201ddf8 (possible pointer authentication failure)
VM Region Info: 0x10201ddf8 is in 0x10201c000-0x102020000;  bytes
 after start: 7672  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE]
 PRT/MAX SHRMOD  REGION DETAIL
      __TEXT                   102018000-10201c000 [   16K]
 r-x/r-x SM=COW  ...app/icdab_ptr
--->  __TEXT                   10201c000-102020000 [   16K]
 r-x/rwx SM=COW  ...app/icdab_ptr
      __DATA_CONST             102020000-102024000 [   16K]
 r--/rw- SM=COW  ...app/icdab_ptr

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [2477]
Triggered by Thread:  0

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   icdab_ptr                     	0x000000010201ddf8
 nextInterestingJumpToFunc + 24056 (ViewController.m:25)
1   icdab_ptr                     	0x000000010201dcf0
 -[ViewController viewDidLoad] + 23792 (ViewController.m:34)
2   UIKitCore                     	0x00000001aca4cda0
 -[UIViewController
 _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 108
3   UIKitCore                     	0x00000001aca515fc
 -[UIViewController loadViewIfRequired] + 956
4   UIKitCore                     	0x00000001aca519c0
 -[UIViewController view] + 32
.
.

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x000000010c80a738   x1: 0x000000010c80a738   x2:
 0x000000000000000d   x3: 0x0000000000000000
    x4: 0x000000016dde59b8   x5: 0x0000000000000040   x6:
 0x0000000000000033   x7: 0x0000000000000800
    x8: 0x036f93010201ddf8   x9: 0xb179df14ab2900d1  x10:
 0x000000010c80a738  x11: 0x00000000000007fd
   x12: 0x0000000000000001  x13: 0x00000000b3e33897  x14:
 0x00000000b4034000  x15: 0x0000000000000068
   x16: 0x582bcd01bf21b57c  x17: 0x00000002057e0758  x18:
 0x0000000000000000  x19: 0x000000010be0d760
   x20: 0x0000000000000000  x21: 0x0000000209717000  x22:
 0x00000001f615ffcb  x23: 0x0000000000000001
   x24: 0x0000000000000001  x25: 0x00000001ffac7000  x26:
 0x0000000280436140  x27: 0x00000002057a44a8
   x28: 0x00000001f5cfa024   fp: 0x000000016dde5b60   lr:
 0x000000010201dcf0
    sp: 0x000000016dde5b30   pc: 0x000000010201ddf8 cpsr:
 0x60000000
   esr: 0x82000004 (Instruction Abort) Translation fault
```

这种方法很方便，因为这样我们就可以将故障转储报告与调试器中的分析直接关联起来。 请注意，`x8` 寄存器恰好是我们先前探讨的 `result `值。

