# Siri崩溃

## 我们为什么要关注 Siri 崩溃？

这是 Siri 在 Mac 上崩溃的示例。 请注意，Mac 上的二进制文件未加密。这意味着我们可以演示如何使用第三方工具来研究出错的二进制文件。但由于只有 Apple 拥有 Siri 的源代码，因此它增加了挑战难度，并迫使我们对问题进行抽象思考。

## 崩溃报告

以下是崩溃报告，为了便于演示，将其适当截断：

```
Process:               SiriNCService [1045]
Path:                  
/System/Library/CoreServices/Siri.app/Contents/
XPCServices/SiriNCService.xpc/Contents/MacOS/SiriNCService
Identifier:            com.apple.SiriNCService
Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       KERN_INVALID_ADDRESS at 0x0000000000000018
Exception Note:        EXC_CORPSE_NOTIFY
VM Regions Near 0x18:
-->
    __TEXT                 0000000100238000-0000000100247000
    [   60K] r-x/rwx SM=COW
    /System/Library/CoreServices/Siri.app/Contents/
    XPCServices/SiriNCService.xpc/Contents/MacOS/SiriNCService

Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:

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
10  com.apple.AppKit              	
0x00007fff4039ca73 _DPSNextEvent + 2085
11  com.apple.AppKit              	0x00007fff40b32e34
-[NSApplication(NSEvent) _nextEventMatchingEventMask:
untilDate:inMode:dequeue:] + 3044
12  com.apple.ViewBridge          	0x00007fff67859df0
-[NSViewServiceApplication nextEventMatchingMask:untilDate:
inMode:dequeue:] + 92
13  com.apple.AppKit              	0x00007fff40391885
-[NSApplication run] + 764
14  com.apple.AppKit              	0x00007fff40360a72
NSApplicationMain + 804
15  libxpc.dylib                  	
0x00007fff6af6cdc7 _xpc_objc_main + 580
16  libxpc.dylib                  	
0x00007fff6af6ba1a xpc_main + 433
17  com.apple.ViewBridge          	0x00007fff67859c15
-[NSXPCSharedListener resume] + 16
18  com.apple.ViewBridge          	0x00007fff67857abe
NSViewServiceApplicationMain + 2903
19  com.apple.SiriNCService       	
0x00000001002396e0 main + 180
20  libdyld.dylib                 	
0x00007fff6ac12015 start + 1
```

## 崩溃详情

看着这个 09:52 发生的崩溃，我们可以看到

`Exception Type:        EXC_BAD_ACCESS (SIGSEGV)`

这意味着我们正在访问不存在的内存。
正在运行的程序（称为TEXT）是

```
/System/Library/CoreServices/Siri.app/Contents/
XPCServices/SiriNCService.xpc/Contents/MacOS/SiriNCService
```

这很有趣，因为通常是应用程序发生崩溃。 但在这里，我们看到一个软件组件发生了崩溃。
Siri服务是一个分布式应用程序，它使用跨进程通信（xpc）来完成其工作。
从上面对xpc的引用中我们可以看到。

我们在试图调用一个不再存在的对象的方法是什么？
crash dump 为我们提供了有用的答案：

`
Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:
`

现在我们必须对崩溃的三个方面 _what_, _where_ 和 _when_ 做出一个近似的解答。
在 `SiriNCService`中，当对一个不存在的对象调用`didUnlockScreen`时，Siri 的一个组件崩溃了。 

## 使用我们的工具

为了更进一步了解，我们需要使用 `class-dump`工具。

`class-dump SiriNCService > SiriNCService.classdump.txt`

查看输出的一部分，如下所示：

```
@property __weak SiriNCService *service;
 // @synthesize service=_service;
- (void).cxx_destruct;
- (BOOL)isSiriListening;
- (void)_didUnlockScreen:(id)arg1;
- (void)_didLockScreen:(id)arg1;
```

我们看到确实有一个方法 `didUnlockScreen`，并且我们看到有一个 `service` 对象，该对象被 **弱** 引用。 这意味着该对象未保留，可能会释放。 通常，这意味着我们只是 SiriNCService 的用户，而不是所有者。 我们并不持有对象的生命周期。

## 软件工程见解

这里潜在的软件工程问题是生命周期问题。应用程序的一部分具有我们没有预料到的对象生命周期。作为健壮性和防御性编程的最佳实践，应该编写代码来检测服务的缺失。有可能发生的情况是，软件会随着时间的推移而得到维护，但随着新功能的添加，对象的生命周期会变得更加复杂，但使用对象的旧代码却没有同步更新。

再进一步，我们应该问这个组件使用了哪些弱属性？由此我们可以创建一些简单的单元测试用例，当这些对象为 nil 时，它们可以测试代码。然后我们可以回过头来，为代码路径添加健壮性，假设对象是非 nil 的。

进一步回顾一下，这个组件的设计中是否有什么不寻常的地方需要进行集成测试?

```
grep -i heat SiriNCService.classdump.txt
@protocol SiriUXHeaterDelegate <NSObject>
- (void)heaterSuggestsPreheating:(SiriUXHeater *)arg1;
- (void)heaterSuggestsDefrosting:(SiriUXHeater *)arg1;
@interface SiriNCAlertViewController : NSViewController
<SiriUXHeaterDelegate, AFUISiriViewControllerDataSource,
 AFUISiriViewControllerDelegate>
    SiriUXHeater *_heater;
@property(readonly, nonatomic)
SiriUXHeater *heater; // @synthesize heater=_heater;
- (void)heaterSuggestsPreheating:(id)arg1;
- (void)heaterSuggestsDefrosting:(id)arg1;
@interface SiriUXHeater : NSObject
    id <SiriUXHeaterDelegate> _delegate;
@property(nonatomic)
__weak id <SiriUXHeaterDelegate> delegate;
 // @synthesize delegate=_delegate;
- (void)_suggestPreheat;
```

该组件似乎可以准备就绪，并具有各种级别的初始化和取消初始化。也许这种复杂性是为了让用户界面具有响应性。但是它向我们传递了这样一个信息：这个组件需要一个集成测试套件，它可以对状态机进行编码，以便我们了解服务的生命周期

## 经验教训

我们从使用 HOWTO 知识（了解崩溃报告）到使用工具来获得基本的知识水平。然后，我们开始应用软件工程经验，然后开始对组件的实际设计进行推理，以询问我们如何到达这里以及应该采取什么措施来避免该问题。在 crash dump  分析期间，从查看问题的伪像到了解需要做的事情的过程是一个常见的主题。而仅仅专注于理解崩溃报告的方法是无法实现的。为了真正取得进展，我们需要换个角度，从不同角度看待事物。

