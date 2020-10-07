# Apple Silicon

In this chapter we look at crashes on Apple Silicon Macs, and crashes arising from the use of the Rosetta\index{trademark!Rosetta} translation system.  Furthermore we look at new types of crashes that are possible from multi-architecture code that supports both ARM\index{CPU!ARM} and Intel\index{CPU!Intel} CPUs.

## What is Rosetta?

Rosetta\index{trademark!Rosetta} is an instruction translator present on Apple Silicon Macs.  When presented an Application with Intel instructions as part of the binary, it can translate those to ARM instructions, and then run them.  Think of it as a Ahead Of Time (AOT)\index{JIT} compiler. @rosetta  The origins of the technology come from an earlier era when Macs were transitioning from the PowerPC chip to Intel chips.  Apple was assisted by technology from Transitive Technologies Ltd. to produce Rosetta version 1.  @transitive @rosetta_news  In Rosetta version 2, we have a system allowing on a per process basis, Intel instructions to be pre-translated to ARM instructions, and then run at native speed.

### Rosetta binaries

On Apple Silicon Macs, the Rosetta software resides in 
```
/Library/Apple/usr/libexec/oah
```

Within this directory is the runtime engine, `runtime_t8027`, the translator `oahd-helper`, a command line tool `translate_tool`, and other artefacts.   Its operation is largely transparent to end users apart from a small startup delay or slightly lower performance.  From a crash dump perspective, we see its presence in terms of memory footprint, exception helper and runtime helpers.

### Rosetta limitations

Rosetta is a powerful system but it has some limitations.  These concern mainly high performance multimedia applications and Operating System virtualization solutions.

Excluded from Rosetta are:

- Kernel extensions
- `x86_64` vitualization support instructions
- vector instructions, such as AVX, AVX2, and AVX512\index{Vector instruction!AVX}

Interestingly, Rosetta does support Just-In-Time compilation apps.  These applications are special because they generate their own code and then execute them.  Most applications have fixed read-only code (the program text) which is then executed, and only have their data as mutable (but not executable).  Presumbly this was because JIT is a common technology for the JavaScript runtime.

Apple advise checking for optional hardware features before calling code that utilises such functionality.  To determine what optional hardware support is present on our platform, we can run `sysctl hw | grep optional`.  In code, we have the `sysctlbyname` function to achieve the same thing.

### Forcing Rosetta execution

If we accept the standard build architecture options for our program, which are `Build Active Architecture Only` set to `Yes` for `Debug` builds, and `No` for `Release` builds, then when running under the Debugger, we shall only see Native binaries.  That is because in the Debug case, we do not want to waste time building an architecture not relevant to the machine we are testing on.

If we do an archive build, `Product > Archive`, and then select `Distribute App` we end up with a Release Build.  With default settings, this will be a Fat Binary\index{file!Fat} File offering `x86` and `arm64` within the multi-architecture binary.

Once we have a Fat binary we can use `Finder` app, right-click `File info` to set Rosetta to perform translation of our binary so that on an Apple Silicon Mac, the Intel instructions are translated from the Fat binary.

![](screenshots/univeral_application_icdab_rosetta_thread.png)

## Code Translation Example
Our working example in this chapter is the `icdab_thread` program; it is available on the web.  @icdabgithub  This program attempts to call `thread_set_state` and then deliberately crashes 60 seconds later using `abort`\index{command!abort}.  It is not able to actually do this because of recent security enhancements in macOS to prevent the use of such an API; it was an attack vector for malware.  Nevertheless, this program is interesting because of a closely related artefact upon crashing, the number of times `task_for_pid`\index{command!task for pid} had been called.

We have adapted the command line executable program `icdab_thread` into an application which merely calls the same underlying code.  The application is called `icdab_rosetta_thread`.  The reason for this is because UNIX command line executables are not eligible for running Translated but Applications are. 

### `icdab_rosetta_thread` Lipo Information

The following command shows our application supports both ARM and Intel instructions.
```
# lipo -archs
 icdab_rosetta_thread.app/Contents/MacOS/icdab_rosetta_thread
x86_64 arm64
```

