# 符号化

本章介绍了 crash dump 的符号化。符号化是将机器地址映射成对拥有源代码的程序员有意义的符号地址的过程。我们希望尽可能看到函数名（加上任何偏移量），而不是看到机器地址。

我们使用 `icdab_planets` 示例应用程序来演示崩溃。@icdabgithub

当处理真实的崩溃时，一般会涉及到很多不同的关联数据。这些数据可以来自用户终端，通过设置允许将崩溃报告上传到 Apple 的终端设备，Apple 拥有的符号信息和我们本地开发环境的配置信息可以相互映射。

为了理解所有信息是如何组合在一起的，最好从一开始开始就自己完成数据转化任务，因此一旦我们需要诊断符号化问题，我们就已有一定的技术经验。

## 构建过程

通常，当我们开发应用程序时，我们会将应用程序的 `Debug` 版本构建到我们的设备上。而当我们为测试人员、应用程序审核或应用商店构建应用时，我们构建应用程序的 `Release` 版本。

默认情况下，对于 `Release`版本，`.o` 文件的调试信息被存储在一个单独的目录结构中。被称作 ` our_app_name.DSYM`。

当开发人员发现崩溃时，可以使用这些调试信息来帮助我们理解程序在哪里出错了。

当用户发现我们的应用程序崩溃时，并没有开发人员在身边。所以，会生成一份崩溃报告。它包含出现问题的机器地址。符号化可以将这些地址转换为有意义的源代码来作为参考。

为了进行符号化，必须拥有对应的 DSYM 文件。

默认情况下，Xcode 被设置为只为 `Release` 版本生成 DSYM 文件，`Debug` 版本则不会生成该文件。

## 构建设置

打开 Xcode，选择 build settings，搜索 "Debug Information Format"，可以看到如下设置：

Setting|Meaning|Usually set for target
--|--|--
DWARF|调试信息仅在 `.o` 文件中 |Debug
DWARF with dSYM File|除了`.o` 文件，也会将调试信息整理到 DSYM 文件中 |Release

在默认设置中，如果我们在测试设备上调试 APP 时，点击应用图标并启动 APP ，那么如果发生崩溃，我们并没有在崩溃报告中看到任何符号。这使许多人感到困惑。

这是因为二进制文件的 UUID 和 DSYM 并不匹配。

为了避免这个问题，示例程序 `icdab_planets` 在 `Debug `和 `Release` 两个 Target 中全都设置为 `DWARF with dSYM File` 。然后我们就可以进行符号化，因为在 Mac 上会生成一个可供匹配的 DSYM。

## 关注开发环境的崩溃

`icdab_planets` 程序被设计为在启动时由于断言而崩溃。

如果没有设置成`DWARF with dSYM File`，我们会得到一个象征性的部分符号化的崩溃报告。 

从 `Windows->Devices and Simulators->View Device Logs` 中看到的崩溃报告看起来像这样（为了便于演示而截断）

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        
0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       
0x0000000183ba2288 pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	
0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	
0x0000000183944000 basename_r + 0
4   icdab_planets                 	
0x00000001008e45bc 0x1008e0000 + 17852
5   UIKit                         	
0x000000018db56ee0
-[UIViewController loadViewIfRequired] + 1020

Binary Images:
0x1008e0000 - 0x1008ebfff icdab_planets arm64
  <9ff56cfacd66354ea85ff5973137f011>
   /var/containers/Bundle/Application/
   BEF249D9-1520-40F7-93F4-8B99D913A4AC/
   icdab_planets.app/icdab_planets
```

但是，如果设置成`DWARF with dSYM File`，崩溃报告则会像这样：

```
Thread 0 Crashed:
0   libsystem_kernel.dylib        	
0x0000000183a012ec __pthread_kill + 8
1   libsystem_pthread.dylib       	
0x0000000183ba2288
pthread_kill$VARIANT$mp + 376
2   libsystem_c.dylib             	
0x000000018396fd0c abort + 140
3   libsystem_c.dylib             	
0x0000000183944000 basename_r + 0
4   icdab_planets                 	
0x0000000104e145bc
-[PlanetViewController viewDidLoad] + 17852
 (PlanetViewController.mm:33)
