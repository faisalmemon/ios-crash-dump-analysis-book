# 基本概念

## 什么是崩溃?

我们的计算机内部是一个操作环境。它包括一个或多个正在运行的操作系统以及应用程序软件。两者的区别在于，操作系统软件在比应用程序软件（用户模式）更高的 CPU 权限（内核模式）下运行。

我们通常理解为我们的应用软件的基本概念模型是位于一个操作系统上，而操作系统本身又是位于硬件上。

但是，现代计算机系统具有多个协作子系统。例如，配备 TouchBar 的MacBook Pro即具有主操作系统macOS，同时也有支持处理 TouchBar 界面、磁盘加密 和  “Hey Siri” 的 Bridge OS。我们计算机中的多媒体和网络芯片是高级组件，可以在其上运行自己的实时操作系统。我们的 Mac 软件只是 macOS 上运行的众多应用程序之一。

应用程序崩溃是操作环境响应我们在应用程序中所做的（或未完成的）某些操作，这些操作违反了我们所运行的平台的某些规则。

当操作系统检测到系统中存在问题时，它可能会自行崩溃。 这称为 `kernel panic`\index{crash!kernel panic}。

## 操作系统的规则

操作环境通过某些规则来保障用户的环境安全性、数据安全性、性能和隐私性。

### Nil 处理示例

Apple 生态系统的新手常常惊讶地发现，Objective-C 允许我们向 nil 对象发送消息。 它默默地忽略了失败的调用。 例如，
以下方法可以运行正常。

```
- (void)nilDispatchDoesNothing
{
    NSString *error = NULL;
    assert([error length] == 0);
}
```

Objective-C 运行时的开发者做出了一个判断，并认为应用程序最好忽略这些问题。


但是，如果我们引用了一个 C 指针，应用程序就会发生崩溃。
```
void nullDereferenceCrash() {
    char *nullPointer = NULL;
    assert(strlen(nullPointer) == 0);
}
```

操作系统的开发者为了避免对空指针地址或更底层的内存地址的非法访问，所以中断了应用程序 。

操作系统将此内存区域留出，因为它表示未正确设置对象或数据结构的编程错误。  

当出现问题时，我们并不总是会崩溃。 只有它违反运行环境的规则，应用程序才会发生崩溃。

### 获取 MAC 地址示例

参考获取 iPhone 的的 MAC 的示例。媒体访问控制（MAC）地址是分配给网卡的唯一识别码，用来允许机器在通信栈的数据链路层进行没有重复地相互通信。

在 iOS 7 之前，MAC 地址不被视为敏感 API。因此，使用 `sysctl` API 请求 MAC 地址会给出真实地址。要查看此操作，请参阅 `icdab_sample` 应用程序。

不幸的是，此 API 作为跟踪用户的一种方式而被开发者滥用 ，这违反了隐私协议。因此，Apple 在 iOS 7 中引入了一项新的方式，API 始终会返回固定的 MAC 地址。

当调用 `sysctl` API 时，Apple 本来可以选择使我们的应用程序崩溃。但是，`sysctl` 是一种通用的底层调用，它可用于其他有效目的。因此，iOS 设置的策略是在请求时返回固定的 MAC 地址 `02:00:00:00:00:00`。

### 获取相机权限示例

现在，让我们考虑使用相机拍摄照片的情况。

在 iOS 10 中，当我们的应用程序需要使用设备相机（隐私且敏感）功能时，我们需要定义一段阅读性良好的授权文案，以便用户理解并给予相机的访问权限。

即便我们没有在 `Info.plist` 中为 `NSCameraUsageDescription` 定义授权描述，以下代码的判断结果还是正确的，系统会尝试弹出相册选择器。

```
if UIImagePickerController.isSourceTypeAvailable(
      UIImagePickerControllerSourceType.camera) {
      // Use Xcode 9.4.1 to see it enter here
      // Xcode 10.0 will skip over
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType =
       UIImagePickerControllerSourceType.camera
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
      }
```

然而，当我们使用Xcode 9.4.1版本运行上面的代码时，我们在控制台会看到以下崩溃的描述性信息：

```
2018-07-10 20:09:21.549897+0100 icdab_sample[1775:15601294]
 [access] This app has crashed because it attempted to access
  privacy-sensitive data without a usage description.  
  The app's Info.plist must contain an NSCameraUsageDescription
   key with a string value explaining to the user how the app
   uses this data.
Message from debugger: Terminated due to signal 9
```

