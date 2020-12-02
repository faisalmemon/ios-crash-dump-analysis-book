# Apple Silicon

在本章中，我们着眼于 Apple Silicon Mac 上的崩溃，比如，因使用 Rosetta \index{trademark!Rosetta} 翻译系统而引起的崩溃以及因在 macOS 上运行的未修改 iOS 应用程序而引起的崩溃。 此外，我们还将研究同时支持 ARM \index{CPU!ARM} 和 Intel \index{CPU!Intel}  CPU的多体系结构代码可能导致的新型崩溃。

## 什么是 Apple Silicon Mac?

Apple Silicon表示该芯片的设计来自Apple，而不是第三方。 苹果公司的A系列芯片可以被认为是苹果芯片。 但是，本章重点是Apple Silicon Macs。 这些始于Apple M1芯片。 这些Mac之所以不被称为 _基于ARM的Mac_，可能是因为Apple在设计水平上做出了重大贡献，同时仍然符合ARM ABI。 当从基于 Intel 的 Mac 切换到 Apple Silicon Mac 时，这为客户带来了更优益的市场收益，例如更长的电池寿命和高性能。

## 什么是 Rosetta?

Rosetta\index{trademark!Rosetta} 是 Apple Silicon Mac 上的指令翻译器。当应用程序将 Intel 指令作为二进制代码的一部分时，它可以将这些指令转换为 ARM 指令，然后运行它们。可以把它看作 AOT \index{JIT} 编译器。@rosetta 这项技术的起源可以追溯到更早的时期，当时 mac 正在从 PowerPC 芯片过渡到 Intel 芯片。苹果在 Transitive Technologies Ltd. 的技术帮助下研发出了 Rosetta 的第一个版本。@transitive @rosetta_news 在 Rosetta 的第二个版本中，我们的系统允许在每个进程的基础上，将 Intel 指令预先翻译成 ARM 指令，然后以原生速度运行。

### Rosetta 的二进制文件

在 Apple Silicon Mac 上，Rosetta 软件驻留在
```
/Library/Apple/usr/libexec/oah
```

在这个目录下有运行时引擎 `runtime_t8027`、翻译器 ` oahd-helper`、命令行工具 `translate_tool`和其他工具。它的操作对终端用户来说基本是透明的，除了启动延迟较小或性能稍低。从崩溃分析的角度来看，我们可以从内存占用量，异常帮助程序和运行时帮助程序的角度看到它的存在。

### Rosetta 的局限性

Rosetta 是一个功能强大的系统，但有一些局限性。这些主要涉及高性能多媒体应用程序和操作系统虚拟化解决方案。

Rosetta 并不包括以下功能：

- 内核扩展
- `x86_64` 虚拟化支持说明
- 矢量指令，例如 AVX，AVX2 和 AVX512\index{Vector instruction!AVX}

有趣的是，Rosetta 支持即时编译应用程序。这些应用程序非常特殊，因为它们自己生成代码，然后执行代码。大多数应用程序都只有固定的只读代码（程序文本），然后执行这些代码，它们的数据只是可变的（但不是可执行的）。这大概是因为JIT是JavaScript运行时的常用技术。

Apple 建议在调用使用这种功能的代码之前先检查可选的硬件功能。 我们可以通过运行 `sysctl hw | grep optional` 来确定平台上存在哪些可选硬件支持。在代码中，我们可以调用`sysctlbyname` 方法来实现同样的功能。

### 强制执行 Rosetta

如果我们默认给自己的项目使用标准的构建选项，当在 `Debug` 时将`Build Active Architecture Only` 设置成为`Yes`，而对于`Release`构建则设置为`No`，然后再调试时，我们将只看到本机的二进制文件。 这是因为在 `Debug` 时，我们不想浪费时间来构建与我们正在测试的机器无关的体系结构。

如果我们进行 `Archive` 构建，`Product > Archive`，然后选择 `Distribute App` 我们最终获得了一个可供发布的版本。 在默认设置下，这将是 Fat Binary \index{file!Fat} （我们将其称为胖二进制）文件，在多体系结构的二进制文件中提供 `x86` 和 `arm64`。

一旦我们有了一个 Fat Binary 文件，我们可以使用 `Finder` 应用程序，右键单击`File info`设置 Rosetta 来执行我们的二进制文件的翻译，这样在一个 Apple Silicon Mac 上，Intel 指令就会从 Fat Binary 中翻译出来。

![](screenshots/univeral_application_icdab_rosetta_thread.png)

