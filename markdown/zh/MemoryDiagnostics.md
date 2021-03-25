# 内存诊断

在本章中，我们着眼于基于不同的诊断选项来解决内存问题。

## 内存分配基础

iOS 平台在堆栈上或堆上为我们的应用分配内存。

每当我们在函数范围内创建局部变量时，就会在堆栈上分配内存。每当我们调用 `malloc` 方法（或其变体）时，都会从堆中分配内存。

堆上分配的最小的内存大小为 16 字节（我们不探究具体实现细节）。这意味着当我们不小心覆盖已分配的最小内存时，少量的内存冲突可能无法被检测到。

分配内存后，会将其放入虚拟内存区域。存在用于分配大致相同内存大小的虚拟内存区域。例如，我们有 `MALLOC_LARGE`，`MALLOC_SMALL` 和 `MALLOC_TINY` 三种内存区域。这种策略主要是为了减少内存碎片的数量。此外，还有一个用于存储图像字节的区域，即 `CGvimage`区域。这将允许内存优化系统性能。

关于发现内存分配错误的困难是，由于相邻内存可能用于不同目的，因此这些症状可能会造成混淆，所以系统的一个逻辑区域可能会干扰系统的不相关区域。 此外，由于可能存在的延迟（或等待时间），因此发现问题的时间要比引入问题的时间晚得多。

## Address Sanitizer

> 具体详见谷歌开源工具 https://github.com/google/sanitizers

一个非常强大的工具可以协助进行内存诊断，称为 Address Sanitizer。(称为 @asanchecker)

它需要我们为 Address Sanitizer 重新配置我们的 Scheme 设置来重编译代码：

![](screenshots/diagnostic_santizer_setting.png)

Address Sanitizer 会执行内存计数（成为影子内存）。他知道哪些内存位置被 “poisoned”。即，尚未分配（或已分配，然后释放）的内存。

@wwdc2015_413

Address Sanitizer 将直接利用编译器，因此在编译代码时，对内存的任何访问都需要对影子内存进行检查，以查看内存位置是否被释放。 如果发现这种现象，则会生成错误报告。

这是一个非常强大的工具，因为它解决了两个最重要的内存错误类别：

1. 堆内存访问溢出（Heap Buffer Overflow）
2. 堆内存释放后使用（Heap Use After Free）

_堆内存访问溢出（Heap Buffer Overflow）_ 问题是指我们将访问比已分配的内存更多的内存区域。
_堆内存释放后使用（Heap Use After Free）_ 问题是指我们将访问已经释放的内存区域。

Address Sanitizer 可以进一步其他类型的内存问题，不过很少遇到：堆栈缓冲区溢出，全局变量溢出，C ++容器溢出以及返回错误后使用。 

这种便利的代价是我们的程序运行将会慢 2~5 倍。但在我们的持续集成系统中消除一些问题是值得的。

## 内存冲突示例

思考在示例 `icdab_edge` 程序中的以下代码。 @icdabgithub

```
- (void)overshootAllocated
{
    uint8_t *memory = malloc(16);
    for (int i = 0; i < 16 + 1; i++) {
        *(memory + i) = 0xff;
    }
}
```

此代码分配最小的内存量，即16个字节。然后它写入17个连续的内存位置。 我们得到一个堆溢出错误。

这个问题本身并不会使我们的应用立即崩溃。但如果旋转设备，则会触发潜在故障，并导致崩溃。通过启用 Address Sanitizer，应用程序立即崩溃。这有一个巨大的好处。 否则，我们可能在调试屏幕旋转相关代码上浪费了很多时间。

Address Sanitizer 的错误报告很详尽。 为了便于演示，我们仅显示报告的选定部分。

错误报告以以下内容开头：
```
==21803==ERROR: AddressSanitizer:
 heap-buffer-overflow on address
 0x60200003a5e0 at
  pc 0x00010394461b bp 0x7ffeec2b8f00 sp 0x7ffeec2b8ef8
WRITE of size 1 at 0x60200003a5e0 thread T0
#0 0x10394461a in -[Crash overshootAllocated] Crash.m:48
```