## Translated Crashes

If we run the `icdab_rosetta_thread` application, clicking on `Start Threads Test`, after one minute we have a crash.  Comparing the crash dump between Native and Translated cases, we see differences in the Crash Report.

### Code Type

```
Code Type:             ARM-64 (Native)
```

when running natively, becomes under translation,

```
Code Type:             X86-64 (Translated)
```

### Thread Dumps

The crashed thread (and others) look similar, apart from the pointers are based much higher in the Translated case.

For the native crash we have:
```
Thread 1 Crashed:: Dispatch queue: com.apple.root.default-qos
0   libsystem_kernel.dylib              0x00000001de3015d8
 __pthread_kill + 8
1   libsystem_pthread.dylib             0x00000001de3accbc
 pthread_kill + 292
2   libsystem_c.dylib                   0x00000001de274904 abort
 + 104
3   perivalebluebell.com.icdab-rosetta-thread  
 0x00000001002cd478 start_threads + 244
4   perivalebluebell.com.icdab-rosetta-thread  
 0x00000001002cd858 thunk for @escaping @callee_guaranteed () ->
 () + 20
5   libdispatch.dylib                   0x00000001de139658
 _dispatch_call_block_and_release + 32
6   libdispatch.dylib                   0x00000001de13b150
 _dispatch_client_callout + 20
7   libdispatch.dylib                   0x00000001de13e090
 _dispatch_queue_override_invoke + 692
8   libdispatch.dylib                   0x00000001de14b774
 _dispatch_root_queue_drain + 356
9   libdispatch.dylib                   0x00000001de14bf6c
 _dispatch_worker_thread2 + 116
10  libsystem_pthread.dylib             0x00000001de3a9110
 _pthread_wqthread + 216
11  libsystem_pthread.dylib             0x00000001de3a7e80
 start_wqthread + 8
```

For the translated crash we have:
```
Thread 1 Crashed:: Dispatch queue: com.apple.root.default-qos
0   ???                                 0x00007fff0144ff40 ???
1   libsystem_kernel.dylib              0x00007fff6bdc4812
 __pthread_kill + 10
2   libsystem_c.dylib                   0x00007fff6bd377f0 abort
 + 120
3   perivalebluebell.com.icdab-rosetta-thread  
 0x0000000100d1c5ab start_threads + 259
4   perivalebluebell.com.icdab-rosetta-thread  
 0x0000000100d1ca1e thunk for @escaping @callee_guaranteed () ->
 () + 14
5   libdispatch.dylib                   0x00007fff6bbf753d
 _dispatch_call_block_and_release + 12
6   libdispatch.dylib                   0x00007fff6bbf8727
 _dispatch_client_callout + 8
7   libdispatch.dylib                   0x00007fff6bbfad7c
 _dispatch_queue_override_invoke + 777
8   libdispatch.dylib                   0x00007fff6bc077a5
 _dispatch_root_queue_drain + 326
9   libdispatch.dylib                   0x00007fff6bc07f06
 _dispatch_worker_thread2 + 92
10  libsystem_pthread.dylib             0x00007fff6be8c4ac
 _pthread_wqthread + 244
11  libsystem_pthread.dylib             0x00007fff6be8b4c3
 start_wqthread + 15
```

Note the actual line of code in thread stack 0 is `???` in the translated case.  Presumably this is the actual translated code that is synthesised by Rosetta.

Furthermore we have an additional two threads in the translated case, the exception server\index{Rosetta!Exception Server}, and the runtime environment:
```
Thread 3:: com.apple.rosetta.exceptionserver
0   runtime_t8027                       0x00007ffdfff76af8
 0x7ffdfff74000 + 11000
1   runtime_t8027                       0x00007ffdfff803cc
 0x7ffdfff74000 + 50124
2   runtime_t8027                       0x00007ffdfff82738
 0x7ffdfff74000 + 59192

Thread 4:
0   runtime_t8027                       0x00007ffdfffce8ac
 0x7ffdfff74000 + 370860
```

