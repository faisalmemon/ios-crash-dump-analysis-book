本书填补了当崩溃发生时应用程序开发人员与开发平台之间出现的空白。应用程序开发人员主要想的是高级概念和抽象化。当应用发生崩溃时，现实会把你粗鲁地拉到底层架构、指针和原始数据的 UNIX 世界中。

我们只专注于 Apple 生态系统。

我们的讨论涵盖了 iOS、macOS、tvOS、watchOS 和 BridgeOS 这些平台，ARM 架构和 C(Core Foundation)、Objective-C、Objective-C++ 和 Swift 等多种语言。这是因为较旧的语言更容易崩溃。现实世界中的应用程序最终往往会成为由更安全的 Swift 语言和旧技术的混合体。

我们介绍了苹果生态系统的最新发展。特别是，由于使用 Apple Silicon Macs 而引起的新问题。

我们假设你至少具有 iOS 编程和软件工程的入门知识，并且可以在 Mac 上运用 Xcode 软件。

我们采取的方法是将关于问题的三种不同观点结合起来，让你能以全面、稳健地了解情况以及如何解决问题。

首先，我们将会为你提供一份如何使用 Apple 提供的出色自带工具的 `HOW-TO` 指南。

其次，我们提供一个针对防止和解决崩溃的软件工程概念的讨论。

最后，我们将提供一种正式的解决问题的方法，但该方法主要适用于崩溃分析。

编程文献全面分析了软件工程概念，而 Apple 通过 Guides 和 WWDC 视频介绍了其 crash dump 工具。

在软件工程界一般很少讨论如何去解决正式的问题，可能是因为解决问题被视作软件工程师的一种能力。它被认作是一门研究后增加”自身“能力的学科，这些能力似乎是为了从其他人群中区分出”有技术头脑“的人。

我们的目标并不是羞于重复那些我们在其他地方看到过或阅读过的知识，而是采取一种统一的方式来解释整个观点。 为什么 crash dump 分析如此困难的原因在于，它假定工程师具备大量的背景知识，以便腾出空间专注于特定工具或崩溃报告的具体细节。这会使得工程师出现认知障碍，本书就是要克服这种障碍。

作为本书的补充，还会有一个资源网站，用于结合书本内容一起使用，以便您可以自己设置并运行示例项目然后进行试验。本书最后的所有参考文献都收录在书目章节中。例如，你可以在其中找到资源的 URL。

支持该书的GitHub网站位于@icdabgithub