这就足够我们切换到代码并开始理解问题。

并进一步提供了详细信息，显示我们的访问超出所分配的 16 字节的内存区域。
```
0x60200003a5e0 is located 0 bytes to the right of
 16-byte region [0x60200003a5d0,0x60200003a5e0)
allocated by thread T0 here:
#0 0x103bcdaa3 in wrap_malloc
(libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
#1 0x1039445ae in -[Crash overshootAllocated] Crash.m:46
```

请注意使用 “半开” 数字范围数字表示法，其中`[`包括较低范围的索引，而 `)` 则排除较高范围的索引。 因此，我们对`0x60200003a5e0`的访问超出了分配的范围 `[0x60200003a5d0,0x60200003a5e0）`。

我们还得到了围绕该问题的内存的“映射”，为了便于演示，将 `0x1c0400007460` 截断为 ` .... 7460`：
```
SUMMARY: AddressSanitizer: heap-buffer-overflow Crash.m:48 in
 -[Crash overshootAllocated]
Shadow bytes around the buggy address:
....7460: fa fa 00 00 fa fa fd fd fa fa fd fa fa fa fd fa
....7470: fa fa 00 00 fa fa fd fa fa fa 00 00 fa fa fd fd
....7480: fa fa fd fa fa fa fd fd fa fa fd fa fa fa fd fa
....7490: fa fa fd fd fa fa fd fd fa fa fd fa fa fa fd fa
....74a0: fa fa 00 fa fa fa 00 00 fa fa fd fd fa fa 00 00
=>....74b0: fa fa 00 00 fa fa 00 00 fa fa 00 00[fa]fa fa fa
....74c0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
....74d0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
....74e0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
....74f0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
....7500: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend
(one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
```

从`[fa]` 中我们看到我们命中了 “redzone”（ `poisoned` 内存）的第一个字节。

## （堆内存）释放后使用示例

思考在示例 `icdab_edge` 程序中的以下代码。@icdabgithub

```
- (void)useAfterFree
{
    uint8_t *memory = malloc(16);         // line 54
    for (int i = 0; i < 16; i++) {
        *(memory + i) = 0xff;
    }
    free(memory);                         // line 58
    for (int i = 0; i < 16; i++) {
        *(memory + i) = 0xee;             // line 60
    }
}
```

该代码分配最小的内存空间（16个字节），然后写入该内存，将其释放，然后再次尝试写入同一内存。

Address Sanitizer 报告报告我们访问已经释放的内存的位置：
```
35711==ERROR: AddressSanitizer:
 heap-use-after-free on address
0x602000037270 at
 pc 0x000106d34381 bp 0x7ffee8ec9ef0 sp 0x7ffee8ec9ee8
WRITE of size 1 at 0x602000037270 thread T0
    #0 0x106d34380 in -[Crash useAfterFree] Crash.m:60
```

它告诉我们释放的位置：
```
0x602000037270 is located 0 bytes inside of 16-byte region
 [0x602000037270,0x602000037280)
freed by thread T0 here:
    #0 0x106fbdc6d in wrap_free
    (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54c6d)
    #1 0x106d34318 in -[Crash useAfterFree] Crash.m:58
```

它告诉我们内存最初分配的位置：
```
previously allocated by thread T0 here:
    #0 0x106fbdaa3 in wrap_malloc
    (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
    #1 0x106d3428e in -[Crash useAfterFree] Crash.m:54
    SUMMARY: AddressSanitizer: heap-use-after-free Crash.m:60 in
     -[Crash useAfterFree]
```

