### fud 崩溃

`fud` 程序是私有框架 `MobileAccessoryUpdater`中的一个未记录的进程。

在这里，我们显示了macOS上进程 `fud`的崩溃报告，为了便于演示，该报告已被截断：

```
Process:               fud [84641]
Path:                  /System/Library/PrivateFrameworks/
MobileAccessoryUpdater.framework/Support/fud
Identifier:            fud
Version:               106.50.4
Code Type:             X86-64 (Native)
Parent Process:        launchd [1]
Responsible:           fud [84641]
User ID:               0

Date/Time:             2018-06-12 08:34:15.054 +0100
OS Version:            Mac OS X 10.13.4 (17E199)
Report Version:        12
Anonymous UUID:        6C1D2091-02B7-47C4-5BF9-E99AD5C45875

Sleep/Wake UUID:       369D13CB-F0D3-414B-A177-38B1E560EEC7

Time Awake Since Boot: 240000 seconds
Time Since Wake:       47 seconds

System Integrity Protection: enabled

Crashed Thread:        1
  Dispatch queue: com.apple.fud.processing.queue

Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       EXC_I386_GPFLT
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Segmentation fault: 11
Termination Reason:    Namespace SIGNAL, Code 0xb
Terminating Process:   exc handler [0]

Thread 1 Crashed:: Dispatch queue:
 com.apple.fud.processing.queue
0   libdispatch.dylib             	0x00007fff67fc6cbd
 _dispatch_continuation_push + 4
1   fud                           	0x0000000101d3ce57
 __38-[FudController handleXPCStreamEvent:]_block_invoke + 593
2   libdispatch.dylib             	0x00007fff67fbb64a
 _dispatch_call_block_and_release + 12
3   libdispatch.dylib             	0x00007fff67fb3e08
 _dispatch_client_callout + 8
4   libdispatch.dylib             	0x00007fff67fc8377
 _dispatch_queue_serial_drain + 907
5   libdispatch.dylib             	0x00007fff67fbb1b6
 _dispatch_queue_invoke + 373
6   libdispatch.dylib             	0x00007fff67fc8f5d
 _dispatch_root_queue_drain_deferred_wlh + 332
7   libdispatch.dylib             	0x00007fff67fccd71
 _dispatch_workloop_worker_thread + 880
8   libsystem_pthread.dylib       	0x00007fff68304fd2
 _pthread_wqthread + 980
9   libsystem_pthread.dylib       	0x00007fff68304be9
 start_wqthread + 13

Thread 1 crashed with X86 Thread State (64-bit):
  rax: 0xe00007f80bd22039  rbx: 0x00007f80bd2202e0
    rcx: 0x7fffffffffffffff
    rdx: 0x011d800101d66da1
  rdi: 0x00007f80bd21a250  rsi: 0x0000000102c01000
    rbp: 0x0000700007e096c0
    rsp: 0x0000700007e09670
   r8: 0x0000000102c00010   r9: 0x0000000000000001
     r10: 0x0000000102c01000
     r11: 0x00000f80b5300430
  r12: 0x00007f80ba70c670  r13: 0x00007fff673c8e80
    r14: 0x00007f80bd201e00
    r15: 0x00007f80ba70cf30
  rip: 0x00007fff67fc6cbd  rfl: 0x0000000000010202
    cr2: 0x00007fff9b2f11b8

Logical CPU:     3
Error Code:      0x00000004
Trap Number:     14
```

我们显然有一个不好的内存问题，因为我们有一个`EXC_BAD_ACCESS (SIGSEGV)`（SIGSEGV）异常。
我们看到的错误代码是 14，在https://github.com/apple/darwin-xnu中属于缺页中断。

由于 `libdispatch`是 Apple 开源的，我们甚至可以查找触发崩溃的函数。@libdispatchtar

我们看到：
```
#define dx_push(x, y, z) dx_vtable(x)->do_push(x, y, z)

DISPATCH_NOINLINE
static void
_dispatch_continuation_push(dispatch_queue_t dq,
   dispatch_continuation_t dc)
{
	dx_push(dq, dc, _dispatch_continuation_override_qos(dq,
 dc));
}
```

我们正在从一个有错误内存位置的数据结构中解除内存引用。

我们可以反汇编问题调用站点的macOS二进制文件`/usr/lib/system/libdispatch.dylib`。

在这里，我们使用 Hopper 进行脱壳：
```
__dispatch_continuation_push:
0000000000014c69 push       rbx
                             ; CODE XREF=__dispatch_async_f2+112,
                             j___dispatch_continuation_push
0000000000014c6a mov        rax, qword [rdi]
0000000000014c6d mov        r8, qword [rax+0x40]
0000000000014c71 mov        rax, qword [rsi+8]
0000000000014c75 mov        edx, eax
0000000000014c77 shr        edx, 0x8
0000000000014c7a and        edx, 0x3fff
0000000000014c80 mov        ebx, dword [rdi+0x58]
0000000000014c83 movzx      ecx, bh
0000000000014c86 je         loc_14ca3
```

`rdi `寄存器值似乎有问题，地址为 `0x00007f80bd21a250 `

我们需要退一步，了解为什么我们有内存访问问题。

查看堆栈回溯，我们可以看到该程序使用跨进程通信（XPC）来完成其工作。 它有 `handleXPCStreamEvent` 函数。

这是一个常见的编程问题，当我们接收到一个数据有效负载时，就会出现解压缩有效负载和解释数据的问题。我们推测反序列化代码中有一个bug。这将给我们一个潜在的坏数据结构，我们取消引用会导致崩溃。

如果我们是`fud`程序的作者，我们可以对其进行更新以检查它获得的XPC数据，并确保遵循最佳实践进行数据的序列化/反序列化，例如使用接口定义层生成器。