### Crashed Thread State Registers

In the native case, we get thread state registers:
```
Thread 1 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2:
 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x000000000000003c   x5: 0x0000000000000000   x6:
 0x0000000000000000   x7: 0x0000000000000000
    x8: 0x00000000000005b9   x9: 0xb91ed5337c66d7ee  x10:
 0x0000000000003ffe  x11: 0x0000000206c1fa22
   x12: 0x0000000206c1fa22  x13: 0x000000000000001e  x14:
 0x0000000000000881  x15: 0x000000008000001f
   x16: 0x0000000000000148  x17: 0x0000000200e28528  x18:
 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x000000016fbbb000  x21: 0x0000000000001707  x22:
 0x000000016fbbb0e0  x23: 0x0000000000000114
   x24: 0x000000016fbbb0e0  x25: 0x000000020252d184  x26:
 0x00000000000005ff  x27: 0x000000020252d6c0
   x28: 0x0000000002ffffff   fp: 0x000000016fbbab70   lr:
 0x00000001de3accbc
    sp: 0x000000016fbbab50   pc: 0x00000001de3015d8 cpsr:
 0x40000000
   far: 0x0000000100ff8000  esr: 0x56000080
```

In the translated case, we get thread state registers:
```
Thread 1 crashed with X86 Thread State (64-bit):
  rax: 0x0000000000000000  rbx: 0x000000030600b000  rcx:
 0x0000000000000000  rdx: 0x0000000000000000
  rdi: 0x0000000000000000  rsi: 0x0000000000000003  rbp:
 0x0000000000000000  rsp: 0x000000000000003c
   r8: 0x000000030600ad40   r9: 0x0000000000000000  r10:
 0x000000030600b000  r11: 0x00007fff6bd37778
  r12: 0x0000000000003d03  r13: 0x0000000000000000  r14:
 0x0000000000000006  r15: 0x0000000000000016
  rip: <unavailable>  rfl: 0x0000000000000287
```

### Translated Code information

In the translated case, we get extra information, presumably useful for those engineers that work on debugging Rosetta:
```
Translated Code Information:
  tmp0: 0xffffffffffffffff tmp1: 0x00007fff0144ff14 tmp2:
 0x00007fff6bdc4808
```

### External Modification Summary

In the native case, we saw:
```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 914636
    thread_create: 0
    thread_set_state: 804
```

Our code had attempted to call `thread_set_state` but was not able to (under any platform configuration due to macOS restrictions).

Looking that the translated case,
```
External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 1
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 915091
    thread_create: 0
    thread_set_state: 804
```

We see almost the same statistics, but interestingly we have `task_for_pid`\index{command!task for pid} set to 1.  So the translation environment only did a mimimal observation/modification of the actual process under translation.

### Virtual Memory Regions

The translated version of the program runs a bit heavier on RAM usage than the native version.

In the native case, we have:
```
                                VIRTUAL   REGION
REGION TYPE                        SIZE    COUNT (non-coalesced)
===========                     =======  =======
TOTAL                              1.7G     2053
TOTAL, minus reserved VM space     1.3G     2053
```

versus the translated case:

```
REGION TYPE                        SIZE    COUNT (non-coalesced)
===========                     =======  =======
TOTAL                              5.4G     1512
TOTAL, minus reserved VM space     5.1G     1512
```

Note in the translated case we have additional Virtual Memory regions for Rosetta:
```
Rosetta Arena                     2048K        1
Rosetta Generic                    864K       19
Rosetta IndirectBranch             512K        1
Rosetta JIT                      128.0M        1
Rosetta Return Stack               192K       12
Rosetta Thread Context             192K       12
```

## Rosetta Crashes

Rosetta is a powerful translation system.  But it does not translate all X86-64 instructions.  Vector instructions, as an example, cannot be translated and generate a crash when encountered.  @rosetta

Before diagnosing specific problems, it is worth familiarising ourselves with the Porting Guide from Apple because this can help us develop a reasonable hypothesis for why our program may be crashing.  @rosettaPortingGuide