最后，它向我们展示了一个错误地址周围的内存分布图片，为了便于演示，将“ 0x1c0400006df0”截断为“ .... 6df0”：
```
    Shadow bytes around the buggy address:
  ....6df0: fa fa fd fd fa fa 00 00 fa fa fd fd fa fa fd fa
  ....6e00: fa fa fd fa fa fa 00 00 fa fa fd fa fa fa 00 00
  ....6e10: fa fa fd fd fa fa fd fa fa fa fd fd fa fa fd fa
  ....6e20: fa fa fd fa fa fa fd fd fa fa fd fd fa fa fd fa
  ....6e30: fa fa fd fa fa fa 00 fa fa fa 00 00 fa fa fd fd
=>....6e40: fa fa 00 00 fa fa 00 00 fa fa 00 00 fa fa[fd]fd
  ....6e50: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  ....6e60: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  ....6e70: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  ....6e80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  ....6e90: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    Shadow byte legend
    (one shadow byte represents 8 application bytes):
      Addressable:           00
      Partially addressable: 01 02 03 04 05 06 07
      Heap left redzone:       fa
      Freed heap region:       fd
```

我们看到条目`[fd]`表示已释放对内存的进行写入操作。

## 内存管理工具

有一系列补充Address Sanitizer的工具。在关掉 Address Sanitizer 之后在使用他们。他们会发现 Address Sanitizer 可能会错过的某些失败原因。

与 Address Sanitizer 相比，这些内存管理工具不需要重新编译项目。

### Guard Malloc 工具

该工具的一个主要缺点是仅适用于模拟器。每块内存都被分配在他们自己的内存页中，前后都有保护。该工具在很大程度上已被 Address Sanitizer 取代。

### Malloc Scribble

Malloc Scribble 的目的是通过将 `malloc` 的或 ` free` 的内存标记成固定的已知值来使内存错误的症状变得可预测。已分配的内存标记为`0xAA`而已释放的内存标记为 `0x55`。 它不会影响在堆栈上分配内存的行为。 它与Address Sanitizer不兼容。

如果我们有一个应用程序每次在运行时都以不同的方式崩溃，那么 Malloc Scribble 是一个不错的选择。 它将有助于使崩溃可预测和可重复。

思考在示例 `icdab_edge` 程序中的以下代码。@icdabgithub

```
- (void)uninitializedMemory
{
    uint8_t *source = malloc(16);
    uint8_t target[16] = {0};
    for (int i = 0; i < 16; i++) {
       target[i] = *(source + i);
    }
}
```

首先，为 `source` 提供新分配的内存。由于此内存尚未初始化，因此在 Scheme 设置中设置了Malloc Scribble（以及 Address Sanitizer 重置）后，会将其设置为0xAA。

然后，设置 `target`。它是堆栈上的缓冲区（不是堆内存）。使用代码 `= {0}`，我们将应用设置的缓冲区的所有内存位置设置为 `0`。 否则，它将是随机存储器值。

然后我们进入一个循环。 通过在调试器中进行断点（例如在第二次迭代中），我们可以打印出内存内容并看到以下内容：

![](screenshots/scribble.png)

我们看到 `target`缓冲区与前两个索引位置（ `0xAA`）相距零。我们看到 `source`内存始终为 `0xAA`。

如果我们没有设置Malloc Scribble，则目标缓冲区将被填充随机值。在复杂的程序中，此类数据可以被输入到影响程序行为的其他子系统中。

### Zombie Objects（僵尸对象）

僵尸对象的目的是在Objective-C 环境中的中检测 `NSObject`对象释放后使用的错误。特别是如果我们有一个使用手动引用计数的遗留代码库，则很容易过度释放对象。这意味着，通过指针传递消息可能会产生不可预测的效果。

此设置只能在调试构建时进行，因为代码将不再释放对象。它的性能配置文件相当于泄漏所有应该被释放的对象。

开启配置将使释放对象成为`NSZombie`对象。 发送给`NSZombie`对象的任何消息都会导致立即崩溃。 因此，每当有消息发送给已经释放的的对象时，我们都可以确保发生崩溃。

思考在示例 `icdab_edge` 程序中的以下代码。@icdabgithub

```
- (void)overReleasedObject
{
    id vc = [[UIViewController alloc] init];
    // Build Phases -> Compile Sources
    // -> Crash.m has Compiler Flags setting
    // -fno-objc-arc to allow the following line to be called
    [vc release];
    NSLog(@"%@", [vc description]);
}
```

