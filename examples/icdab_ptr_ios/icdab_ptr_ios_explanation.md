## `icdab_ptr` PAC crash

On an iPhone 11\index{trademark!iPhone 11}, which has an A13 Bionic chip\index{CPU!A13 Bionic}, we see the following crash when running the `icdab_ptr` program.  @icdabgithub

```
Incident Identifier: DA9FE0C7-6127-4660-A214-5DF5D432DBD9
CrashReporter Key:   d3e622273dd1296e8599964c99f70e07d25c8ddc
Hardware Model:      iPhone12,1
Process:             icdab_ptr [2125]
Path:               
 /private/var/containers/Bundle/Application/32E9356D-AF19-4F30-BB
87-E4C056468063/icdab_ptr.app/icdab_ptr
Identifier:          perivalebluebell.com.icdab-ptr
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           perivalebluebell.com.icdab-ptr [1288]

Date/Time:           2020-10-14 23:09:20.9645 +0100
Launch Time:         2020-10-14 23:09:20.6958 +0100
OS Version:          iPhone OS 14.2 (18B5061e)
Release Type:        Beta
Baseband Version:    2.02.00
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x2000000100ae9df8 ->
 0x0000000100ae9df8 (possible pointer authentication failure)
VM Region Info: 0x100ae9df8 is in 0x100ae4000-0x100aec000;  bytes
 after start: 24056  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE]
 PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  __TEXT                   100ae4000-100aec000 [   32K]
 r-x/r-x SM=COW  ...app/icdab_ptr
      __DATA_CONST             100aec000-100af0000 [   16K]
 r--/rw- SM=COW  ...app/icdab_ptr

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [2125]
Triggered by Thread:  0

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   icdab_ptr                           0x0000000100ae9df8
 nextInterestingJumpToFunc + 24056 (ViewController.m:26)
1   icdab_ptr                           0x0000000100ae9cf0
 -[ViewController viewDidLoad] + 23792 (ViewController.m:35)
2   UIKitCore                           0x00000001aca4cda0
 -[UIViewController
 _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 108
3   UIKitCore                           0x00000001aca515fc
 -[UIViewController loadViewIfRequired] + 956
4   UIKitCore                           0x00000001aca519c0
 -[UIViewController view] + 32
.
.

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000103809718   x1: 0x0000000103809718   x2:
 0x0000000000000000   x3: 0x00000000000036c8
    x4: 0x00000000000062dc   x5: 0x000000016f319b20   x6:
 0x0000000000000031   x7: 0x0000000000000700
    x8: 0x045d340100ae9df8   x9: 0x786bdebd0a110081  x10:
 0x0000000103809718  x11: 0x00000000000007fd
   x12: 0x0000000000000001  x13: 0x00000000d14208c1  x14:
 0x00000000d1621000  x15: 0x0000000000000042
   x16: 0xe16d9e01bf21b57c  x17: 0x00000002057e0758  x18:
 0x0000000000000000  x19: 0x0000000102109620
   x20: 0x0000000000000000  x21: 0x0000000209717000  x22:
 0x00000001f615ffcb  x23: 0x0000000000000001
   x24: 0x0000000000000001  x25: 0x00000001ffac7000  x26:
 0x0000000282c599a0  x27: 0x00000002057a44a8
   x28: 0x00000001f5cfa024   fp: 0x000000016f319dd0   lr:
 0x0000000100ae9cf0
    sp: 0x000000016f319da0   pc: 0x0000000100ae9df8 cpsr:
 0x60000000
   esr: 0x82000004 (Instruction Abort) Translation fault

Binary Images:
0x100ae4000 - 0x100aebfff icdab_ptr arm64e 
 <83e44566e30039258fd14db647344501>
 /var/containers/Bundle/Application/32E9356D-AF19-4F30-BB87-E4C05
6468063/icdab_ptr.app/icdab_ptr
```

Firstly, we notice that the point at which we crashed was `ViewController.m:26` from
```
0   icdab_ptr                           0x0000000100ae9df8
 nextInterestingJumpToFunc + 24056 (ViewController.m:26)
```

Our source code has:
```
24 // this function's address is where we will be jumping to
25 static void nextInterestingJumpToFunc(void) {
26     NSLog(@"Simple nextInterestingJumpToFunc\n");
27 }
```

The purpose of the program was to calculate the address of the `nextInterestingJumpToFunc` function by means of pointer arithmetic and then jump to it.  It managed to do so but then crashed.  We know from the previous section that this was because we deliberately used the function address PAC borrowed from the `interestingJumpToFunc` function.

