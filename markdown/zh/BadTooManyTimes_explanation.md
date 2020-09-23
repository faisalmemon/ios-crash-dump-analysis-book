## 唤醒崩溃异常

在某些情况下，iOS平台可以用 `Exception Code` 对唤醒崩溃进行分类。

例如，错误的网络代码导致了以下崩溃，为了便于演示而将其截断：

```
Exception Type:  00000020
Exception Codes: 0xbad22222
Highlighted Thread:  3

Application Specific Information:
SBUnsuspendLimit ooVoo[360] exceeded 15 wakes in 300 sec

Thread 3 name:  com.apple.NSURLConnectionLoader
Thread 3:
0   libsystem_kernel.dylib          0x307fc010
 mach_msg_trap + 20
1   libsystem_kernel.dylib          0x307fc206
 mach_msg + 50
2   CoreFoundation                  0x3569b41c
__CFRunLoopServiceMachPort + 120
3   CoreFoundation                  0x3569a154
 __CFRunLoopRun + 876
4   CoreFoundation                  0x3561d4d6
 CFRunLoopRunSpecific + 294
5   CoreFoundation                  0x3561d39e
 CFRunLoopRunInMode + 98
6   Foundation                      0x3167abc2
+[NSURLConnection(Loader) _resourceLoadLoop:] + 302
7   Foundation                      0x3167aa8a
 -[NSThread main] + 66
8   Foundation                      0x3170e59a
 __NSThread__main__ + 1042
9   libsystem_c.dylib               0x30b68c16
 _pthread_start + 314
10  libsystem_c.dylib               0x30b68ad0
 thread_start + 0
```

二进制代码`0xbad22222` 读作 “Bad too many”，将“too”用作“2”的双关语。

在操作系统中，管理内存的方法是首先将连续的内存排序为内存页，然后将页面排序为段。 这允许将元数据属性分配给应用于该段内的所有页面的段。这允许我们的程序代码(程序 _TEXT _ )被设置为只读但可执行。提高了性能和安全性。

此类崩溃可能是由于未正确使用网络 API. @impropersockets
