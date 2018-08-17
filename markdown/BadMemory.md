# Bad Memory Crashes

In this chapter, we study bad memory crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_BAD_ACCESS (SIGSEGV)`\index{signal!SIGSEGV},
or `EXC_BAD_ACCESS (SIGBUS)`\index{signal!SIGBUS} in their Crash Report.

We look at a range of crashes obtained by searching the Internet.

## General principles

In operating systems, memory is managed by first collating contiguous memory into memory pages, and then collating pages into segments.  This allows meta data properties to be assigned to a segment that applies to all pages within the segment.  This allows the code of your program (the program _TEXT_) to be set to read only but executable.  This improves performance and security.

SIGBUS (bus error) means the memory address is correctly mapped into the address space of the process, but the process is not allowed to access the memory.

SIGSEGV (segment violation) means the memory address is not even mapped into the process address space.

## Segment Violation (SEGV) crashes

### fud crash

The `fud`\index{command!fud} program is an undocumented process within the private framework `MobileAccessoryUpdater`
From looking at the binary it appears to be a firmware update program.

Here we show the Crash Report of process `fud` on macOS, truncated for ease of demonstration:

```
Process:               fud [84641]
Path:                  /System/Library/PrivateFrameworks/MobileAccessoryUpdater.framework/Support/fud
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

Crashed Thread:        1  Dispatch queue: com.apple.fud.processing.queue

Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       EXC_I386_GPFLT
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Segmentation fault: 11
Termination Reason:    Namespace SIGNAL, Code 0xb
Terminating Process:   exc handler [0]

Thread 1 Crashed:: Dispatch queue: com.apple.fud.processing.queue
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
  rax: 0xe00007f80bd22039  rbx: 0x00007f80bd2202e0  rcx: 0x7fffffffffffffff
    rdx: 0x011d800101d66da1
  rdi: 0x00007f80bd21a250  rsi: 0x0000000102c01000  rbp: 0x0000700007e096c0
    rsp: 0x0000700007e09670
   r8: 0x0000000102c00010   r9: 0x0000000000000001  r10: 0x0000000102c01000
     r11: 0x00000f80b5300430
  r12: 0x00007f80ba70c670  r13: 0x00007fff673c8e80  r14: 0x00007f80bd201e00
    r15: 0x00007f80ba70cf30
  rip: 0x00007fff67fc6cbd  rfl: 0x0000000000010202  cr2: 0x00007fff9b2f11b8

Logical CPU:     3
Error Code:      0x00000004
Trap Number:     14
```

We clearly have a bad memory issue, since we have a `EXC_BAD_ACCESS (SIGSEGV)` exception.
The Trap Number we see is 14, which from https://github.com/apple/darwin-xnu is a Page Fault.

We can even look up the function that triggered the crash since `libdispatch`\index{command!libdispatch} is Apple Open Source. @libdispatchtar

We see:
```
#define dx_push(x, y, z) dx_vtable(x)->do_push(x, y, z)

DISPATCH_NOINLINE
static void
_dispatch_continuation_push(dispatch_queue_t dq, dispatch_continuation_t dc)
{
	dx_push(dq, dc, _dispatch_continuation_override_qos(dq, dc));
}
```

We are dereferencing memory from a data structure which has a bad memory location.

We can dissassemble the macOS binary, `/usr/lib/system/libdispatch.dylib` for the problem call site.

Here we use the Hopper tool to do the dissassembly:
```
__dispatch_continuation_push:
0000000000014c69         push       rbx
                                         ; CODE XREF=__dispatch_async_f2+112,
                                          j___dispatch_continuation_push
0000000000014c6a         mov        rax, qword [rdi]
0000000000014c6d         mov        r8, qword [rax+0x40]
0000000000014c71         mov        rax, qword [rsi+8]
0000000000014c75         mov        edx, eax
0000000000014c77         shr        edx, 0x8
0000000000014c7a         and        edx, 0x3fff
0000000000014c80         mov        ebx, dword [rdi+0x58]
0000000000014c83         movzx      ecx, bh
0000000000014c86         je         loc_14ca3
```

There seems to be a problem with the `rdi` register value, address `0x00007f80bd21a250`

We need to take a step back, and understand why we have a memory access problem.

Looking at the stack backtrace we can see that this program uses cross process communication (XPC) \index{XPC} to do its work.  It has a `handleXPCStreamEvent` function.

It is a common programming problem that when we receive a data payload, there is a problem unpacking the payload and interpreting the data.  We speculate that there is a bug in the deserialization code.  That would give us a potentially bad data structure which we dereference causing a crash.

If we were the author of the `fud` program we could update it to check the XPC data it gets and ensure best practices are followed for serialization/deserialization of data, such as the use interface definition layer generators.

EXC_BAD_ACCESS (SIGSEGV)

EXC_BAD_ACCESS
fud_crash_osx
kiosk_startup

SIGSEGV
leak_agent_crash
siri_crash

SIGBUS
xmbc_sigbus
jablotron_sigbus_align_ios