The crash reporting system demangles the pointer understanding what the effective pointer address is given the faulty pointer.  We have:
```
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x2000000100ae9df8 ->
 0x0000000100ae9df8 (possible pointer authentication failure)
VM Region Info: 0x100ae9df8 is in 0x100ae4000-0x100aec000;  bytes
 after start: 24056  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE]
 PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  __TEXT                   100ae4000-100aec000 [   32K]
 r-x/r-x SM=COW  ...app/icdab_ptr
      __DATA_CONST             100aec000-100af0000 [   16K]
 r--/rw- SM=COW  ...app/icdab_ptr
```

Our pointer, `0x2000000100ae9df8` points to the text region of the program at `0x0000000100ae9df8` but the upper 24 bits of the pointer are incorrect, hence the message `(possible pointer authentication failure)` and this results in the `SIGSEGV`.  Notice the PAC is a special value `0x200000` which presumably the value representing `invalid PAC`.

From the previous section, we know that the code which checks the PAC in our program is:
```
blraaz  x8
```

Our `x8` register was `0x045d340100ae9df8` so presumably the faulty PAC was `0x045d34`.

## Pointer Authentication Debugging Tips

In this section we point out some differences when running the debugger on a Architecture `armv8e` target.  We also show how to match a crash report to a debugging session.

When we print out pointers, we get the pointer with the PAC value stripped out.  For example, for a pointer `0x36f93010201ddf8`, our `result` variable, we would get:
```
(lldb) po result
(actual=0x000000010201ddf8 icdab_ptr`nextInterestingJumpToFunc at ViewController.m:25)
```

This value is from the execution that produced the following output
```
ptr addresses as uintptr_t are 0x36f93010201ddd8 0xc7777b010201ddf8
delta is 0xc407e80000000020 clean_delta is 0x20
ptrFn result is 0x36f93010201ddf8
```

Whilst we are attached via the debugger, we don't see the crash dump report.  However, if we detach our debugger:
```
(lldb) detach
```
the system will continue on, and perform a crash, and then generate a report.

```
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x200000010201ddf8 -> 0x000000010201ddf8 (possible pointer authentication failure)
VM Region Info: 0x10201ddf8 is in 0x10201c000-0x102020000;  bytes after start: 7672  bytes before end: 8711
      REGION TYPE                 START - END      [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      __TEXT                   102018000-10201c000 [   16K] r-x/r-x SM=COW  ...app/icdab_ptr
--->  __TEXT                   10201c000-102020000 [   16K] r-x/rwx SM=COW  ...app/icdab_ptr
      __DATA_CONST             102020000-102024000 [   16K] r--/rw- SM=COW  ...app/icdab_ptr

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [2477]
Triggered by Thread:  0

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   icdab_ptr                     	0x000000010201ddf8 nextInterestingJumpToFunc + 24056 (ViewController.m:25)
1   icdab_ptr                     	0x000000010201dcf0 -[ViewController viewDidLoad] + 23792 (ViewController.m:34)
2   UIKitCore                     	0x00000001aca4cda0 -[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 108
3   UIKitCore                     	0x00000001aca515fc -[UIViewController loadViewIfRequired] + 956
4   UIKitCore                     	0x00000001aca519c0 -[UIViewController view] + 32
.
.

Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x000000010c80a738   x1: 0x000000010c80a738   x2: 0x000000000000000d   x3: 0x0000000000000000
    x4: 0x000000016dde59b8   x5: 0x0000000000000040   x6: 0x0000000000000033   x7: 0x0000000000000800
    x8: 0x036f93010201ddf8   x9: 0xb179df14ab2900d1  x10: 0x000000010c80a738  x11: 0x00000000000007fd
   x12: 0x0000000000000001  x13: 0x00000000b3e33897  x14: 0x00000000b4034000  x15: 0x0000000000000068
   x16: 0x582bcd01bf21b57c  x17: 0x00000002057e0758  x18: 0x0000000000000000  x19: 0x000000010be0d760
   x20: 0x0000000000000000  x21: 0x0000000209717000  x22: 0x00000001f615ffcb  x23: 0x0000000000000001
   x24: 0x0000000000000001  x25: 0x00000001ffac7000  x26: 0x0000000280436140  x27: 0x00000002057a44a8
   x28: 0x00000001f5cfa024   fp: 0x000000016dde5b60   lr: 0x000000010201dcf0
    sp: 0x000000016dde5b30   pc: 0x000000010201ddf8 cpsr: 0x60000000
   esr: 0x82000004 (Instruction Abort) Translation fault
```

This approach is handy because then we can directly correlate the crash dump report to our analysis in the debugger.  Notice that the `x8` register is exactly the `result` value we explored earlier.
