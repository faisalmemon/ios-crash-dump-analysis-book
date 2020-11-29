## 在 mac 上运行 iOS

由于 Apple Silicon Macs 和 iOS 设备共享相同的 ARM CPU 体系结构，因此Apple提供了_附加功能_。 未经修改的 iOS 应用程序可能会在基于 ARM 的 macOS 上运行。 为此，基于 ARM 的 macOS 拥有了一些特殊的 iOS 支持库。

我们可以这样想，macOS （_主语_）是提供支持库和框架的 ，提供 iOS（ _宾语_ ）应用程序期望的 UIKit。

当此类应用程序崩溃时，我们会获得崩溃报告，该报告是 macOS 崩溃报告，但大多数细节都涉及 iOS 库。