## 翻译后的应用程序示例
本章的工作示例是`icdab_thread `程序。 可以在网上找到。@icdabgithub  该程序尝试调用 `thread_set_state`，然后在 60 秒后调用`abort` \index{command!abort} 主动崩溃。实际上它并没有办法达到这个效果，因为最近 macOS 的安全增强，以防止使用这样的API，它是恶意软件的攻击载体。尽管如此，这个程序还是很有趣的，因为在崩溃时，一个紧密相关的部分`task_for_pid` \index{command!task for pid} 被多次调用了 。

我们已经将命令行可执行程序 `icdab_thread` 修改为仅调用相同基础代码的应用程序。这个应用程序就是 `icdab_rosetta_thread`。这是因为 UNIX 命令行可执行文件不适合运行转换后的程序，而应用程序可以。

### `icdab_rosetta_thread` Lipo 信息

以下命令显示我们的应用程序同时支持 ARM 和 Intel 指令。
```
# lipo -archs
 icdab_rosetta_thread.app/Contents/MacOS/icdab_rosetta_thread
x86_64 arm64
```

## 翻译后的程序崩溃

如果我们运行 `icdab_rosetta_thread` 应用程序，点击 `Start Threads Test`，在一分钟后，应用程序发生崩溃。比较原生案例与已翻译案例之间的崩溃分析，我们可以从崩溃报告中的找到差异。

### 代码类型

```
Code Type:             ARM-64 (Native)
```

当在本地运行时，变成了已翻译

```
Code Type:             X86-64 (Translated)
```

### 线程转储

崩溃的线程（和其他线程）看起来很相似，只是指针在翻译后的情况下基于更高的指针。
对于原生的崩溃，我们有：

```
Thread 1 Crashed:: Dispatch queue: com.apple.root.default-qos
0   libsystem_kernel.dylib              0x00000001de3015d8
 __pthread_kill + 8
1   libsystem_pthread.dylib             0x00000001de3accbc
 pthread_kill + 292
2   libsystem_c.dylib                   0x00000001de274904 abort
 + 104
3   perivalebluebell.com.icdab-rosetta-thread  
 0x00000001002cd478 start_threads + 244
4   perivalebluebell.com.icdab-rosetta-thread  
 0x00000001002cd858 thunk for @escaping @callee_guaranteed () ->
 () + 20
5   libdispatch.dylib                   0x00000001de139658
 _dispatch_call_block_and_release + 32
6   libdispatch.dylib                   0x00000001de13b150
 _dispatch_client_callout + 20
7   libdispatch.dylib                   0x00000001de13e090
 _dispatch_queue_override_invoke + 692
8   libdispatch.dylib                   0x00000001de14b774
 _dispatch_root_queue_drain + 356
9   libdispatch.dylib                   0x00000001de14bf6c
 _dispatch_worker_thread2 + 116
10  libsystem_pthread.dylib             0x00000001de3a9110
 _pthread_wqthread + 216
11  libsystem_pthread.dylib             0x00000001de3a7e80
 start_wqthread + 8
```

而对于翻译后的案例中崩溃，则有
```
Thread 1 Crashed:: Dispatch queue: com.apple.root.default-qos
0   ???                                 0x00007fff0144ff40 ???
1   libsystem_kernel.dylib              0x00007fff6bdc4812
 __pthread_kill + 10
2   libsystem_c.dylib                   0x00007fff6bd377f0 abort
 + 120
3   perivalebluebell.com.icdab-rosetta-thread  
 0x0000000100d1c5ab start_threads + 259
4   perivalebluebell.com.icdab-rosetta-thread  
 0x0000000100d1ca1e thunk for @escaping @callee_guaranteed () ->
 () + 14
5   libdispatch.dylib                   0x00007fff6bbf753d
 _dispatch_call_block_and_release + 12
6   libdispatch.dylib                   0x00007fff6bbf8727
 _dispatch_client_callout + 8
7   libdispatch.dylib                   0x00007fff6bbfad7c
 _dispatch_queue_override_invoke + 777
8   libdispatch.dylib                   0x00007fff6bc077a5
 _dispatch_root_queue_drain + 326
9   libdispatch.dylib                   0x00007fff6bc07f06
 _dispatch_worker_thread2 + 92
10  libsystem_pthread.dylib             0x00007fff6be8c4ac
 _pthread_wqthread + 244
11  libsystem_pthread.dylib             0x00007fff6be8b4c3
 start_wqthread + 15
```

注意，在翻译后的案例中，线程堆栈 0 中的实际代码行是 `???`。 大概这是 Rosetta 合成的实际翻译代码。

