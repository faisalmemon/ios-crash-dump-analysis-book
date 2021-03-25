# Pointer Authentication（指针验证机制）

在本章中，我们将研究指针验证机制以及相关的崩溃。

使用 Apple A12\index{CPU!A12} 芯片或更高版本的设备将称为 _Pointer Authentication_ 的安全功能作为 ARMv8.3-A\index{ARM!v8.3-A} 体系结构的一部分。例如， iPhone XS\index{trademark!iPhone XS}，iPhone XS Max\index{trademark!iPhone XS Max}, 和 iPhone XR\index{trademark!iPhone XR} 使用 A12芯片。其基本思想是在 64 位指针中存在未使用的位，因为它已经可以寻址相当广泛的地址，因此只有 40 位被分配给这样的目的。 @iospac  因此，剩余的位可用于存储在将预期的指针地址与上下文值和密钥组合后计算出的哈希值。 然后，如果由于错误或恶意操作而要更改指针地址，则该指针将被认为是无效的，并且如果将其用于更改程序的控制流，则最终将导致 SIGSEGV。

实际上，在许多情况下都使用了指针验证机制，例如确保 C++  虚拟调度表未被篡改。 但是，我们只看一个错误操作跳转地址的简单情况。因此，我们只看一个错误操作跳转地址的简单情况。

## 配置指针验证机制

在使用 A12 或更高版本的设备，Apple 在设备内核中启用了指针验证机制。对于用户空间代码，指针身份验证是一项可选功能。可以在项目的_构建设置_中来启用它，如图为 `icdab_ptr` 示例 _Enable Pointer Authentication_（启用指针验证机制）。 @icdabgithub  我们将架构 `arm64e`  添加到架构设置中。

![Enable Pointer Authentication](screenshots/enable_ptr_auth.png)

如果我们正在编写对安全性敏感的软件，那么值得尽早的采用此功能。

## 操纵指针

让我们考虑下面的程序，该程序以人工方式操纵指针，以揭示指针验证机制背后的一些思想。

```
#import "ViewController.h"

#include "ptrauth.h"

@interface ViewController ()

@end

@implementation ViewController

typedef void(*ptrFn)(void);

static void interestingJumpToFunc(void) {
    NSLog(@"Simple interestingJumpToFunc\n");
}

// this function's address is where we will be jumping to
static void nextInterestingJumpToFunc(void) {
    NSLog(@"Simple nextInterestingJumpToFunc\n");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ptrFn result = [self generatePtrToFn];
    NSLog(@"ptrFn result is %p\n", result);
    result(); // will crash; deferences a pointer with a bad PAC
}

- (ptrFn)generatePtrToFn {
    uintptr_t a1 = (uintptr_t)interestingJumpToFunc;
    uintptr_t a2 = (uintptr_t)nextInterestingJumpToFunc;
    NSLog(@"ptr addresses as uintptr_t are 0x%lx 0x%lx\n",
          a1, a2);
    ptrdiff_t delta = a2 - a1;
    ptrdiff_t clean_delta =
    ptrauth_strip(&nextInterestingJumpToFunc,
                  ptrauth_key_asia) -
    ptrauth_strip(&interestingJumpToFunc,
                  ptrauth_key_asia);
    
    NSLog(@"delta is 0x%lx clean_delta is 0x%tx\n", delta,
 clean_delta);
    
    ptrFn func = interestingJumpToFunc;
    func += clean_delta; // correct offset but neglects PAC
 component
    return func;
}
```

如果运行上述程序，则会崩溃。 该程序的日志输出为：

```
ptr addresses as uintptr_t are 0x2946180102c55dd8
 0x22b810102c55df8
delta is 0xd8e5690000000020 clean_delta is 0x20
ptrFn result is 0x2946180102c55df8
```

我们看到，当获得指向函数`interestingJumpToFunc` 的指针，然后将其存储在足以容纳指针地址的整数中时，我们将获得一个较大的值`0x2946180102c55dd8`。 这是因为地址的前24位是指针验证码（PAC）\index{Pointer Authentication Code}\index{PAC}。 在这种情况下，PAC 为 `0x294618` ，有效指针为`0x0102c55dd8`。

在物理上相邻的下一个指针 `nextInterestingJumpToFunc` 是 `0x22b810102c55df8`； 显然，它具有相似的有效地址`0x0102c55df8`，但具有完全不同的 PAC `0x22b81`。

当我们计算指针之间的增量时，由于指针值的 PAC 部分，我们显然会得到一个无意义的地址。 为了正确计算指针的有效地址之间的增量，我们需要使用 `ptrauth_strip`实用程序函数。 这是作为内置宏汇编指令实现的。

经过宏预处理后，代码为：

```
ptrdiff_t clean_delta =
    __builtin_ptrauth_strip(&nextInterestingJumpToFunc,
 ptrauth_key_asia) -

    __builtin_ptrauth_strip(&interestingJumpToFunc,
 ptrauth_key_asia);
```

生成的装配说明的格式为：
```
	xpaci	x9
```
当使用 `__builtin_ptrauth_strip` 剥离功能时。 这将从寄存器（在本例中为`x9`）中删除PAC。

使用带状函数的好处是我们能够正确确定感兴趣的两个函数之间的距离。它是 `0x20`。 我们的函数 `generatePtrToFn` 实际上只是将delta加到`interestingJumpToFunc`的地址上来计算 `nextInterestingJumpToFunc` 的地址，但是这样做是错误的。 它将PAC在其计算出的地址中留给`interestingJumpToFunc`。

请注意，这类指针操作均不会导致崩溃。 检查指针的时间是用于更改链接寄存器\index{register!link} 的时间。 也就，当我们根据指针值来更改程序的控制流时。

在函数 `viewDidLoad()` 我们存在以下代码
```
result(); // will crash; deferences a pointer with a bad PAC
```

使用的指针是我们的错误指针`0x2946180102c55df8`。 汇编指令检测到错误的指针

```
blraaz	x8
```

这是具有指向注册的链接的分支，具有使用指令密钥 A 的指针身份验证。

请注意，当我们剥离指针时，我们使用了`ptrauth_key_asia`来删除指令密钥A。但是，我们无法访问执行相反操作所需的特殊值，而是使用带有适当的 _salt_ 的指令密钥A来对指针进行签名值以获取上下文中正确的带符号指针。

现在，我们已经检查了错误的代码，让我们看看崩溃时会发生什么。

