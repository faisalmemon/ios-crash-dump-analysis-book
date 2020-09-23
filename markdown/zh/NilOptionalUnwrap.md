## 解包 Nil 可选类型

Swift 编程语言是朝着编写默认安全代码迈出的重要一步。

Swift 的核心概念是明确地处理可选性。在类型声明中，尾随的 `?` 表示该值可以不存在，用 `nil` 表示。这些类型需要显式展开来访问它们存储的值。

当一个值在对象初始化时不可用，但在对象生命周期的后期，然后尾随' !'用于保存值的类型。这意味着可以在代码中处理该值，而不需要显式解包。它被称为可选的隐式解包可选。
注意，从 Swift 4.2 开始，在实现级别，它是可选的，带有注释，表明可以使用它而无需显式解包。

我们使用 `icdab_wrap` 示例程序来演示由于错误使用可选控件而导致的崩溃。@icdabgithub

### iOS UIKit Outlets

使用故事板来声明用户界面，并将`UIViews`与`UIViewController`相关联，这是一个标准范例。

当用户界面更新时，比如启动我们的应用程序时，或者在场景之间执行segue时，故事板实例支持 `UIViewController`并在我们的 `UIViewController`对象中将字段设置为已创建的 `UIViews` 。

当我们将故事板链接到控制器代码时，会自动生成一个字段声明，例如:
```
@IBOutlet weak var planetImageOutlet: UIImageView!
```

### 所有权规则

如果我们没有显式创建对象，并且没有将所有权传递给我们，那我们不应缩短所传递对象的生命周期。

在我们的`icdab_wrap` 示例中，我们有一个父页面，我们可以进入一个具有大冥王星图像的子页面。
该图像是从 Internet 下载的。 当离开该页面并访问原始页面时，代码尝试通过释放与图像关联的内存来减少内存。

对于这种图像清理策略是是否有用可取，存在另一种争论。应该使用一个分析工具来告诉我们什么时候应该尽量减少内存占用。

我们的代码存在一个 bug：
```
override func viewWillDisappear(_ animated: Bool) {
        planetImageOutlet = nil
        // BUG; should be planetImageOutlet.image = nil
    }
```

与其将图像视图的图像设置为 nil，不如将图像视图本身设置为 `nil`。

这意味着当我们重新访问Pluto场景时，由于我们的 `planetImageOutlet` 为`nil`，因此尝试存储下载的图像时会崩溃。

```
func imageDownloaded(_ image: UIImage) {
        self.planetImageOutlet.image = image
    }
```

该代码将崩溃，因为它隐式解包了已设置为 `nil`的可选类型。

### 解包 nil 可选类型的崩溃报告

当我们从 swift 运行时强制解包可选类型 nil 中得到崩溃时，我们看到:
```
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x00000001011f7ff8
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
Terminating Process: exc handler [0]
Triggered by Thread:  0
```

注意这是一个异常类型， `EXC_BREAKPOINT (SIGTRAP)`。

我们看到运行时环境由于遇到问题而引发了断点异常。这是通过查看堆栈顶部的swift核心库来识别的。

```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libswiftCore.dylib            	
0x00000001011f7ff8 0x101050000 + 1736696
1   libswiftCore.dylib            	
0x00000001011f7ff8 0x101050000 + 1736696
2   libswiftCore.dylib            	
0x00000001010982b8 0x101050000 + 295608
3   icdab_wrap                    	
0x0000000100d3d404
 PlanetViewController.imageDownloaded(_:)
  + 37892 (PlanetViewController.swift:45)

```

存在未初始化指针的另一个细微提示是机器寄存器的特殊值是 `0xbaddc0dedeadbead`。
这是由编译器设置的，以指示未初始化的指针：

```
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000100ecc100   x1: 0x00000001c005b9f0   
    x2: 0x0000000000000008
       x3: 0x0000000183a4906c
    x4: 0x0000000000000080   x5: 0x0000000000000020   
    x6: 0x0048000004210103
       x7: 0x00000000000010ff
    x8: 0x00000001c00577f0   x9: 0x0000000000000000  
    x10: 0x0000000000000002
      x11: 0xbaddc0dedeadbead
   x12: 0x0000000000000001  x13: 0x0000000000000002  
   x14: 0x0000000000000000
     x15: 0x000a65756c617620
   x16: 0x0000000183b9b8cc  x17: 0x0000000000000000  
   x18: 0x0000000000000000
     x19: 0x0000000000000000
   x20: 0x0000000000000002  x21: 0x0000000000000039  
   x22: 0x0000000100d3f3d0
     x23: 0x0000000000000002
   x24: 0x000000000000000b  x25: 0x0000000100d3f40a  
   x26: 0x0000000000000014
     x27: 0x0000000000000000
   x28: 0x0000000002ffffff   fp: 0x000000016f0ca8e0   
   lr: 0x00000001011f7ff8
    sp: 0x000000016f0ca8a0   pc: 0x00000001011f7ff8
    cpsr: 0x60000000
```