此外，在翻译后的案例中，我们还有另外两个线程，异常服务器\index{Rosetta!Exception Server}和运行时环境：
```
Thread 3:: com.apple.rosetta.exceptionserver
0   runtime_t8027                       0x00007ffdfff76af8
 0x7ffdfff74000 + 11000
1   runtime_t8027                       0x00007ffdfff803cc
 0x7ffdfff74000 + 50124
2   runtime_t8027                       0x00007ffdfff82738
 0x7ffdfff74000 + 59192

Thread 4:
0   runtime_t8027                       0x00007ffdfffce8ac
 0x7ffdfff74000 + 370860
```

### 崩溃的线程状态寄存器

在原生的例子中，我们得到了线程状态寄存器：
```
Thread 1 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2:
 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x000000000000003c   x5: 0x0000000000000000   x6:
 0x0000000000000000   x7: 0x0000000000000000
    x8: 0x00000000000005b9   x9: 0xb91ed5337c66d7ee  x10:
 0x0000000000003ffe  x11: 0x0000000206c1fa22
   x12: 0x0000000206c1fa22  x13: 0x000000000000001e  x14:
 0x0000000000000881  x15: 0x000000008000001f
   x16: 0x0000000000000148  x17: 0x0000000200e28528  x18:
 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x000000016fbbb000  x21: 0x0000000000001707  x22:
 0x000000016fbbb0e0  x23: 0x0000000000000114
   x24: 0x000000016fbbb0e0  x25: 0x000000020252d184  x26:
 0x00000000000005ff  x27: 0x000000020252d6c0
   x28: 0x0000000002ffffff   fp: 0x000000016fbbab70   lr:
 0x00000001de3accbc
    sp: 0x000000016fbbab50   pc: 0x00000001de3015d8 cpsr:
 0x40000000
   far: 0x0000000100ff8000  esr: 0x56000080
```

在翻译后的案例中，同样也有线程状态寄存器：
```
Thread 1 crashed with X86 Thread State (64-bit):
  rax: 0x0000000000000000  rbx: 0x000000030600b000  rcx:
 0x0000000000000000  rdx: 0x0000000000000000
  rdi: 0x0000000000000000  rsi: 0x0000000000000003  rbp:
 0x0000000000000000  rsp: 0x000000000000003c
   r8: 0x000000030600ad40   r9: 0x0000000000000000  r10:
 0x000000030600b000  r11: 0x00007fff6bd37778
  r12: 0x0000000000003d03  r13: 0x0000000000000000  r14:
 0x0000000000000006  r15: 0x0000000000000016
  rip: <unavailable>  rfl: 0x0000000000000287
```

### 翻译的代码信息

在翻译后的案例中，我们会获得更多信息，这可能对那些从事调试 Rosetta 的工程师有用：
```
Translated Code Information:
  tmp0: 0xffffffffffffffff tmp1: 0x00007fff0144ff14 tmp2:
 0x00007fff6bdc4808
```

### 外部修改摘要

在原生的例子中，我们看到：
```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 914636
    thread_create: 0
    thread_set_state: 804
```

我们的代码曾尝试调用 `thread_set_state`，但未能（由于 macOS 限制，在任何平台配置下都不行）。

然后我们看一下翻译后的示例：

```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 1
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 915091
    thread_create: 0
    thread_set_state: 804
```

我们看到几乎相同的统计信息，但是有趣的是，我们将`task_for_pid` \index{command!task for pid} 设置为 1。因此，翻译环境仅对翻译过程进行了最小的观察/修改。

### 虚拟内存区域

该程序的翻译版本在 RAM 使用率上比原生版本高。

在原生的案例中，我们可以看到：
```
                                VIRTUAL   REGION
REGION TYPE                        SIZE    COUNT (non-coalesced)
===========                     =======  =======
TOTAL                              1.7G     2053
TOTAL, minus reserved VM space     1.3G     2053
```

而翻译后的情况则是：

```
REGION TYPE                        SIZE    COUNT (non-coalesced)
===========                     =======  =======
TOTAL                              5.4G     1512
TOTAL, minus reserved VM space     5.1G     1512
```

请注意，在翻译后的情况下，我们为 Rosetta 提供了其他虚拟内存区域：
```
Rosetta Arena                     2048K        1
Rosetta Generic                    864K       19
Rosetta IndirectBranch             512K        1
Rosetta JIT                      128.0M        1
Rosetta Return Stack               192K       12
Rosetta Thread Context             192K       12
```

## Rosetta 崩溃

Rosetta 是功能强大的翻译系统。 但是它不能翻译所有 X86-64指令。 例如，矢量指令无法翻译，遇到时会发生崩溃。 @rosetta

在诊断特定问题之前，有必要先熟悉一下 Apple 的 Porting Guide，因为这可以帮助我们针对程序可能崩溃的原因提出合理的假设。 @rosettaPortingGuide
