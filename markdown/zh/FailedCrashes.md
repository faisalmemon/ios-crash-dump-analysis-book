# Failed的崩溃

在本章中，我们讨论 _Failed_\index{crash!failed} 崩溃。 就是那些没有以正确的崩溃报告返回给我们的崩溃。

有时，这是由于第三方崩溃报告框架的错误造成的。在本章中，我们将重点讨论失败的原生原因，并解释一些可能是导致这种现象发生的场景。

## 信号处理失败

在调试程序时，从概念上讲，它与崩溃时的状态类似。 这是因为我们要进入流程并检查其状态（或可能通过插入断点来更改程序）。 在iOS 13.5（在iOS 14.x中已修复）中，有一个小故障：如果应用程序告诉操作系统它希望进行调试，那么当系统希望由于崩溃而将其杀死时它发现它无法杀死该应用程序。 然后，整个系统卡死，需要重新设置。

如果我们有一个应用程序，则可能具有一些反逆向工程\index{software!anti-reverse engineering}或反调试功能\index{software!anti-debugging} （可能通过框架），我们可能最终会遇到这种情况，因为使一个应用程序假装它已经被调试是防止调试器连接的一种常用技术。

应用程序 `icdab_pt` 演示了该问题。 @icdabgithub.  @jitios.

```
#define SIZE 4096
#define SHM_NAME "map-jit-memory"

#define PT_TRACE_ME 0
int ptrace(int, pid_t, caddr_t, int); // private method

+ (void)crashThenStallCrashReporting:(BOOL)stall {
    int fd = open(SHM_NAME, O_RDWR | O_CREAT, 0666);
    int result = ftruncate(fd, SIZE);
    
    // we are not privileged so this will not be successful
    void *buf1 = mmap(0,
                      SIZE,
                      PROT_READ | PROT_WRITE,
                      MAP_JIT,
                      fd,
                      0);
    
    if (stall) {
        ptrace(PT_TRACE_ME, 0, NULL, 0);
    }
    
    // trigger crash by accessing a bad buffer
    strcpy(buf1, "Modified buffer");
    
    result = munmap(buf1, SIZE);
    result = shm_unlink(SHM_NAME);
}
```

上面的代码会使得在模拟器上崩溃报告与在目标硬件上造成的崩溃报告相同。
为了方便起见，我们将重点放在测试模拟器上，因为它易于重置，并且可以比较不同的 OS 版本。

当我们在 iOS 13.5\index{iOS!13.5} 上运行时，我们发现当传值为 `YES` 时系统挂起，但是当传值为 `NO` 时系统正常崩溃。在 iOS 14.x\index{iOS!14.x}，这两种情况下都会立即崩溃。

