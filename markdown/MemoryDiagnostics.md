# Memory diagnostics

In this chapter, we look at different diagnostic options for resolving memory problems.

## Basics of memory allocation

The iOS platform allocates memory for our app either on the stack or from the heap.

Memory is allocated on the stack as a result of creating locally scoped variables within functions.
Memory is allocated from the heap as a result of calling malloc (or its variants).

The minimum granularity of allocation on the heap is 16 bytes (an implementation detail we are not to rely upon).  This means a small overshoot can sometimes go undetected when we are accidentally overwriting past the number of bytes we have allocated.

When memory is allocated, it is placed into a Virtual Memory region.  There are virtual memory regions for allocations of approximately the same size.  For example, MALLOC_LARGE, MALLOC_SMALL, MALLOC_TINY.  This strategy tends to reduce the amount of fragmentation of memory.  Furthermore, there is a region for storing the bytes of an image, the "CG image" region.  This allows the system to optimise the performance of the system.

The hard part about memory allocation errors is that the symptoms can be confusing because adjacent memory might be used to different purposes, so one logical area of the system can interfere with an unrelated area of the system.  Furthermore, there can be a delay (or latency) so the problem is discovered much after the problem was introduced.

## Address Sanitizer

A very powerful tool can assist with memory diagnostics, called the Address Sanitizer.
(See @asanchecker)

It requires us to recompile our code with the Schema setting for Address Sanitizer set:

![](screenshots/diagnostic_santizer_setting.png)

Address sanitizer does memory accounting (called Shadow Memory).  It knows which memory locations are "poisoned".  That is, memory which has not been allocated (or was allocated, and then freed).

@wwdc2015_413

Address sanitizer directly makes use of the compiler so that when code is compiled, any access to memory entails a check against the Shadow Memory to see if the memory location is poisoned.  If so, an error report is generated.

This is a very powerful tool because it tackles the two most important classes of memory error.  Firstly, using more bytes than we were allocated.  Secondly, using memory after it has been freed.  It goes much further to address other classes of memory error but those are less often encountered: stack buffer overflow, global variable overflow, overflows in C++ containers, and use after return bugs.

The cost of this convenience is that our program can be x2 to x5 slower.  It is something worth switching on in our continuous integration systems to shake out problems.

## Memory overshoot example

Consider the following code in the `icdab_edge` example program.  @icdabgithub

```
- (void)overshootAllocated
{
    uint8_t *memory = malloc(16);
    for (int i = 0; i < 16 + 1; i++) {
        *(memory + i) = 0xff;
    }
}
```

This code allocates the minimum amount of memory, 16 bytes.  Then it writes to 17 consecutive memory locations.  We get a heap overflow bug.

This problem, itself, does not make our app crash immediately.  If we rotate the device, the latent fault is triggered and we get a crash.  By enabling the address sanitizer, we immediately get a crash.
This is a huge benefit.  Otherwise, we might have wasted a lot of time in debugging screen rotation related code.

The error report from Address Sanitizer is extensive.  We only show selected portions of the report for ease of demonstration.

The error report begins with:
```
==21803==ERROR: AddressSanitizer: heap-buffer-overflow on address
 0x60200003a5e0 at pc 0x00010394461b bp 0x7ffeec2b8f00 sp 0x7ffeec2b8ef8
WRITE of size 1 at 0x60200003a5e0 thread T0
#0 0x10394461a in -[Crash overshootAllocated] Crash.m:48
```

This is enough context to be able to switch to the code and start understanding the problem.

Further details are supplied showing we off the end of a 16-byte allocation:
```
0x60200003a5e0 is located 0 bytes to the right of 16-byte region
 [0x60200003a5d0,0x60200003a5e0)
allocated by thread T0 here:
#0 0x103bcdaa3 in wrap_malloc
(libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
#1 0x1039445ae in -[Crash overshootAllocated] Crash.m:46
```

and we also get a "map" of the memory around the problem:
```
SUMMARY: AddressSanitizer: heap-buffer-overflow Crash.m:48 in
 -[Crash overshootAllocated]
Shadow bytes around the buggy address:
  0x1c0400007460: fa fa 00 00 fa fa fd fd fa fa fd fa fa fa fd fa
  0x1c0400007470: fa fa 00 00 fa fa fd fa fa fa 00 00 fa fa fd fd
  0x1c0400007480: fa fa fd fa fa fa fd fd fa fa fd fa fa fa fd fa
  0x1c0400007490: fa fa fd fd fa fa fd fd fa fa fd fa fa fa fd fa
  0x1c04000074a0: fa fa 00 fa fa fa 00 00 fa fa fd fd fa fa 00 00
=>0x1c04000074b0: fa fa 00 00 fa fa 00 00 fa fa 00 00[fa]fa fa fa
  0x1c04000074c0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x1c04000074d0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x1c04000074e0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x1c04000074f0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x1c0400007500: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
```

