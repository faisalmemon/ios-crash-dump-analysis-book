# 崩溃报告

在本章中，我们将详细介绍崩溃报告中的内容。

我们将主要关注 iOS 奔溃报告。我们还将介绍 macOS 的奔溃报告，虽然报告的结构略有不同，但都足以让我们获取信息。

虽然，目前部分 App 可以会通过安装使用第三方的奔溃处理程序，以增加获取崩溃报告和诊断的能力，或者是基于 Web 服务来管理大量用户设备的奔溃信息。但是在本章中，我们假设 App 没有安装这种三方库，因此我们使用 `Apple CrashReport` 工具来处理奔溃报告。

当 App 发生奔溃时，`ReportCrash`从操作系统的崩溃过程中提取相关信息，并生成拓展名为`.crash `的文本文件。

当符号信息可用时，Xcode 将符号化奔溃报告然后显示符号化以后的名称而不是机器地址。这就提高了报告的可阅读性，更容易理解。

App 已经制作了一份详细的文档来解释 `crash dump` 的全部结构。

## 系统诊断

崩溃报告只是更大的系统诊断报告中的一部分。

通常，作为 App 的开发人员我们并不需要有进一步的更多的了解。但是，如果我们的问题可能是由一系列无解释的事件，或者是与硬件或与 Apple 提供的系统服务之间更复杂的交互而引起的，这时候我们不仅仅需要查看奔溃报告，而需要研究系统诊断报告。