### 经验教育

请注意这里的对比。这两种情况下我们都调用了涉及隐私敏感的API。但是在相机的案例中，Apple 选择了让应用程序崩溃而不是谈一个弹框给出警告，或者是返回一个错误的值来表明源类型不可用。

这似乎是一个苛刻的设计选择。当用户在 Xcode 10.0（提供了 iOS 12 的SDK） 进行操作时， 这个调用相机授权的 API 有了不一样的表现。当由于未在 `Info.plist` 中定义授权描述是，判断相机是否可用API会返回 `false`。

这强调了涉及两个实体的意义，即程序和操作环境（包括其策略）。拥有正确的源代码并不能保证程序能够正常运行。 当我们的应用程序发生崩溃时，我们需要考虑操作环境以及代码本身。

## 应用程序的策略

我们正在编写的应用程序也可以主动引发崩溃。这通常通过我们的代码中的断言调用来完成的。任何断言的失败，这些调用都会要求操作环境立即终止我们的应用程序。 然后操作环境就终止了我们的应用程序。
那么在崩溃报告中我们会得到这样一个类型:

`Exception Type:  EXC_CRASH (SIGABRT)`

表明应用程序在第一时间主动触发崩溃

### 什么时候应该主动触发崩溃？

我们可以遵循与操作环境类似的标准来制定我们应用的崩溃策略。

如果我们的代码检测到数据的完整性存在问题，我们可能会触发崩溃以防止进一步的数据损坏。

### 什么时候不应该触发崩溃

如果问题直接来自某些 IO 问题（例如文件或网络访问）或某些人为的输入问题（例如错误的日期值）那么我们不应改触发崩溃。

作为应用程序开发人员，我们的工作是保护系统的底层部分免受现实世界中存在的不可预测性的影响。通过日志记录，错误处理，用户警报和 IO 重试，可以更好地解决此类问题。

## 工程指导

我们应如何防范上述的私隐问题?

需要记住的是，任何涉及操作环境保护策略的代码都是自动化测试的理想选择。

在 `icdab_sample` 项目中我们已经创建了单元测试和 UI 测试。

当将测试用例应用于处理琐碎的程序时，我们总会感到无所适从。 但是考虑一个具有拓展性的 `Info.plist` 文件的大型程序。当我们要创建一个新版本而需要创建另一个新的 `Info.plist` 文件。那么在不同构建目标建如何保持隐私协议设置的同步就会成为一个问题。那么仅针对启动相机的 UI 测试代码可以轻松捕获到此类问题，因此具有实用的商业价值。

同样，如果我们的 APP 包含大量的底层代码，然后我们需要将APP从iOS系统移植到tvOS，那么有多少涉及操作系统的敏感代码会仍然适用呢。 

针对不同的设计考虑全面地对顶级功能进行单元测试可以抵消在我们对代码库中深入研究和单元测试潜在的辅助函数调用所耗费的精力。 这是一项战略性工作，可让我们在移植到 Apple 生态系统（及以后）中的其他平台时对自己的应用程序和对问题领域的早期反馈充满信心。

### 单元测试获取 MAC 地址

获取MAC地址的代码并非易事。 因此，它需要进行一定程度的测试。

下面是单元测试代码的摘录：

```
    func getFirstOctectAsInt(_ macAddress: String) -> Int {
        let firstOctect = macAddress.split(separator: ":").first!
        let firstOctectAsNumber = Int(String(firstOctect))!
        return firstOctectAsNumber
    }

    func testMacAddressNotNil() {
        let macAddress = MacAddress().getMacAddress()
        XCTAssertNotNil(macAddress)
    }

    func testMacAddressIsNotRandom() {
        let macAddressFirst = MacAddress().getMacAddress()
        let macAddressSecond = MacAddress().getMacAddress()
        XCTAssert(macAddressFirst == macAddressSecond)
    }

    func testMacAddressIsUnicast() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 1))
    }

    func testMacAddressIsGloballyUnique() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 2))
    }
```

实际上，最后一个测试用例会失败，因为操作系统会返回本地地址。

### UI Tests 测试访问相机

为了测试访问相机的功能，我们编写了一个简单的 UI 测试用例，模拟按下了拍照按钮（通过辅助功能标识符 `takePhotoButton` ）

```
func testTakePhoto() {
    let app = XCUIApplication()
    app.buttons["takePhotoButton"].tap()
}
```

这个 UI 测试代码会导致立即崩溃。

> 如果用户并未授权的时候

