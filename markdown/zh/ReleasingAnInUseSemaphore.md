## 释放正在使用的信号量

`libdispatch`库支持识别运行时问题。
出现此类问题时，应用程序崩溃并显示异常类型， `EXC_BREAKPOINT (SIGTRAP)`

我们使用 `icdab_sema`示例程序来演示 `libdispatch` 检测到的由于错误使用信号量而导致的崩溃。@icdabgithub

`libdispatch` 库是用于管理并发的操作系统库（称为Grand Central Dispatch或GCD）。该库可从Apple处以开源形式获得。@libdispatchtar

该库抽象了操作系统如何提供对多核CPU资源的访问的详细信息。 在崩溃期间，它会向崩溃报告提供其他信息。 这意味着，如果我们愿意，我们可以找到检测到运行时问题的代码。

### 释放信号量的崩溃示例

`icdab_sema` 示例程序在启动时发生崩溃。
崩溃报告如下（为便于演示，将其截断）：

```
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x00000001814076b8
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
Terminating Process: exc handler [0]
Triggered by Thread:  0

Application Specific Information:
BUG IN CLIENT OF LIBDISPATCH:
 Semaphore object deallocated while in use
Abort Cause 1

Filtered syslog:
None found

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libdispatch.dylib             	0x00000001814076b8
 _dispatch_semaphore_dispose$VARIANT$mp + 76
1   libdispatch.dylib             	0x00000001814067f0
 _dispatch_dispose$VARIANT$mp + 80
2   icdab_sema_ios                	0x00000001006ea98c
 use_sema + 27020 (main.m:18)
3   icdab_sema_ios                	0x00000001006ea9bc
 main + 27068 (main.m:22)
4   libdyld.dylib                 	0x0000000181469fc0
 start + 4

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x00000001c409df10   x1: 0x000000016f71ba4f
       x2: 0xffffffffffffffe0   x3: 0x00000001c409df20
    x4: 0x00000001c409df80   x5: 0x0000000000000044
       x6: 0x000000018525c984   x7: 0x0000000000000400
    x8: 0x0000000000000001   x9: 0x0000000000000000
      x10: 0x000000018140766c  x11: 0x000000000001dc01
   x12: 0x000000000001db00  x13: 0x0000000000000001
     x14: 0x0000000000000000  x15: 0x0001dc010001dcc0
   x16: 0x000000018140766c  x17: 0x0000000181404b58
     x18: 0x0000000000000000  x19: 0x00000001b38f4c80
   x20: 0x0000000000000000  x21: 0x0000000000000000
     x22: 0x00000001c409df10  x23: 0x0000000000000000
   x24: 0x0000000000000000  x25: 0x0000000000000000
     x26: 0x0000000000000000  x27: 0x0000000000000000
   x28: 0x000000016f71bb18   fp: 0x000000016f71ba70
      lr: 0x00000001814067f0
    sp: 0x000000016f71ba40   pc: 0x00000001814076b8
     cpsr: 0x80000000
```

### 错误的信号量代码

重现信号量问题的代码基于使用手动引用计数（MRC）的Xcode项目。 这是一个旧设置，但在与遗留代码库集成时可能会遇到。 在项目级别，将选项 “Objective-C Automatic Reference Counting” 设置为“NO”。 然后，我们可以直接调用 `dispatch_release` API。

代码如下：

```
#import <Foundation/Foundation.h>

void use_sema() {
    dispatch_semaphore_t aSemaphore =
     dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore,
       DISPATCH_TIME_FOREVER);
    // dispatch_semaphore_signal(aSemaphore);
    dispatch_release(aSemaphore);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        use_sema();
    }
    return 0;
}
```

### 使用特定于应用程序的崩溃报告信息

在我们的示例中，崩溃报告的  `Application Specific Information`  部分直接说明了问题。

```
BUG IN CLIENT OF LIBDISPATCH:
 Semaphore object deallocated while in use
```

我们只需要给信号量发信号就可以避免这个问题。

如果我们有一个更不寻常的问题，或者想更深入地了解它，我们可以查找该库的源代码，并在代码中找到相关诊断消息。

以下是相关的库代码：

```
void
_dispatch_semaphore_dispose(dispatch_object_t dou,
		DISPATCH_UNUSED bool *allow_free)
{
	dispatch_semaphore_t dsema = dou._dsema;

	if (dsema->dsema_value < dsema->dsema_orig) {
		DISPATCH_CLIENT_CRASH(
      dsema->dsema_orig - dsema->dsema_value,
				"Semaphore object deallocated
 while in use"
    );
	}

	_dispatch_sema4_dispose(&dsema->dsema_sema,
     _DSEMA4_POLICY_FIFO);
}
```

在这里，我们可以通过 `DISPATCH_CLIENT_CRASH` 宏查看导致崩溃的库。

### 经验教训

在现代应用程序代码中，应避免使用手动引用计数。

当通过运行时库发生崩溃时，我们需要返回API规范以了解我们如何违反导致崩溃的API合同。崩溃报告中特定于应用程序的信息应该有助于我们在重新阅读API文档、研究工作样例代码和查看运行时库源代码的详细级别(如果可用)时集中注意力。

如果已从旧代码库中继承了MRC代码，则应使用设计模式来包装基于MRC的代码，并向其中提供干净的API。然后，该程序的其余部分可以使用自动引用计数（ARC）。这将包含问题，并允许新代码从ARC中受益。 也可以将特定文件标记为MRC。需要为文件设置编译器标志选项 `-fno-objc-arc`。可以在 Xcode 的 _Build Phases-> Compile Sources_区域中找到它。

如果遗留代码不需要增强，则最好将其保留下来，而仅用 Facade API 对其进行包装。 然后，我们可以为该API编写一些测试用例。未主动更新的代码往往仅在以新方式使用时才会引起错误。有时，具有遗留代码知识的员工已离开项目，因此知识较少的员工进行更新可能会带来风险。

如果可以随时间替换旧代码，那就太好了。 通常，需要业务证明。 一种策略是将旧模块分解成较小的部分。 如果能战略性地做到这一点，那么可以采用现代编码实践对较小的部分之一进行重新加工。当增强了此类模块以解决新客户需求时，它将成为双赢。
