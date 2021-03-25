## 符号化失败

崩溃报告程序 `ReportCrash`\index{command!ReportCrash} 本身可能会失败。 幸运的是，有一个故障保护机制，允许 `ReportCrash` 报告 `ReportCrash` 故障。

在我们的示例中，我们看到Symbolification \index{Symbolification} 阶段失败。

```
Incident Identifier: FD5D3125-4CD2-4A42-8C4C-86022EDED6B7
CrashReporter Key:   28184df1e2804fabaabb19f3a67639f76eb8f299
Hardware Model:      iPhone11,8
Process:             ReportCrash [2437]
Path:                /System/Library/CoreServices/ReportCrash
Identifier:          ReportCrash
Version:             ???
Code Type:           ARM-64 (Native)
Role:                Unspecified
Parent Process:      launchd [1]
Coalition:           com.apple.ReportCrash [570]
```

```
Exception Type:  EXC_BAD_ACCESS (SIGBUS)
Exception Subtype: UNKNOWN_0x32 at 0x000000017e012290
VM Region Info: 0x17e012290 is in 0x16f180000-0x17f180000;  bytes
 after start: 250159760  bytes before end: 18275695
      REGION TYPE                      START - END             [
 VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      Stack                  000000016f0f8000-000000016f180000 [ 
 544K] rw-/rwx SM=COW  thread 5
--->  mapped file            000000016f180000-000000017f180000
 [256.0M] r-x/r-x SM=COW  ...t_id=555409f3
      GAP OF 0x2cdbc000 BYTES
      unused shlib __TEXT    00000001abf3c000-00000001abf78000 [ 
 240K] r-x/r-x SM=COW  ... this process

Termination Signal: Bus error: 10
Termination Reason: Namespace SIGNAL, Code 0xa
Terminating Process: exc handler [2437]
Triggered by Thread:  1
```

```
0   CoreSymbolication                   0x00000001c63b9138
 0x1c6357000 + 401720
1   CoreSymbolication                   0x00000001c63b8e50
 0x1c6357000 + 400976
2   CoreSymbolication                   0x00000001c63b8e50
 0x1c6357000 + 400976
3   CoreSymbolication                   0x00000001c63b3884
 0x1c6357000 + 379012
4   libdyld.dylib                       0x00000001ac19c374
 0x1ac194000 + 33652
5   CoreSymbolication                   0x00000001c63b3620
 0x1c6357000 + 378400
6   CoreSymbolication                   0x00000001c63b83b0
 0x1c6357000 + 398256
7   CoreSymbolication                   0x00000001c63b9f88
 0x1c6357000 + 405384
8   Symbolication                       0x00000001ccac7598
 0x1cca9d000 + 173464
9   Symbolication                       0x00000001ccac8220
 0x1cca9d000 + 176672
10  ReportCrash                         0x0000000100f417e0
 0x100f3c000 + 22496
11  ReportCrash                         0x0000000100f3e6c8
 0x100f3c000 + 9928
12  ReportCrash                         0x0000000100f3fb70
 0x100f3c000 + 15216
13  ReportCrash                         0x0000000100f4a3e0
 0x100f3c000 + 58336
14  ReportCrash                         0x0000000100f4d6f0
 0x100f3c000 + 71408
15  ReportCrash                         0x0000000100f4d78c
 0x100f3c000 + 71564
16  libsystem_kernel.dylib              0x00000001ac16867c
 0x1ac165000 + 13948
17  ReportCrash                         0x0000000100f49a8c
 0x100f3c000 + 55948
18  libsystem_pthread.dylib             0x00000001ac0a9d50
 0x1ac0a8000 + 7504
19  libsystem_pthread.dylib             0x00000001ac0b1c88
 0x1ac0a8000 + 40072
```

```
Thread 1 crashed with ARM Thread State (64-bit):
    x0: 0x000000014df61b80   x1: 0x00000000000387bf   x2:
 0x0000000000000080   x3: 0x0000000000036df0
    x4: 0x0000000000000000   x5: 0x0000000000000000   x6:
 0x0000000000000080   x7: 0x000000017e012290
    x8: 0x00000001489f8000   x9: 0x0000000148a2edf0  x10:
 0x0000000000000080  x11: 0x000000017e014000
   x12: 0x0000000010000000  x13: 0x00000001b0000000  x14:
 0x0000000000000000  x15: 0x000000014f0852e0
   x16: 0x00000001a0000000  x17: 0xffffffffffffffff  x18:
 0x0000000000000000  x19: 0x000000014df61b80
   x20: 0x000000014df61b80  x21: 0x00000001aee92290  x22:
 0x0000000000000080  x23: 0x000000017e012290
   x24: 0x0000000000000001  x25: 0x00000000005cf000  x26:
 0x0000000138f54000  x27: 0x000000016ef48e68
   x28: 0x0000000000036df0   fp: 0x000000016ef486b0   lr:
 0x843bf481c63b8e50
    sp: 0x000000016ef486a0   pc: 0x00000001c63b9138 cpsr:
 0x20000000
   esr: 0x92000006 (Data Abort) byte read Translation fault

Binary Images:
0x100f3c000 - 0x100f53fff ReportCrash arm64e 
 <280941d3f7a93468982d7b115aa1f8a1>
 /System/Library/CoreServices/ReportCrash
.
.
0x1c6357000 - 0x1c63dcfff CoreSymbolication arm64e 
 <19219f5e25623142895af16a024bf332>
 /System/Library/PrivateFrameworks/CoreSymbolication.framework/Co
reSymbolication
.
.
0x1cca9d000 - 0x1ccb1bfff Symbolication arm64e 
 <f8f62c98901f34fb82c75a0d61044452>
 /System/Library/PrivateFrameworks/Symbolication.framework/Symbol
ication
```

我们可以在以下位置找到 `CoreSymbolification` \index{CoreSymbolification} 的二进制文件：
```
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.pla
tform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simru
ntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFramew
orks/CoreSymbolication.framework
```

从 `pc` 上，像以前一样，使用 Hopper 观察`CoreSymbolification`，通过将二进制文件重新定位到`0x1c6357000`并检查`0x00000001c63b9138`，我们发现崩溃是由于一个 C++ 例行程序操纵内存造成的：

```
  std::__1::__split_buffer<TRawRegion<Pointer64>,
 std::__1::allocator<TRawRegion<Pointer64>
 >&>::__split_buffer(&var_38, r1, r2);
```

来自Apple Open Source  C++ 库， `libcpp`。@libcpp

从历史上看，符号化一直是失败的根源，它是崩溃报告所依赖的主要子系统。