5   UIKit                         	
0x000000018db56ee0
-[UIViewController loadViewIfRequired] + 1020
```

报告的第0、1、2、5行在两种情况下是相同的，因为我们的开发环境具有正在测试的 iOS 版本的符号信息。在第二种情况下，Xcode 将查找 DSYM 文件以阐明第 4 行。它告诉我们这是在 PlanetViewController.mm 文件中的第33行。 是：

```
assert(pluto_volume != 0.0);
```

## DSYM 结构

DSYM 文件严格来说是一个目录层次结构：
```
icdab_planets.app.dSYM
icdab_planets.app.dSYM/Contents
icdab_planets.app.dSYM/Contents/Resources
icdab_planets.app.dSYM/Contents/Resources/DWARF
icdab_planets.app.dSYM/Contents/Resources/DWARF/icdab_planets
icdab_planets.app.dSYM/Contents/Info.plist
```

只是将通常放在 `.o` 文件中的 DWARF 数据，复制到另一个单独的文件中。

通过查看构建日志，我们可以看到 DSYM 是如何生成的。它实际上只是因为这个命令： `dsymutil path_to_app_binary -o output_symbols_dir.dSYM`

## 着手符号化

为了帮助我们熟悉 crash dump 报告，我们可以演示实际上符号化是如何工作的。在第一段报告中，我们想要了解：

```
4   icdab_planets                 	
0x00000001008e45bc 0x1008e0000 + 17852
```

如果我们能在崩溃时准确的知道代码的版本，我们就可以重新编译我们的程序，但是在 DSYM 设置打开的情况下，我们只能在在发生崩溃后获取一个 DSYM 文件。

crash dump 告诉我们崩溃发生时程序在内存中的程序在内存中的地址信息。这告诉我们其他地址（TEXT）位置相对偏移量。

在crash dump 报告的底部，我们有一行`0x1008e0000 - 0x1008ebfff icdab_planets`。 所以 icdab_planets 的位置从 `0x1008e0000` 开始。

运行命令 `atos` 查看你感兴趣的位置信息：
```
# atos -arch arm64 -o
 ./icdab_planets.app.dSYM/Contents/Resources/DWARF/
icdab_planets -l 0x1008e0000 0x00000001008e45bc
-[PlanetViewController viewDidLoad] (in icdab_planets)
 (PlanetViewController.mm:33)
```

崩溃报告工具基本上就是使用 `atos`命令来符号化崩溃报告，以及提供其他与系统相关的信息。

如果想要更加深入的了解符号化过程我们可以通过 Apple Technote 来获取其进一步的描述。@tn2123

## 逆向工程方法

在上面的例子中，我们具有crash dump 的源代码和符号，因此可以执行符号化。

但是有时在我们的项目中，包含了第三方的二进制框架，我们并没有源代码。如果框架提供者提供了相应的符号信息让用户可以进行 crash dump 分析，这当然是很好的。但是当符号信息不可用时，我们仍然可以通过一些逆向工程的手段来取得进展。

与第三方合作时，故障的诊断和排查通常需要更多的时间。我们发现良好的编写且具体的错误报告可以加速很多事情。以下方法可以为你提供所需的特定信息。

我们将使用工具一章中提到的 Hopper 工具来演示我们的方法。

启动 hopper，选择  _File->Read Executable to Disassemble_。我们使用  `examples/assert_crash_ios/icdab_planets`中的二进制文件作为示例。

我们需要 “rebase” 反汇编程序，以便它在崩溃时显示的地址与程序的地址相同。选择 `Modify->Change File Base Address`。为了保持一致，输入 `0x1008E0000`。

现在我们可以看到崩溃代码了。地址 `0x00000001008e45bc` 实际上是设备在跟踪堆栈中执行函数调用后将 _return_ 到的地址。尽管如此，它仍被记录在此。选择 `Navigate-> Go To Address and Symbol` 并输入 `0x00000001008e45bc` 。

我们看到的总体会如下所示

![](screenshots/hopperAddressView.png)

放大这一行，我们能看到

![](screenshots/hopperPlanetAbort.png)

这确实显示了 assert 方法的返回地址。再往上看，我们看到判断了 Pluto 的体积不能为零。这只是 Hopper 非常基本的使用示例。接下来我们将使用 Hopper 演示其最有趣的功能——将汇编代码生成伪代码。这降低了理解崩溃的心理负担。如今，大多数开发人员很少查看汇编代码，所以就这个功能就值得我们为该软件付出代价。

现在至少对于当前的问题吗，我们可以编写一个错误报告，指明由于 Pluto 的体积为零，导致代码崩溃了。对框架的提供者来说，这就足以解决问题了。

在更复杂的情况下，想象我们使用了一个发生崩溃的图片转换库。图片可能有多种像素格式。使用  `assert` 可以让我们注意到某些特定的像素格式。因此，我们可以尝试其他的像素格式。

另一个例子是 security 库。安全代码通常会返回通用错误代码，而不是特定的故障代码，以便将来进行代码增强并避免泄漏内部细节（安全风险）。安全库中的 crash dump 程序可能会指出安全问题的类型，并帮助我们更早地更正传递到库中的某些数据结构。