当调用上述代码时，会发生崩溃，并记录以下内容：

```
2018-09-12 12:09:10.236058+0100 icdab_edge[92796:13650378]
 *** -[UIViewController description]: message sent to deallocated
  instance 0x7fba1ff071c0
```

查看调试器，我们看到：

![](screenshots/zombie.png)

注意对象实例`vc`的类型是`_NSZombie_UIViewController *`。

该类型将是过已释放对象的原始类型，但是增加前缀了 `_NSZombie_`。
这是最有帮助的，在调试器中研究程序状态时，我们应该注意这一点。

### Malloc 堆栈

有时需要了解我们应用程序过去的动态行为，以解决应用程序崩溃的原因。 例如，我们可能发生了内存泄露，然后由于使用过多内存而被系统终止。 我们可能有一个数据结构，想知道代码的哪一部分负责分配它。

Malloc Stack 选项的目的是为提供我们所需的历史数据。苹果通过提供补充的可视化工具来增强了内存分析。 Malloc Stack 具有一个子选项“所有分配和释放的历史记录”或“仅实时分配”。

我们建议使用“所有分配”选项，除非使用的开销过多。 那可能是由于有一个应用程序大量使用了内存分配。 “仅实时分配”选项足以捕获内存泄漏，并且开销很低，因此它是用户界面中的默认选项。

下面是执行步骤：

1. 在 `Diagnostics` 设置选项卡中设置`Malloc Stack`选项。
2. 启动应用.
3. 按下 `Debug Memgraph` 按钮
4. 基于命令行工具进行分析，_File -> Export Memory Graph..._

Xcode 内的 Memgraph 可视化工具功能全面，但令人生畏。
有一个有用的WWDC视频来介绍基本知识 @wwdc2018_416

通常有太多的底层细节需要检查。使用图形工具的最佳方式是当我们对应用程序错误使用内存有一些假设时。

#### Malloc 堆栈存储器示例：检测循环引用

一个简单有效的成果是看看我们是否有内存泄漏。这些内存位置无法访问，不能释放。

我们使用tvOS示例应用程序 `icdab_cycle` 来展示 Memgraph 如何发现循环引用。 @icdabgithub

通过在 Scheme 设置中设置Malloc Stack ，我们启动应用程序，然后按Memgraph按钮，如下所示：

![](screenshots/memgraphbutton.png)

通过按下感叹号过滤器按钮，我们可以过滤为仅显示泄漏：

![](screenshots/retaincycle.png)

如果已经完成 _File-> Export Memory Graph ..._，将内存图导出到 `icdab_cycle.memgraph`，我们可以使用以下命令从Mac Terminal应用程序中查看等效信息：

```
leaks icdab_cycle.memgraph

Process:         icdab_cycle [15295]
Path:            /Users/faisalm/Library/Developer/
CoreSimulator/Devices/
1616CA04-D1D0-4DF6-BE8E-F63541EC1EED/
data/Containers/Bundle/Application/
E44B9EFD-258B-4D0E-8637-CF374638D5FF/
icdab_cycle.app/icdab_cycle
Load Address:    0x106eb7000
Identifier:      icdab_cycle
Version:         ???
Code Type:       X86-64
Parent Process:  debugserver [15296]

Date/Time:       2018-09-14 16:38:23.008 +0100
Launch Time:     2018-09-14 16:38:12.398 +0100
OS Version:      Apple TVOS 12.0 (16J364)
Report Version:  7
Analysis Tool:   /Users/faisalm/Downloads/
Xcode.app/Contents/Developer/Platforms/
AppleTVOS.platform/Developer/Library/CoreSimulator/
Profiles/Runtimes/
tvOS.simruntime/Contents/
Resources/RuntimeRoot/Developer/Library/
PrivateFrameworks/DVTInstrumentsFoundation.framework/
LeakAgent
Analysis Tool Version:  iOS Simulator 12.0 (16J364)

Physical footprint:         38.9M
Physical footprint (peak):  39.0M
----

leaks Report Version: 3.0
Process 15295: 30252 nodes malloced for 5385 KB
Process 15295: 3 leaks for 144 total leaked bytes.

Leak: 0x600000d506c0  size=64  zone:
DefaultMallocZone_0x11da72000
   Song  Swift  icdab_cycle
	Call stack: [thread 0x10a974380]: |
   0x10a5f678d (libdyld.dylib) start |
    0x106eba614 (icdab_cycle) main
     AppDelegate.swift:12 ....
```