### 提取系统诊断信息
当需要了解导致崩溃发生的环境时，我们可能需要安装手机设备管理配置文件（用于打开调试某些子系统），或创建虚拟网络接口（用于网络监测）。 Apple 提供了一个涵盖每个场景的 [网页](https://developer.apple.com/bug-reporting/profiles-and-logs/)。

在 iOS 上，基本思路是我们先安装一个配置文件，这个配置文件会让设备记录更多的日志，然后复现崩溃操作（或者让客户这么操作）。 然后我们按下设备上的特殊按键组合（例如，同时按下音量按钮和侧按钮）。系统会短暂振动，表明它正在运行`sysdiagnose`  程序，这个程序会提取很多日志文件。然后我们用 iTunes 同步设备以检索生成的`sysdiagnose_date_name.tar.gz` 文件。打包文件中包含许多系统和子系统日志，我们可以看到崩溃发生的时间以及引起崩溃的上下文。

在 macOS 上我们也可以执行相同的操作。

## iOS 崩溃报告导览

在这里，我们将浏览 iOS 崩溃报告中的每个部分并解释相应的字段。

出于目的，我们将 tvOS 和 watchOS 视作 iOS 的子集，并具有相似的崩溃报告。 

请注意，此处我们所指的“ iOS崩溃报告 ” 是用来表示来自物理设备的崩溃报告。 当发生崩溃时，我们通常是在模拟器上调试应用程序。在这种情况下，异常代码可能会有所不同，因为模拟器使用不同的方法来导致应用在调试器下停止。

### iOS 崩溃报告 Header 部分

崩溃报告通常以以下样式的开头：

```
Incident Identifier: E030D9E4-32B5-4C11-8B39-C12045CABE26
CrashReporter Key:   b544a32d592996e0efdd7f5eaafd1f4164a2e13c
Hardware Model:      iPad6,3
Process:             icdab_planets [2726]
Path:                /private/var/containers/Bundle/Application/
BEF249D9-1520-40F7-93F4-8B99D913A4AC/
icdab_planets.app/icdab_planets
Identifier:          www.perivalebluebell.icdab-planets
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           www.perivalebluebell.icdab-planets [1935]
```

这些类目由下表进行解释：

Entry|Meaning
--|--
Incident Identifier|崩溃报告的唯一编号
CrashReporter Key|崩溃设备的唯一标识符
Hardware Model|Apple 硬件模型（iPad，iPhone）
Process|崩溃的进程名称（或编号）
Path|设备文件系统上崩溃程序的完整路径名
Identifier|来自`Info.plist` 的 Bundle identifier
Version|`CFBundleVersion`；括号中有 `CFBundleVersionString`
Code Type|崩溃进程的目标体系结构
Role|进程 `task_role`。如果我们在后台、前台或控制台应用程序中，都会显示一个指示器。主要影响进程的调度优先级。
Parent Process|崩溃进程的父级。`launchd` 是一个进程启动程序，通常是父进程。
Coalition|任务分组合并，然后他们就可以可以把资源消耗集中起来。

> `CFBundleVersion `表示 bundle 构建迭代的版本号(发布与未发布) 而`CFBundleVersionString` 可能想说的是`CFBundleShortVersionString` 表示 bundle 发布版本号

首先要看的是版本。通常，如果我们是一个小团队或者是独立开发者，我们没有什么精力和资源去分析诊断旧版本的崩溃，所以首先我们要做的是让用户去更新最新版本。

如果我们有很多的崩溃，那么可能会出现一种现象。它可能来自于同一个用户（看到同一个 `CrashReporter Key`），也可能来自不同的用户（看到不同的 `CrashReporter Key`）。这可能影响我们对于崩溃的优先级判断。

`Hardware Model` 是一个值得关注的点。是只有 iPad设备，还是仅限iPhone设备，或者两者兼而有之? 对于特定的设备，我们很少测试或者代码做了特殊处理，亦或者指向一个我们并没有测试过的老旧设备。

APP 是在前台还是在后台中奔溃也是一个值得关注的点，大多数应用程序通常都不会测试其在后台运行时会发生什么，这里说的是 `Role`。例如，我们可能会接到一个电话，或者在应用之间进行切换。

现有的`Code Type` 通常是 `64-bit ARM` 的。但是我们可能看到原始的 `32-bit ARM` 

### iOS 崩溃报告 Date 和 Version 部分

接下来崩溃报告将提供日期和版本信息：

```
Date/Time:           2018-07-16 10:15:31.4746 +0100
Launch Time:         2018-07-16 10:15:31.3763 +0100
OS Version:          iPhone OS 11.3 (15E216)
Baseband Version:    n/a
Report Version:      104
```

这些类目由下表进行解释：

Entry|Meaning
--|--
Date/Time|崩溃发生的时间
Launch Time|崩溃前最初启动该进程的时间
OS Version| 操作系统版本（内部版本号）。 
Baseband Version| 蜂窝调制解调器固件版本号（用于电话呼叫）或 `n/a`（如果设备没有蜂窝调制解调器）（大多数 iPad，iPod Touch 等） 
Report Version|生成报告的 ReportCrash 版本

首先要检查的是操作系统的版本。比我们测试的版本新还是旧？是 `beta` 版吗？

接下来要比较启动时间和崩溃发生时的时间差值。应用程序是立即崩溃还是经过很长时间后崩溃？启动崩溃有时可能是打包和部署问题。我们将利用一些技术来解决运行以后的崩溃问题。

日期是有有意义？有时，设备在某个时间会设置或转发，这可能会触发安全证书或许可证密钥的日期检查。确保日期看起来是真实的。

通常关注 `Baseband Version` 并没有什么用。基带的存在意味着应用会被通话打断（当然，无论如何也会有 VOIP 呼叫）。iPad 软件通常被认为是不打算接听电话的，但 iPad 也可以选择购买有蜂窝调制解调器的版本。

### iOS崩溃报告异常部分

崩溃报告接下来将包含异常信息：

```
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Triggered by Thread:  0
```

或者它可能具有更详细的异常信息：
```
Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace <0xF>, Code 0xdead10cc
Triggered by Thread:  0
```

这通常发生在，MachOS 内核在有问题的进程上引发了操作系统异常，从而终止了该进程。 然后，ReportCrash 程序从操作系统中检索此类异常的详细信息。

这些类目由下表进行解释：

Entry|Meaning
--|--
Exception Type|Mach OS中的异常类型
Exception Codes|异常类型的编码，例如尝试访问无效的地址以及支持信息。
Exception Note|如果进程被看门狗计时器杀死，会显示`SIMULATED（这不是崩溃）`，进程崩溃则显示 ` EXC_CORPSE_NOTIFY`
Termination Reason|视情况而定，它给出一个命名空间（数字或子系统名称）和一个 `magic number`（通常是一个看起来像英语单词的十六进制数字）。 有关每个终止代码的详细信息，请参见下文。
Triggered by Thread|导致崩溃的进程中的线程

在本节中，最重要的项是异常类型。

Exception Type|Meaning
--|--
`EXC_CRASH (SIGABRT)` |我们的程序触发了一个编程语言异常，例如失败的断言，这导致操作系统中止我们的应用程序
`EXC_CRASH (SIGQUIT)` |一个进程从另一个正在管理它的进程接收到退出信号。通常，这意味着某个拓展程序花费了太长的时间或者消耗了太多的内存。App 的拓展程序仅能获得有限的内存。
`EXC_CRASH (SIGKILL)` |系统终止了我们的 App（或 App 的拓展程序），通常是因为已经达到了某种资源的限制。我们需要研究终止原因，以确定违反的某个政策是终止原因。
`EXC_BAD_ACCESS (SIGSEGV)` 或 `EXC_BAD_ACCESS (SIGBUS)` |我们的程序很可能试图访问错误的或者是我们没有权限访问的内存地址。或由于内存压力，该内存已被释放
`EXC_BREAKPOINT (SIGTRAP)` |这可能是由于触发了一个`NSException`（可能是我们自己的库触发的）或者是调用了`_NSLockError` 或 `objc_exception_throw`方法。例如，这可能是因为 Swift 检测到异常，例如强制展开 nil 可选
`EXC_BAD_INSTRUCTION (SIGILL)` |这是程序代码本身有问题，而不是因为错误的内存访问。 这在 iOS 设备上应该很少见； 可能是编译器或优化器错误，或者是错误的手写汇编代码。 但在模拟器上，是不一样的，因为使用未定义的操作码是 Swift 运行时用来停止访问僵尸对象（已分配对象）的一种技术。
`EXC_GUARD`|这个问题发生在程序去关闭一个受保护的文件。例如，关闭系统使用的 SQLite 库

当存在终止原因时，我们可以按如下方式查找代码：

Termination Code | Meaning
--|--
`0xdead10cc`  |我们在挂起之前持有文件锁或 sqlite 数据库锁。我们应该在挂起之前释放锁。
`0xbaaaaaad` | 通过侧面和两个音量按钮对整个系统进行了 `stackshot`。请参阅前面的系统诊断部分 
`0xbad22222` | 可能是 VOIP 应用被频繁唤起导致的崩溃。也可以注意一下我们的后台调用网络的代码。 如果我们的TCP连接被唤醒太多次（例如 300 秒内唤醒 15 次），就会导致此崩溃。 
`0x8badf00d` | 我们的应用程序执行状态更改（启动、关闭、处理系统消息等）花费了太长时间。与看门口的时间策略发生冲突（超时）并导致终止。最常见的罪魁祸首是在主线程上进行同步的网络连接。 
`0xc00010ff` | 系统检测的设备发烫而终止了我们的 App。如果只在少量设备上（几个）发生，那就可能是由于硬件的问题，而不是我们 App 问题。但是如果发生在其他设备上，我们应该使用 Instruments 去检查我们 App 的耗电量问题。 
`0x2bad45ec` | 发生安全冲突。 如果 `Termination Description` 显示为 `Process detected doing insecure drawing while in secure mode`，则意味着我们的应用尝试在不允许的情况下进行绘制，例如在锁定屏幕的情况下。 

#### Magic Numbers 和他们的黑话(意思)

出于某种怪异的幽默，在讨论终止代码时，下面的 `Magic Number` 是表达这些意思

Magic Number | Spoken Phrase
--|--
`0xdead10cc` | Deadlock
`0xbaaaaaad` | Bad
`0xbad22222` | Bad too (two) many times
`0x8badf00d` | Ate (eight) bad food
`0xc00010ff` | Cool Off
`0x2bad45ec` | Too bad for security

#### 主动终止

当 `Exception Type` 为 `SIGABRT` 时，我们应该从崩溃堆栈中查找代码中存在哪些断言或异常。

#### 内存问题
当我们存在内存问题时， `Exception Type`  为 `EXC_BAD_ACCESS` 括号里是`SIGSEGV` 或者 `SIGBUS`，我们根据括号中的异常代码来判断是什么内存问题。对于这类问题，我们可以打开 Xcode 中关于特定 `target scheme` 的相关诊断程序。应该打开 `address sanitizer`，以查看是否可以发现错误。

> 选择 `Edit Scheme` 选择 `Run` 选择 `Address Sanitizer`

如果 Xcode 显示 App 正在使用大量内存，那么可能是我们所依赖的内存已被系统释放。为此，请打开 `Malloc Stack` 日志记录选项，选择 `All Allocation And Free History`。然后在 App 运行的某个时刻，可以单击 `MemGraph` 按钮，然后探索对象的分配历史记录。

有关更多详细信息，请阅读 内存诊断 章节。

#### 例外

当我们的异常类型为 `EXC_BREAKPOINT` 时，这可能会造成一定的困惑。该应用在没有 `debugger` 工具的情况下独自运行，那么断点从哪里来呢？通常，可能是因为我们运行了 `NSException` 代码。这使的系统在过程中跟踪陷阱信号，并使任何可用的调试器都这个过程中以帮助调试。所以即使我们在 `debug ` 时断开断点，我们也会在这里停住，这样我们就可以找出存在运行时异常的原因。在正常的应用程序运行的情况下，没有 `debugger` 工具，系统只能崩溃应用程序。

#### 非法指示
当我们的异常类型为`EXC_BAD_INSTRUCTION`时，异常代码（接下来的字符）将是有问题的汇编代码。这种情况应改是罕见的。这值得我们去调整 `Build Settings` 中代码的优先级别，因为更高级别的优化可能会导致在构建期间发出更多奇特的指令，从而增加了编译器错误的机会。或者说，问题可能出在代码中具有手动编译优化功能的底层库中，例如多媒体资源库。手写汇编指令可能是错误出现的原因。

#### 保护例外

有些操作系统会使用某些文件，因此它们会受到特殊保护。当关闭（或以其他方式修改）此类文件时，我们会得到一个 `EXC_GUARD`  类型的异常。

例如：
```
Exception Type:  EXC_GUARD
Exception Codes: 0x0000000100000000, 0x08fd4dbfade2dead
Crashed Thread:  5
```

异常代码 `0x08fd4dbfade2dead` 表达了修改与数据库相关的文件（在我们的示例中它已被关闭）。这个十六进制字符串可以类似 `黑话` 读作  `Ate (8) File Descriptor (fd) for (4) Database (db)`。

当出现这样的问题时，我们可以查看崩溃线程中的文件操作。 在我们的例子中：
```
Thread 5 name:  Dispatch queue: com.apple.root.default-priority
Thread 5 Crashed:
0   libsystem_kernel.dylib          0x3a287294 close + 8
1   ExternalAccessory               
0x32951be2 -[EASession dealloc] + 226
```

在这里执行了一个关闭操作。

当我们有与文件操作对应的描述代码时，我们应该特别检查一下我们的关闭操作代码。

我们可以从第一个异常代码推断文件操作。它是一个 64 位标志，指定如下：

Bit Range|Meaning
--|--
63:61|Guard 类型，其中 0x2 表示文件描述符
60:32|Flavor
31:00|File descriptor number

从观察中，我们认为 Guard 类型没有被使用。

Flavor 是另一个向量：

Flavor Bit|Meaning
--|--
0|尝试调用`close()`
1|`dup()` , `dup2()` 或者 `fcntl()`
2|通过套接字尝试调用`sendmsg()`
4|尝试调用`write()`

### iOS 崩溃报告已过滤的 `syslog` 部分

奔溃报告接下来是 `syslog` 部分：

```
Filtered syslog:
None found
```

这是一个异常部分，因为他会去查看奔溃进程的进程 ID，然后查看该进程是否有任何 `syslog` （系统日志）部分。这个例子中我们并未在奔溃报告看到任何已过滤的信息，只看到 `None found` 。

### iOS 崩溃报告中的异常回溯部分

当我们的应用程序检测到问题并要求操作系统终止该应用程序时，我们将获得报告的异常回溯部分。这涵盖了自己主动或通过 Swift，Objective-C 或 C 运行时支持库间接调用了`abort`，`NSException`，`_NSLockError`或`objc_exception_throw`的情况。

我们并没有办法得到实际发生断言的部分。但我们可以假定已经过滤的系统日志的前一个部分应该完成了这部分。虽然，通过  _Window-> Devices and Simulators-> Open Console_ 会允许我们恢复该信息。

当我们在客户的崩溃报告中看到异常回溯时，我们应该要求崩溃设备的控制台日志。

例如，我们将看到：
```
default	13:36:58.000000 +0000	icdab_nsdata
	 My data is <> - ok since we can handle a nil

default	13:36:58.000000 +0100	icdab_nsdata	 
-[__NSCFConstantString _isDispatchData]:
unrecognized selector sent to instance 0x3f054

default	13:36:58.000000 +0100	icdab_nsdata
	 *** Terminating app due to
uncaught exception 'NSInvalidArgumentException', reason:
'-[__NSCFConstantString _isDispatchData]:
 unrecognized selector sent to
instance 0x3f054'
	*** First throw call stack:
	(0x25aa391b 0x2523ee17 0x25aa92b5 0x25aa6ee1 0x259d2238
     0x2627e9a5 0x3d997
    0x2a093785 0x2a2bb2d1 0x2a2bf285 0x2a2d383d 0x2a2bc7b3
     0x27146c07
    0x27146ab9 0x27146db9 0x25a65dff 0x25a659ed 0x25a63d5b
     0x259b3229
     0x259b3015 0x2a08cc3d 0x2a087189 0x3d80d 0x2565b873)

default	13:36:58.000000 +0100	SpringBoard	 Application
'UIKitApplication:www.perivalebluebell.icdab-nsdata[0x51b9]'
 crashed.

default	13:36:58.000000 +0100	UserEventAgent
	 2769630555571:
 id=www.perivalebluebell.icdab-nsdata pid=386, state=0

default	13:36:58.000000 +0000	ReportCrash	 Formulating
report for corpse[386] icdab_nsdata

default	13:36:58.000000 +0000	ReportCrash	 Saved type
 '109(109_icdab_nsdata)'
 report (2 of max 25) at
 /var/mobile/Library/Logs/CrashReporter/
 icdab_nsdata-2018-07-27-133658.ips
```

有趣的是这一行：
```
'-[__NSCFConstantString _isDispatchData]:
unrecognized selector sent to instance 0x3f054'
```

这意味着向 `NSString` 类发送了`_isDispatchData` 方法。不存在的方法。

在崩溃报告中看到匹配的异常回溯是：
```
Last Exception Backtrace:
0   CoreFoundation                	
0x25aa3916 __exceptionPreprocess + 122
1   libobjc.A.dylib               	
0x2523ee12 objc_exception_throw + 33
2   CoreFoundation                	0x25aa92b0
-[NSObject+ 1045168 (NSObject) doesNotRecognizeSelector:] + 183
3   CoreFoundation                	
0x25aa6edc ___forwarding___ + 695
4   CoreFoundation                	
0x259d2234 _CF_forwarding_prep_0 + 19
5   Foundation                    	0x2627e9a0
-[_NSPlaceholderData initWithData:] + 123
6   icdab_nsdata                  	0x000f89ba
-[AppDelegate application:didFinishLaunchingWithOptions:]
 + 27066 (AppDelegate.m:26)
7   UIKit                         	0x2a093780
-[UIApplication
 _handleDelegateCallbacksWithOptions:isSuspended:restoreState:]
 + 387
8   UIKit                         	0x2a2bb2cc
-[UIApplication
 _callInitializationDelegatesForMainScene:transitionContext:]
 + 3075
9   UIKit                         	0x2a2bf280
-[UIApplication
 _runWithMainScene:transitionContext:completion:] + 1583
10  UIKit                         	0x2a2d3838
__84-[UIApplication
 _handleApplicationActivationWithScene:transitionContext:
completion:]_block_invoke3286 + 31
11  UIKit                         	0x2a2bc7ae
-[UIApplication workspaceDidEndTransaction:] + 129
12  FrontBoardServices            	0x27146c02
__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 13
13  FrontBoardServices            	0x27146ab4
-[FBSSerialQueue _performNext] + 219
14  FrontBoardServices            	0x27146db4
-[FBSSerialQueue _performNextFromRunLoopSource] + 43
15  CoreFoundation                	0x25a65dfa
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 9
16  CoreFoundation                	
0x25a659e8 __CFRunLoopDoSources0 + 447
17  CoreFoundation                	
0x25a63d56 __CFRunLoopRun + 789
18  CoreFoundation                	
0x259b3224 CFRunLoopRunSpecific + 515
19  CoreFoundation                	
0x259b3010 CFRunLoopRunInMode + 103
20  UIKit                         	
0x2a08cc38 -[UIApplication _run] + 519
21  UIKit                         	
0x2a087184 UIApplicationMain + 139
22  icdab_nsdata                  	
0x000f8830 main + 26672 (main.m:14)
23  libdyld.dylib                 	
0x2565b86e tlv_get_addr + 41
```

此回溯的格式与线程回溯的格式相同，稍后将进行介绍。

异常回溯部分的目的是提供比崩溃线程提供的更多的细节。

在上述情况下崩溃的线程有线程回溯：
```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x2572ec5c __pthread_kill
 + 8
1   libsystem_pthread.dylib       	0x257d8732 pthread_kill +
 62
2   libsystem_c.dylib             	0x256c30ac abort + 108
3   libc++abi.dylib               	0x2521aae4 __cxa_bad_cast
 + 0
4   libc++abi.dylib               	0x2523369e
default_terminate_handler+ 104094 () + 266
5   libobjc.A.dylib               	0x2523f0b0
_objc_terminate+ 28848 () + 192
6   libc++abi.dylib               	0x25230e16
std::__terminate(void (*)+ 93718 ()) + 78
7   libc++abi.dylib               	0x252308f8
__cxa_increment_exception_refcount + 0
8   libobjc.A.dylib               	
0x2523ef5e objc_exception_rethrow + 42
9   CoreFoundation                	
0x259b32ae CFRunLoopRunSpecific + 654
10  CoreFoundation                	
0x259b3014 CFRunLoopRunInMode + 108
11  UIKit                         	
0x2a08cc3c -[UIApplication _run] + 524
12  UIKit                         	
0x2a087188 UIApplicationMain + 144
13  icdab_nsdata                  	
0x000f8834 main + 26676 (main.m:14)
14  libdyld.dylib                 	
0x2565b872 start + 2
```

如果只有线程回溯，我们将知道存在强制转换问题 `__cxa_bad_cast` ，但仅此而已。

从网上搜到 `NSData`具有一个私有的辅助类 `_NSPlaceholderData`。

这个情况是在一个需要使用 `NSData` 的地方使用了 `NSString` 对象。

### iOS 崩溃报告线程部分

崩溃报告接下来是线程回溯的部分（为便于演示而进行了格式化）

```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libsystem_kernel.dylib        	0x0000000183a012ec
 __pthread_kill + 8
1   libsystem_pthread.dylib       	0x0000000183ba2288
 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	0x000000018396fd0c
 abort + 140
3   libsystem_c.dylib             	0x0000000183944000
 basename_r + 0
4   icdab_planets                 	
0x0000000104e145bc
 -[PlanetViewController viewDidLoad] + 17852
  (PlanetViewController.mm:33)
5   UIKit                         	0x000000018db56ee0
 -[UIViewController loadViewIfRequired] + 1020
6   UIKit                         	0x000000018db56acc
 -[UIViewController view] + 28
7   UIKit                         	0x000000018db47d60
 -[UIWindow addRootViewControllerViewIfPossible] + 136
8   UIKit                         	0x000000018db46b94
 -[UIWindow _setHidden:forced:] + 272
9   UIKit                         	0x000000018dbd46a8
-[UIWindow makeKeyAndVisible] + 48
10  UIKit                         	0x000000018db4a2f0
 -[UIApplication
  _callInitializationDelegatesForMainScene:transitionContext:]
  + 3660
11  UIKit                         	0x000000018db1765c
-[UIApplication
_runWithMainScene:transitionContext:completion:] + 1680
12  UIKit                         	0x000000018e147a0c
__111-[__UICanvasLifecycleMonitor_Compatability
_scheduleFirstCommitForScene:transition:firstActivation:
completion:]_block_invoke + 784
13  UIKit                         	0x000000018db16e4c
+[_UICanvas _enqueuePostSettingUpdateTransactionBlock:] + 160
14  UIKit                         	0x000000018db16ce8
-[__UICanvasLifecycleMonitor_Compatability
_scheduleFirstCommitForScene:transition:
firstActivation:completion:] + 240
15  UIKit                         	0x000000018db15b78
-[__UICanvasLifecycleMonitor_Compatability
activateEventsOnly:withContext:completion:] + 724
16  UIKit                         	0x000000018e7ab72c
__82-[_UIApplicationCanvas
 _transitionLifecycleStateWithTransitionContext:
completion:]_block_invoke + 296
17  UIKit                         	0x000000018db15268
-[_UIApplicationCanvas
 _transitionLifecycleStateWithTransitionContext:
completion:] + 432
18  UIKit                         	0x000000018e5909b8
__125-[_UICanvasLifecycleSettingsDiffAction
performActionsForCanvas:
withUpdatedScene:settingsDiff:fromSettings:
transitionContext:]_block_invoke + 220
19  UIKit                         	0x000000018e6deae8
_performActionsWithDelayForTransitionContext + 112
20  UIKit                         	0x000000018db14c88
-[_UICanvasLifecycleSettingsDiffAction performActionsForCanvas:
withUpdatedScene:settingsDiff:fromSettings:
transitionContext:] + 248
21  UIKit                         	0x000000018db14624
-[_UICanvas
scene:didUpdateWithDiff:transitionContext:completion:] + 368
22  UIKit                         	0x000000018db1165c
-[UIApplication workspace:didCreateScene:withTransitionContext:
completion:] + 540
23  UIKit                         	0x000000018db113ac
-[UIApplicationSceneClientAgent scene:didInitializeWithEvent:
completion:] + 364
24  FrontBoardServices            	0x0000000186778470
-[FBSSceneImpl
_didCreateWithTransitionContext:completion:] + 364
25  FrontBoardServices            	0x0000000186780d6c
__56-[FBSWorkspace client:handleCreateScene:withCompletion:]
_block_invoke_2 + 224
26  libdispatch.dylib             	0x000000018386cae4
_dispatch_client_callout + 16
27  libdispatch.dylib             	0x00000001838741f4
_dispatch_block_invoke_direct$VARIANT$mp + 224
28  FrontBoardServices            	0x00000001867ac878
__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 36
29  FrontBoardServices            	0x00000001867ac51c
-[FBSSerialQueue _performNext] + 404
30  FrontBoardServices            	0x00000001867acab8
-[FBSSerialQueue _performNextFromRunLoopSource] + 56
31  CoreFoundation                	0x0000000183f23404
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
32  CoreFoundation                	0x0000000183f22c2c
__CFRunLoopDoSources0 + 276
33  CoreFoundation                	0x0000000183f2079c
 __CFRunLoopRun + 1204
34  CoreFoundation                	0x0000000183e40da8
CFRunLoopRunSpecific + 552
35  GraphicsServices              	0x0000000185e23020
 GSEventRunModal + 100
36  UIKit                         	0x000000018de2178c
 UIApplicationMain + 236
37  icdab_planets                 	0x0000000104e14c94
 main + 19604 (main.m:14)
38  libdyld.dylib                 	0x00000001838d1fc0
 start + 4

Thread 1:
0   libsystem_pthread.dylib       	0x0000000183b9fb04
 start_wqthread + 0

Thread 2:
0   libsystem_kernel.dylib        	0x0000000183a01d84
 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4
 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08
 start_wqthread + 4

Thread 3:
0   libsystem_pthread.dylib       	0x0000000183b9fb04
start_wqthread + 0

Thread 4:
0   libsystem_kernel.dylib        	0x0000000183a01d84
 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4
 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08
start_wqthread + 4

Thread 5:
0   libsystem_kernel.dylib        	0x0000000183a01d84
 __workq_kernreturn + 8
1   libsystem_pthread.dylib       	0x0000000183b9feb4
 _pthread_wqthread + 928
2   libsystem_pthread.dylib       	0x0000000183b9fb08
 start_wqthread + 4

Thread 6 name:  com.apple.uikit.eventfetch-thread
Thread 6:
0   libsystem_kernel.dylib        	0x00000001839dfe08
 mach_msg_trap + 8
1   libsystem_kernel.dylib        	0x00000001839dfc80
 mach_msg + 72
2   CoreFoundation                	0x0000000183f22e40
__CFRunLoopServiceMachPort + 196
3   CoreFoundation                	0x0000000183f20908
 __CFRunLoopRun + 1568
4   CoreFoundation                	0x0000000183e40da8
CFRunLoopRunSpecific + 552
5   Foundation                    	0x00000001848b5674
-[NSRunLoop+ 34420 (NSRunLoop) runMode:beforeDate:] + 304
6   Foundation                    	0x00000001848b551c
-[NSRunLoop+ 34076 (NSRunLoop) runUntilDate:] + 148
7   UIKit                         	0x000000018db067e4
-[UIEventFetcher threadMain] + 136
8   Foundation                    	0x00000001849c5efc
__NSThread__start__ + 1040
9   libsystem_pthread.dylib       	0x0000000183ba1220
 _pthread_body + 272
10  libsystem_pthread.dylib       	0x0000000183ba1110
 _pthread_body + 0
11  libsystem_pthread.dylib       	0x0000000183b9fb10
 thread_start + 4

Thread 7:
0   libsystem_pthread.dylib       	0x0000000183b9fb04
 start_wqthread + 0
```

崩溃报告将明确告诉我们哪个线程崩溃了。
```
Thread 0 Crashed:
```

线程有编号，并且如果线程有名称的话，也会展示名称：
```
Thread 0 name:  Dispatch queue: com.apple.main-thread
```

我们应该将的大部分精力放在崩溃的线程上。 通常是线程 0。注意崩溃线程的名称。请注意，不能在主线程`com.apple.main-thread` 上执行诸如网络之类的长时间任务，因为该线程用于处理用户交互。

对 `__workq_kernreturn` 的引用仅表示正在等待工作的线程，因此除非有大量线程，否则可以将其忽略。

同样，对 `mach_msg_trap` 的引用仅指示线程正在等待消息进入。

当查看堆栈回溯时，首先出现堆栈帧 0，即堆栈的顶部，然后列出调用所有调用栈。  因此，最后一件事是在第 0 帧。

> 栈帧：每一次函数的调用,都会在调用栈（call stack）上维护一个独立的栈帧（stack frame）。

#### 堆栈回溯项

现在让我们关注每个线程的回溯项。 例如：
```
20  UIKit                         	0x000000018db14c88
-[_UICanvasLifecycleSettingsDiffAction
performActionsForCanvas:
withUpdatedScene:settingsDiff:fromSettings:
transitionContext:] + 248
```

Column | Meaning
--|--
1 | 堆栈帧号，最近执行的是 0。 
2 | 二进制文件执行。 
3 | 执行位置（第 0 帧）或返回位置（第 1 帧以后） 
4+ | 符号化函数名称或函数中具有偏移量的地址 

帧数越多，就使我们在程序执行顺序方面的时间倒退。 堆栈的顶部或最近运行的代码位于第 0 帧。用有意义的函数名编写代码的原因之一是调用堆栈从概念上描述了正在发生的事情。 使用小型单一用途功能的方法是一种好习惯。 它满足了诊断和可维护性的需求。

堆栈回溯项的第二列是二进制文件。我们主要关注自己的二进制代码，因为 Apple 的框架代码通常非常可靠。错误通常直接出现在我们的代码中，或者是由于错误使用 Apple API 引起的错误引起的。仅仅因为在 Apple 提供的代码中崩溃并不意味着该错误在 Apple 代码中。

第三栏，执行位置，有些棘手。 如果是第 0 帧，则它是代码中正在运行的实际位置。 如果用于任何后续帧，则它是代码中一旦子功能返回后将恢复的位置。

第四列是运行代码的站点（对于第 0 帧），或者正在进行函数调用的站点（对于以后的帧）。 对于符号化的崩溃，我们将看到地址的符号形式。 这将包括从函数开始到调用子函数的代码的位置偏移。 如果我们只有短函数，则此偏移量将是一个很小的值。 这意味着执行诊断时所需的单步执行代码要少得多，或者要读取的汇编代码要少得多。 这是保持我们的职能简短的另一个原因。 如果没有用符号表示崩溃，那么我们将只看到一个内存地址值。

因此，对于示例堆栈帧，我们有：

- 堆栈帧 20
- UIKit 二进制文件。
- `0x000000018db14c88` 返回 0-19 帧后的地址。
- 调用位置是从方法 `performActionsForCanvas` 开始的第248字节
- 类是 `_UICanvasLifecycleSettingsDiffAction`

### iOS 崩溃报告线程状态部分

iOS 崩溃报告将来自 ARM-64 二进制文件（最常见）或传统 ARM 32 位二进制文件。

在两种情况下，我们都会获得类似的描述 ARM 寄存器状态的信息。

需要注意的一件事是特殊的十六进制代码，`0xbaddc0dedeadbead` 这意味着一个非初始化的指针。

#### 32 位线程状态

```
Thread 0 crashed with ARM Thread State (32-bit):
    r0: 0x00000000    r1: 0x00000000      r2: 0x00000000
          r3: 0x00000000
    r4: 0x00000006    r5: 0x3c42f000      r6: 0x3b66d304
          r7: 0x002054c8
    r8: 0x14d5f480    r9: 0x252348fd     r10: 0x90eecad7
         r11: 0x14d5f4a4
    ip: 0x00000148    sp: 0x002054bc      lr: 0x257d8733
          pc: 0x2572ec5c
  cpsr: 0x00000010
```

#### 64 位线程状态

```
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000028   x1: 0x0000000000000029
       x2: 0x0000000000000008
       x3: 0x0000000183a4906c
    x4: 0x0000000104440260   x5: 0x0000000000000047
       x6: 0x000000000000000a
       x7: 0x0000000138819df0
    x8: 0x0000000000000000   x9: 0x0000000000000000
      x10: 0x0000000000000003
      x11: 0xbaddc0dedeadbead
   x12: 0x0000000000000012  x13: 0x0000000000000002
     x14: 0x0000000000000000
     x15: 0x0000010000000100
   x16: 0x0000000183b9b8cc  x17: 0x0000000000000100
     x18: 0x0000000000000000
     x19: 0x00000001b5c241c8
   x20: 0x00000001c0071b00  x21: 0x0000000000000018
     x22: 0x000000018e89b27a
     x23: 0x0000000000000000
   x24: 0x00000001c4033d60  x25: 0x0000000000000001
     x26: 0x0000000000000288
     x27: 0x00000000000000e0
   x28: 0x0000000000000010   fp: 0x000000016bde54b0
      lr: 0x000000010401ca04
    sp: 0x000000016bde53e0   pc: 0x000000010401c6c8
     cpsr: 0x80000000
```


### iOS 崩溃报告的 Binary Images 部分

奔溃报告会有一部分列举了崩溃进程加载的所有 Binary Images。这通常是一串很长的列表。它强调了一个事实，即我们的应用程序有许多支持框架。大多数框架是私有框架。iOS 开发工具包似乎包含了大量 API，但这只是冰山一角。

这是一个示例列表，为便于演示而进行了编辑：

```
Binary Images:

0x104018000 - 0x10401ffff icdab_as arm64
  <b82579f401603481990d1c1c9a42b773>
/var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/icdab_as

0x104030000 - 0x104037fff libswiftCoreFoundation.dylib arm64
  <81f66e04bab133feb3369b4162a68afc>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreFoundation.dylib


0x104044000 - 0x104057fff libswiftCoreGraphics.dylib arm64
  <f1f2287fb5153a28beea12ec2d547bf8>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreGraphics.dylib

0x104078000 - 0x10407ffff libswiftCoreImage.dylib arm64
  <9433fc53f72630dc8c53851703dd440b>
  /var/containers/Bundle/Application/
1A05BC59-491C-4D0A-B4F6-8A98A804F74D/icdab_as.app/
Frameworks/libswiftCoreImage.dylib

0x104094000 - 0x1040cffff dyld arm64
  <06dc98224ae03573bf72c78810c81a78> /usr/lib/dyld
```

第一部分是图像已加载到内存中的位置。这里 `icdab_as` 已被加载到 `0x104018000`-`0x10401ffff` 范围内。

第二部分是二进制文件的名称。这里的名字是 `icdab_as`。

第三部分是加载的二进制文件中的体系结构切片。我们通常希望在这里看到 `arm64`（ARM 64位）。

第四部分是二进制文件的UUID。这里 `icdab_as` 的UDID 是 `b82579f401603481990d1c1c9a42b773`。

如果我们的 DSYM 文件 UUID 与二进制文件不匹配，则符号化将失败。

以下是使用 `dwarfdump` 命令在 DSYM 和应用程序二进制文件中看到的相应 UUID 的示例：

```
$ dwarfdump --uuid icdab_as.app/icdab_as
icdab_as.app.dSYM/Contents/Resources/DWARF/icdab_as

UUID: 25BCB4EC-21DE-3CE6-97A8-B759F31501B7
 (arm64) icdab_as.app/icdab_as

UUID: 25BCB4EC-21DE-3CE6-97A8-B759F31501B7
 (arm64)
icdab_as.app.dSYM/Contents/Resources/DWARF/icdab_as
```

第五部分是设备上显示的二进制文件的路径。

大多数二进制文件都有一个不言自明的名称。`dyld` 二进制文件是动态加载器。它位于所有堆栈回溯的底部，因为它负责在执行之前开始加载二进制文件。

动态加载器在准备二进制文件以执行时执行许多任务。如果我们的二进制引用了其他库，它将加载它们。如果没有，则无法加载我们的应用程序。这就是为什么即使在调用 `main.m` 中的任何代码之前也可能发生崩溃的原因。稍后，我们将研究如何诊断这些问题。


## macOS 崩溃报告导览

尽管 macOS CrashReport 和 iOS CrashReport 是截然不同的程序，但 macOS 崩溃报告类似于 iOS 崩溃报告。为了避免重复，这里我们只强调与 iOS 的显着差异。

### macOS 崩溃报告 Header 部分

崩溃报告以一下部分开头：

```
Process:               SiriNCService [1045]
Path:                  /System/Library/CoreServices/Siri.app/
Contents/XPCServices/SiriNCService.xpc/
Contents/MacOS/SiriNCService
Identifier:            com.apple.SiriNCService
Version:               146.4.5.1 (146.4.5.1)
Build Info:            AssistantUIX-146004005001000~1
Code Type:             X86-64 (Native)
Parent Process:        ??? [1]
Responsible:           Siri [863]
User ID:               501
```

这里我们看到了熟悉的描述故障二进制信息。崩溃的进程是 SiriNCService，负责这个进程的是 Siri。在 Siri 和 SiriNCService 之间的跨进程通信时发生了崩溃（XPC）。

通常 iOS以一个用户身份运行用户体验的系统，然而 macOS系统却暴露出系统中存在多个用户 ID 的事实。 

### macOS 崩溃报告 Date 和 Version 部分 

接下来我们来看版本信息：

```
Date/Time:             2018-06-24 09:52:01.419 +0100
OS Version:            Mac OS X 10.13.5 (17F77)
Report Version:        12
Anonymous UUID:        00CC683B-425F-ABF0-515A-3ED73BACDDB5

Sleep/Wake UUID:       10AE8838-17A9-4405-B03D-B680DDC84436

```

`Anonymous UUID` 将是计算机的唯一标识。 `Sleep/Wake UUID` 用于匹配睡眠和唤醒事件。唤醒失败是系统崩溃的常见原因（与我们讨论的应用程序崩溃相反）。可以使用电源管理命令 `pmset` 获取更多信息。

### macOS 持续时间部分

macOS 崩溃报告显示应用程序崩溃发生的时间。
```
Time Awake Since Boot: 100000 seconds
Time Since Wake:       2000 seconds
```

我们使用它作为一个广泛的指示只因为看到的数字总是四舍五入所得到一个方便的数字。

### macOS崩溃报告系统完整性部分

```
System Integrity Protection: enabled
```

默认情况下，现代 macOS 运行是 "rootless"的。这意味着即使我们以超级用户身份登录，我们也无法更改系统的二进制文件。这些都是通过固件进行保护的。可以在禁用系统完整性保护的情况下启动 macOS。如果我们只是在禁用 SIP 的情况下崩溃，那么我们需要问为什么 SIP 会关闭以及对操作系统做了哪些更改。

### macOS 崩溃报告的异常部分

接下来展示异常部分。

```
Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       KERN_INVALID_ADDRESS at 0x0000000000000018
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Segmentation fault: 11
Termination Reason:    Namespace SIGNAL, Code 0xb
Terminating Process:   exc handler [0]

VM Regions Near 0x18:
-->
    __TEXT                 0000000100238000-0000000100247000
     [   60K] r-x/rwx SM=COW  
     /System/Library/CoreServices/Siri.app/
     Contents/XPCServices/SiriNCService.xpc/Contents/MacOS/
     SiriNCService

Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:
```

这与 iOS 类似。但是，我们应该注意，如果我们在模拟器上重现 iOS 崩溃，那么模拟器可能会以不同方式对相同的编程错误进行建模。我们可以在 x86 硬件上获得与 ARM 对应的异常。

考虑以下代码，设置为旧版的手动引用计数（MRC）而不是自动引用计数（ARC）。

```
void use_sema() {
    dispatch_semaphore_t aSemaphore =
     dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(aSemaphore);
}
```

代码会导致崩溃，因为在等待时会手动释放信号量。

当它在 ARM 硬件上的 iOS 模拟器上运行时，会发生崩溃
```
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x00000001814076b8
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
Terminating Process: exc handler [0]
Triggered by Thread:  0

Application Specific Information:
BUG IN CLIENT OF LIBDISPATCH: Semaphore object deallocated while
 in use
 Abort Cause 1
```

当它在 iOS 模拟器上运行时，我们会附带调试器
```
Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
```

模拟器使用错误的汇编指令来触发崩溃。

此外，如果我们编写一个运行相同代码的 macOS 应用程序，我们就会崩溃：

```
Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
Exception Codes:       0x0000000000000001, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Illegal instruction: 4
Termination Reason:    Namespace SIGNAL, Code 0x4
Terminating Process:   exc handler [0]

Application Specific Information:
BUG IN CLIENT OF LIBDISPATCH:
Semaphore object deallocated while in use
```

这就带来一个信息，当通过模拟器或等效的 macOS 代码在 x8 6硬件上再现 iOS ARM 崩溃时，由于运行时环境有所不同，表现也会稍有不同。

幸运的是，在两个崩溃报告中都很明显的表明了信号量被释放了。

### macOS 崩溃报告线程部分

接下来是线程部分。这部分类似于iOS。

接下来用示例说明 macOS 崩溃报告中的线程部分：

```
Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   libobjc.A.dylib               	
0x00007fff69feae9d objc_msgSend + 29
1   com.apple.CoreFoundation      	0x00007fff42e19f2c
 __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__ + 12
2   com.apple.CoreFoundation      	0x00007fff42e19eaf
___CFXRegistrationPost_block_invoke + 63
3   com.apple.CoreFoundation      	0x00007fff42e228cc
 __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 12
4   com.apple.CoreFoundation      	0x00007fff42e052a3
__CFRunLoopDoBlocks + 275
5   com.apple.CoreFoundation      	0x00007fff42e0492e
__CFRunLoopRun + 1278
6   com.apple.CoreFoundation      	0x00007fff42e041a3
CFRunLoopRunSpecific + 483
7   com.apple.HIToolbox           	0x00007fff420ead96
RunCurrentEventLoopInMode + 286
8   com.apple.HIToolbox           	0x00007fff420eab06
ReceiveNextEventCommon + 613
9   com.apple.HIToolbox           	0x00007fff420ea884
 _BlockUntilNextEventMatchingListInModeWithFilter + 64
10  com.apple.AppKit              	0x00007fff4039ca73
_DPSNextEvent + 2085
11  com.apple.AppKit              	0x00007fff40b32e34
-[NSApplication(NSEvent) _nextEventMatchingEventMask:
untilDate:inMode:dequeue:] + 3044
12  com.apple.ViewBridge          	0x00007fff67859df0
-[NSViewServiceApplication nextEventMatchingMask:
untilDate:inMode:dequeue:] + 92
13  com.apple.AppKit              	0x00007fff40391885
-[NSApplication run] + 764
14  com.apple.AppKit              	0x00007fff40360a72
NSApplicationMain + 804
15  libxpc.dylib                  	0x00007fff6af6cdc7
 _xpc_objc_main + 580
16  libxpc.dylib                  	0x00007fff6af6ba1a
 xpc_main + 433
17  com.apple.ViewBridge          	0x00007fff67859c15
-[NSXPCSharedListener resume] + 16
18  com.apple.ViewBridge          	0x00007fff67857abe
 NSViewServiceApplicationMain + 2903
19  com.apple.SiriNCService       	0x00000001002396e0
 main + 180
20  libdyld.dylib                 	0x00007fff6ac12015
 start + 1
```

### macOS 崩溃报告线程状态部分

macOS 崩溃报告显示了崩溃线程中 X86 寄存器的详细信息。

```
Thread 0 crashed with X86 Thread State (64-bit):
  rax: 0x0000600000249bd0  rbx: 0x0000600000869ac0
    rcx: 0x00007fe798f55320
    rdx: 0x0000600000249bd0
  rdi: 0x00007fe798f55320  rsi: 0x00007fff642de919
    rbp: 0x00007ffeef9c6220
    rsp: 0x00007ffeef9c6218
   r8: 0x0000000000000000   r9: 0x21eb0d26c23ae422
     r10: 0x0000000000000000
     r11: 0x00007fff642de919
  r12: 0x00006080001e8700  r13: 0x0000600000869ac0
    r14: 0x0000600000448910
    r15: 0x0000600000222e60
  rip: 0x00007fff69feae9d  rfl: 0x0000000000010246
    cr2: 0x0000000000000018

Logical CPU:     2
Error Code:      0x00000004
Trap Number:     14
```

除与了 iOS 相似的信息之外，我们还获得了更多有关运行该线程的 CPU 的消息 。如果有需要我们可以在 Darwin XNU 源代码中查找对应的 `trap number` 。

Darwin XNU 源代码的便捷镜像由 GitHub 来托管：https://github.com/apple/darwin-xnu 

这些 `trap number` 可以被搜索到。我们从`osfmk/x86_64/idt_table.h` 可以找到 `Trap Number:14` 表明看了一个页面错误。这个错误代码是一个位向量，用于描述在 mach 上的错误代码。@macherror

### macOS 崩溃报告 Binary Images 部分

接下来，是崩溃应用程序所加载的 Binary Images。

以下是崩溃报告中前几个二进制文件的示例，为了便于演示，进行了截断：

```
Binary Images:
       0x100238000 -        0x1ß00246fff
         com.apple.SiriNCService (146.4.5.1 - 146.4.5.1)
          <5730AE18-4DF0-3D47-B4F7-EAA84456A9F7>
           /System/Library/CoreServices/Siri.app/Contents/
           XPCServices/SiriNCService.xpc/Contents/MacOS/
           SiriNCService

       0x101106000 -        0x10110affb
         com.apple.audio.AppleHDAHALPlugIn (281.52 - 281.52)
          <23C7DDE6-A44B-3BE4-B47C-EB3045B267D9>
           /System/Library/Extensions/AppleHDA.kext/Contents/
           PlugIns/AppleHDAHALPlugIn.bundle/Contents/MacOS/
           AppleHDAHALPlugIn
```

当二进制旁边出现 `+` 号时，则意味着它是操作系统的一部分。但是，我们看到某些第三方二进制旁边出现 `+` 号而系统二进制文件旁没有出现 `+` 号的示例，因为  `+`  并不是可靠的指示符（在 OS X 10.13.6上进行了最后测试）。

### macOS 崩溃报告修改摘要

接下来，这一节描述了崩溃过程中的所有外部修改：

```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 184
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 72970
    thread_create: 0
    thread_set_state: 0
```

macOS 是比 iOS 更开放的平台。这就允许在某些条件下运行过程中发生了修改。我们需要知道是否发生了这种事情，因为它可以使代码中的任何设计假设无效，由于可以在过程中修改寄存器，这就有可能导致项目崩溃。

通常我们可以看到如上的快照。值得注意的是，在所有情况下，`thread_set_state` 值均为 0。这意味着并没有任何进程直接连接到该进程来更改寄存器状态。这种操作对于托管运行时或调试器的实现是可接受的。在这些情况之外的操作会显得奇怪，需要进一步调查。

在下面的示例中，我们看到线程状态除了200个 `task_for_pid` 调用之外，还一次被外部进程更改了。

```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 201
    thread_create: 0
    thread_set_state: 1
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 6184
    thread_create: 0
    thread_set_state: 1
```

这些数据通常会让我们对应用程序在崩溃之前运行的环境产生怀疑。

通常只有第一等的程序（Apple 提供的）才有权限执行上述修改。我们可以安装执行这个操作的软件。

执行访问进程修改的 API 有如下要求：

- 需要禁用系统完整性保护
- 进行修改的过程必须以 root 身份运行
- 进行修改的程序必须经过代码签名
- 程序必须被分配这些权利，将 `SecTaskAccess`  设置为 `allowed` 和  `debug`。
- 用户必须同意在其安全设置中信任该程序

示例代码 `tfpexample` 演示了这一点。  @icdabgithub

### macOS 崩溃报告虚拟内存部分

崩溃报告接下来是虚拟内存摘要和区域类型细分。如果我们有一个用来渲染文档页面的图形丰富的应用程序，则可以查看，例如 CoreUI 的内存消耗。尽当我们用  Xcode Instruments 中的 memory profiler 工具分析该应用程序时，虚拟内存统计信息才有意义，因为这样我们就可以了解应用程序中内存的动态使用情况，从来在错误发生时发现错误。

这是报告的虚拟内存部分的示例：

```
VM Region Summary:
ReadOnly portion of Libraries: Total=544.2M resident=0K(0%)
swapped_out_or_unallocated=544.2M(100%)
Writable regions: Total=157.9M written=0K(0%) resident=0K(0%)
swapped_out=0K(0%) unallocated=157.9M(100%)

                                VIRTUAL   REGION
REGION TYPE                        SIZE    COUNT (non-coalesced)
===========                     =======  =======
Accelerate framework               128K        2
Activity Tracing                   256K        2
CoreAnimation                      700K       16
CoreGraphics                         8K        2
CoreImage                           20K        4
CoreServices                      11.9M        3
CoreUI image data                  764K        6
CoreUI image file                  364K        8
Foundation                          24K        3
IOKit                             7940K        2
Image IO                           144K        2
Kernel Alloc Once                    8K        2
MALLOC                           133.1M       36
MALLOC guard page                   48K       13
Memory Tag 242                      12K        2
Memory Tag 251                      16K        2
OpenGL GLSL                        256K        4
SQLite page cache                   64K        2
STACK GUARD                       56.0M        6
Stack                             10.0M        8
VM_ALLOCATE                        640K        8
__DATA                            58.3M      514
__FONT_DATA                          4K        2
__GLSLBUILTINS                    2588K        2
__LINKEDIT                       194.0M       26
__TEXT                           350.2M      516
__UNICODE                          560K        2
mapped file                       78.2M       29
shared memory                     2824K       11
===========                     =======  =======
TOTAL                            908.7M     1206
```

### macOS崩溃报告系统配置文件部分

崩溃报告的下一部分是相关硬件的摘要：

```
System Profile:
Network Service: Wi-Fi, AirPort, en1
Thunderbolt Bus: iMac, Apple Inc., 26.1
Boot Volume File System Type: apfs
Memory Module: BANK 0/DIMM0, 8 GB, DDR3, 1600 MHz, 0x802C,
 0x31364B544631473634485A2D314736453220
Memory Module: BANK 1/DIMM0, 8 GB, DDR3, 1600 MHz, 0x802C,
 0x31364B544631473634485A2D314736453220
USB Device: USB 3.0 Bus
USB Device: BRCM20702 Hub
USB Device: Bluetooth USB Host Controller
USB Device: FaceTime HD Camera (Built-in)
USB Device: iPod
USB Device: USB Keyboard
Serial ATA Device: APPLE SSD SM0512F, 500.28 GB
Model: iMac15,1, BootROM IM151.0217.B00, 4 processors,
 Intel Core i5, 3.5 GHz, 16 GB, SMC 2.22f16
Graphics: AMD Radeon R9 M290X, AMD Radeon R9 M290X, PCIe
AirPort: spairport_wireless_card_type_airport_extreme
 (0x14E4, 0x142), Broadcom BCM43xx 1.0 (7.77.37.31.1a9)
Bluetooth: Version 6.0.6f2, 3 services, 27 devices,
 1 incoming serial ports
```

有时，我们的应用程序与硬件设备进行紧密交互，如果通过基于标准的设备接口（例如 USB 接口）进行交互，则有可能会发生很多变化。考虑一下磁盘驱动。许多供应商提供磁盘驱动器，它们可能直接或独立运行。它们可以直接连接，或通过 USB 电缆连接，也可以通过 USB 集线器连接。

有时新的硬件，例如新型 MacBook Pro 会出现自己的硬件问题，因此可以看到与我们的应用程序无关的崩溃。

判断是否是硬件环境导致崩溃的关键是查看大量的崩溃报告以寻找某种规律。

作为应用程序开发人员，我们只会看到应用程序中的崩溃。但如果我们与提供崩溃的用户联系，我们可以询问是否有其他应用程序崩溃，或者是否存在任何系统稳定性问题。

另一个有趣的方面是，并非所有硬件都始终被系统主动使用。例如，当 MacBook Pro 连接到外部显示器时，将使用不同的图形RAM，并使用不同的图形卡（外部GPU与内部GPU）。如果我们的应用程序执行特殊操作，则在连接到外部显示器时，故障可能出在硬件而非我们的代码中，原因是它触发了硬件中的潜在故障。

运行系统诊断程序并查看仅针对特定的匿名 UUID 故障报告是否出现问题，是尝试并了解应用程序是否存在特定的计算机硬件问题的方法。