From `[fa]` we see we hit the first byte of the "redzone" (poisoned memory).

## Use after free example

Consider the following code in the `icdab_edge` example program.  @icdabgithub

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

This code allocates the minimum amount of memory, 16 bytes, writes to it, frees it and then tries a second time to write to the same memory.

Address Sanitizer reports where we accessed memory that has already been freed:
```
35711==ERROR: AddressSanitizer: heap-use-after-free on address 0x602000037270 at pc 0x000106d34381 bp 0x7ffee8ec9ef0 sp 0x7ffee8ec9ee8
WRITE of size 1 at 0x602000037270 thread T0
    #0 0x106d34380 in -[Crash useAfterFree] Crash.m:60
```

It tells us where the free was done:
```
0x602000037270 is located 0 bytes inside of 16-byte region [0x602000037270,0x602000037280)
freed by thread T0 here:
    #0 0x106fbdc6d in wrap_free (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54c6d)
    #1 0x106d34318 in -[Crash useAfterFree] Crash.m:58
```

It tells us where the memory was originally allocated:
```
previously allocated by thread T0 here:
    #0 0x106fbdaa3 in wrap_malloc (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
    #1 0x106d3428e in -[Crash useAfterFree] Crash.m:54
    SUMMARY: AddressSanitizer: heap-use-after-free Crash.m:60 in -[Crash useAfterFree]
```

Finally, it shows us a picture of memory around the faulty address:
```
    Shadow bytes around the buggy address:
      0x1c0400006df0: fa fa fd fd fa fa 00 00 fa fa fd fd fa fa fd fa
      0x1c0400006e00: fa fa fd fa fa fa 00 00 fa fa fd fa fa fa 00 00
      0x1c0400006e10: fa fa fd fd fa fa fd fa fa fa fd fd fa fa fd fa
      0x1c0400006e20: fa fa fd fa fa fa fd fd fa fa fd fd fa fa fd fa
      0x1c0400006e30: fa fa fd fa fa fa 00 fa fa fa 00 00 fa fa fd fd
    =>0x1c0400006e40: fa fa 00 00 fa fa 00 00 fa fa 00 00 fa fa[fd]fd
      0x1c0400006e50: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
      0x1c0400006e60: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
      0x1c0400006e70: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
      0x1c0400006e80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
      0x1c0400006e90: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    Shadow byte legend (one shadow byte represents 8 application bytes):
      Addressable:           00
      Partially addressable: 01 02 03 04 05 06 07
      Heap left redzone:       fa
      Freed heap region:       fd
```

We see the entry, `[fd]` indicating a write to memory that has been freed already.

## Memory Management tools

There are a collection of tools complementary to the Address Sanitizer tool.  These are to be used when Address Sanitizer is off.  They catch certain causes of failure that Address Sanitizer would miss.

The memory management tools do not require a re-compilation of the project.  That is their main advantage.

## Guard Malloc Tool

This tool is only available on simulator targets, a major disadvantage.
Every allocation is placed into its own memory page with guard pages before and after.
This tool is largely superseded by Address Sanitizer.

## Malloc Scribble

The purpose of Malloc Scribble is to make the symptoms of memory errors predictable by having `malloc`ed  or `free`ed memory assigned to fixed known values.  Allocated memory is given `0xAA` and deallocated memory is given `0x55`.  It does not affect the behavior of data allocated on the stack.  It is not compatible with Address Sanitizer.

If we have an app that keeps crashing different ways each time it is run, then Malloc Scribble is a good option.  It will help make the crash predictable and repeatable.

Consider the following code in the `icdab_edge` example program.  @icdabgithub

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

First, `source` is given freshly allocated memory.  Since this memory has not yet been initialised, it is set to 0xAA when Malloc Scribble has been set (and address sanitizer reset) in the Schema settings.

Then, `target` is setup.  It is a buffer on the stack (not heap memory).  Using the code, `= {0}`, we make the app set `0` in all memory locations of this buffer.  Otherwise, it would be random memory values.

Then we enter a loop.  By breakpointing in the debugger, say at the second iteration, we can print off the memory contents and see the following:

![](screenshots/scribble.png)

We see that the `target` buffer is zeros apart from the first two index positions where it is `0xAA`.
We see that the `source` memory is always `0xAA`

If we had not set Malloc Scribble, the target buffer would have got filled with random values.
In a complex program, such data could be fed to other subsystems affecting the behavior of the program.