导致内存泄漏的代码是：
```
var mediaLibrary: Album?

func createRetainCycleLeak() {
    let salsa = Album()
    let carnaval = Song(album: salsa,
     artist: "Salsa Latin 100%",
     title: "La Vida Es un Carnaval")
    salsa.songs.append(carnaval)
}

func buildMediaLibrary() {
    let kylie = Album()
    let secret = Song(album: kylie,
     artist: "Kylie Minogue",
     title: "It's No Secret")
    kylie.songs.append(secret)
    mediaLibrary = kylie
    createRetainCycleLeak()
}
```

这个问题是因为 `createRetainCycleLeak()` 方法中的` Song` 的实例对象 `carnaval` 强引用了 `Album`的实例对象`salsa`，而 `salsa` 又强引用了 ` Song` 的实例对象 `carnaval` ，而当我们从这个方法返回时，并没有从其他对象引用任何一个对象。这两个对象与对象图的其他部分断开连接，并且由于它们的相互强引用(称为循环引用)，所以它们不能被自动释放。一个非常类似的对象间的关系如  `Album` 的实例对象`kylie`并没有引起内存泄露，因为他是被顶级对象 `mediaLibrary` 所引用的。

### 动态链接器API的用法

有时程序是动态适应的或可扩展的。对于这样的程序，动态链接器 AP I 将以编程方式加载额外的代码模块。当应用程序的配置或部署出错时，可能会导致崩溃。

要调试这些问题，需要设置  `Dynamic Linker API Usage ` 。但这可能会产生很多信息，因此可能会在启动时间有限、速度较慢的平台上造成问题，比如第一代Apple Watch

GitHub 上提供了使用动态链接器的示例应用程序。 @dynamicloadingeg

启用后的输出为：

```
_dyld_get_image_slide(0x105545000)
_dyld_register_func_for_add_image(0x10a21264c)
_dyld_get_image_slide(0x105545000)
_dyld_get_image_slide(0x105545000)
_dyld_register_func_for_add_image(0x10a5caf39)
dyld_image_path_containing_address(0x1055d2000)
.
.
.

dlopen(DynamicFramework2.framework/DynamicFramework2)
 ==> 0x60c0001460f0
.
.
.
```

这会生成大量日志记录。对此最好先搜索 `dlopen` 命令，然后查看 `dlopen` 系列中的其他函数被调用了

### 动态库加载

在初始化阶段，有时会出现应用程序崩溃，此时动态加载器正在加载应用程序二进制文件及其依赖框架。 如果我们确信它不是使用动态链接器API的自定义代码，而是将框架组装到我们关心的已加载二进制文件中，那么选择 `Dynamic Library Loads` 是合适的。 与启用 `Dynamic Linker API Usage`  相比，我们得到的日志要短得多。

启动后，我们将获得加载的二进制文件列表：

```
dyld: loaded: /Users/faisalm/Library/Developer/
CoreSimulator/Devices/
99DB717F-9161-461A-B11F-210C389ABA12/
data/Containers/Bundle/Application/
D916AC0F-6434-46A3-B18E-5EC65D194454/
icdab_edge.app/icdab_edge

dyld: loaded: /Applications/Xcode.app/Contents/Developer/
Platforms/iPhoneOS.platform/Contents/Resources/RuntimeRoot/
usr/lib/libBacktraceRecording.dylib
.
.
.
```
