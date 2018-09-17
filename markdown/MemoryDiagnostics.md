# Memory diagnostics

In this chapter, we look at different diagnostic options for resolving memory problems.

## Basics of memory allocation

The iOS platform allocates memory for our app either on the stack or from the heap.

Memory is allocated on the stack whenever we create locally scoped variables within functions.
Memory is allocated from the heap whenever we call `malloc`\index{command!malloc} (or its variants).

The minimum granularity of allocation on the heap is 16 bytes (an implementation detail we are not to rely upon).  This means a small overshoot can sometimes go undetected when we are accidentally overwriting past the number of bytes we have allocated.

When memory is allocated, it is placed into a Virtual\index{memory!virtual} Memory region.  There are virtual memory regions for allocations of approximately the same size.  For example, we have regions `MALLOC_LARGE`, `MALLOC_SMALL`, `MALLOC_TINY`.  This strategy tends to reduce the amount of fragmentation of memory.  Furthermore, there is a region for storing the bytes of an image, the "CG image" region.  This allows the system to optimize the performance of the system.

The hard part about memory allocation errors is that the symptoms can be confusing because adjacent memory might be used to different purposes, so one logical area of the system can interfere with an unrelated area of the system.  Furthermore, there can be a delay (or latency) so the problem is discovered much after the problem was introduced.

## Address Sanitizer

A very powerful tool can assist with memory diagnostics, called the Address Sanitizer.
(See @asanchecker)

It requires us to recompile our code with the Schema setting for Address Sanitizer set:

![](screenshots/diagnostic_santizer_setting.png)

Address sanitizer does memory accounting (called Shadow Memory).  It knows which memory locations are "poisoned".  That is, memory which has not been allocated (or was allocated, and then freed).

@wwdc2015_413

Address sanitizer directly makes use of the compiler so that when code is compiled, any access to memory entails a check against the Shadow Memory to see if the memory location is poisoned.  If so, an error report is generated.

This is a very powerful tool because it tackles the two most important classes of memory error:

1. Heap Buffer Overflow
2. Heap Use After Free

_Heap Buffer Overflow_ bugs are where we used more bytes than we were allocated.
_Heap Use After Free_  bugs are where we used memory after it had been freed.

Address Sanitizer goes much further to address other classes of memory error but those are less often encountered: stack buffer overflow, global variable overflow, overflows in C++ containers, and use after return bugs.

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

This is enough context to be able to switch to the code, and start understanding the problem.

Further details are supplied showing we overshot the end of a 16-byte allocation:
```
0x60200003a5e0 is located 0 bytes to the right of 16-byte region
 [0x60200003a5d0,0x60200003a5e0)
allocated by thread T0 here:
#0 0x103bcdaa3 in wrap_malloc
(libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
#1 0x1039445ae in -[Crash overshootAllocated] Crash.m:46
```

Note the use of a "half-open" number range number notation, where `[` includes the lower range index, and `)` excludes the upper range index.  So our access to `0x60200003a5e0` is outside the allocated range `[0x60200003a5d0,0x60200003a5e0)`

We also get a "map" of the memory around the problem:
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
35711==ERROR: AddressSanitizer: heap-use-after-free on address
0x602000037270 at pc 0x000106d34381 bp 0x7ffee8ec9ef0 sp 0x7ffee8ec9ee8
WRITE of size 1 at 0x602000037270 thread T0
    #0 0x106d34380 in -[Crash useAfterFree] Crash.m:60
```

It tells us where the free was done:
```
0x602000037270 is located 0 bytes inside of 16-byte region
 [0x602000037270,0x602000037280)
freed by thread T0 here:
    #0 0x106fbdc6d in wrap_free
    (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54c6d)
    #1 0x106d34318 in -[Crash useAfterFree] Crash.m:58
```

It tells us where the memory was originally allocated:
```
previously allocated by thread T0 here:
    #0 0x106fbdaa3 in wrap_malloc
    (libclang_rt.asan_iossim_dynamic.dylib:x86_64+0x54aa3)
    #1 0x106d3428e in -[Crash useAfterFree] Crash.m:54
    SUMMARY: AddressSanitizer: heap-use-after-free Crash.m:60 in
     -[Crash useAfterFree]
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

There is a collection of tools complementary to the Address Sanitizer tool.  These are to be used when Address Sanitizer is off.  They catch certain causes of failure that Address Sanitizer would miss.

In contrast to the Address Sanitizer, the memory management tools do not require a re-compilation of the project.

### Guard Malloc Tool

This tool is only available on simulator targets, a major disadvantage.
Every allocation is placed into its own memory page with guard pages before and after.
This tool is largely superseded by Address Sanitizer.

### Malloc Scribble

The purpose of Malloc Scribble is to make the symptoms of memory errors predictable by having `malloc`-ed  or `free`-ed memory assigned to fixed known values.  Allocated memory is given `0xAA` and deallocated memory is given `0x55`.  It does not affect the behavior of data allocated on the stack.  It is not compatible with Address Sanitizer.

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

First, `source` is given freshly allocated memory.  Since this memory has not yet been initialized, it is set to 0xAA when Malloc Scribble has been set (and address sanitizer reset) in the Schema settings.

Then, `target` is setup.  It is a buffer on the stack (not heap memory).  Using the code, `= {0}`, we make the app set `0` in all memory locations of this buffer.  Otherwise, it would be random memory values.

Then we enter a loop.  By breakpointing in the debugger, say at the second iteration, we can print off the memory contents and see the following:

![](screenshots/scribble.png)

We see that the `target` buffer is zeros apart from the first two index positions where it is `0xAA`.
We see that the `source` memory is always `0xAA`

If we had not set Malloc Scribble, the target buffer would have been filled with random values.
In a complex program, such data could be fed to other subsystems affecting the behavior of the program.

### Zombie Objects

The purpose of Zombie Objects is to detect use-after-free bugs in the context of Objective-C `NSObject`s.  Particularly if we have a legacy code base that uses Manual Reference Counting, it can be easy to over release an object.  This means that messaging through the, now dangling, pointer can have unpredictable effects.

This setting must only be made on debug builds because the code will no longer release objects.  Its performance profile is equivalent to leaking every object that should have been deallocated.  

This setting will make deallocated objects to instead become `NSZombie` objects.  This means that any method called upon the object will result in a crash.  Any message sent to an `NSZombie` object results in a crash. Therefore, whenever an over-released object is messaged, we are guaranteed a crash.

Consider the following code in the `icdab_edge` example program.  @icdabgithub

```
- (void)overReleasedObject
{
    id a = [[UIViewController alloc] init];
    // Build Phases -> Compile Sources -> Crash.m has Compiler Flags setting
    // -fno-objc-arc to allow the following line to be called
    [a release];
    NSLog(@"%@", [a description]);
}
```

When the above code is called we get a crash, and the following is logged:

```
2018-09-12 12:09:10.236058+0100 icdab_edge[92796:13650378]
 *** -[UIViewController description]: message sent to deallocated
  instance 0x7fba1ff071c0
```

Looking at the debugger, we see:

![](screenshots/zombie.png)

Note how the type of the object instance `a` is `_NSZombie_UIViewController *`.

The type will be whatever the original type of the over released object was, but prefixed with `_NSZombie_`.
This is most helpful, and we should look out for this when studying the program state in the debugger.

### Malloc Stack

Sometimes the past dynamic behavior of our app needs to be understood in order to resolve why the application crashed.  For example, we may have leaked memory, and then we were terminated by the system for using too much memory.  We might have a data structure and wonder which part of the code was responsible for allocating it.

The purpose of the `Malloc Stack` option is to provide the historical data need.  Memory analysis has been enhanced by Apple by providing complementary visual tools.  Malloc Stack has a sub-option, "All Allocation and Free History" or "Live Allocations Only"

We recommend the "All Allocation" option, unless there is just too much overhead experienced due to having an app with heavy use of memory allocation.  The "Live Allocations Only" option is sufficient to catch memory leaks\index{memory!leak} as well as being low overhead, so it is the default option in the User Interface.

The steps to follow are:

1. Set the `Malloc Stack` option in the Diagnostics settings tab for the app Schema settings.
2. Launch the app.
3. Press the Debug Memgraph Button
4. For command line based analysis, _File -> Export Memory Graph..._

The Memgraph visual tool within Xcode is comprehensive but can feel daunting.
There is a helpful WWDC video to show the basics.  @wwdc2018_416

There is normally too much low-level detail to review.  The best way to use the graphical tool is when we have some hypothesis on why the app is incorrectly using memory.

#### Malloc Stack Memgraph example: detecting retain cycles

A quick win is to see if we have any leaks.  These are memory locations no longer reachable to be able to free up.

We use the tvOS\index{tvOS} example app `icdab_cycle` to show a retain cycle found by Memgraph.  @icdabgithub

Having set the Schema settings for Malloc Stack, we then launch the app and then press the Memgraph Button, shown below:

![](screenshots/memgraphbutton.png)

By pressing the exclamation mark filter button we can filter to only showing leaks:

![](screenshots/retaincycle.png)

If we had done _File -> Export Memory Graph..._, to export the memgraph to `icdab_cycle.memgraph`, we could see the equivalent information from the Mac Terminal app with the command line:\index{command!leaks}

```
leaks icdab_cycle.memgraph

Process:         icdab_cycle [15295]
Path:            /Users/faisalm/Library/Developer/CoreSimulator/Devices/
1616CA04-D1D0-4DF6-BE8E-F63541EC1EED/data/Containers/Bundle/Application/
E44B9EFD-258B-4D0E-8637-CF374638D5FF/icdab_cycle.app/icdab_cycle
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
AppleTVOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/
tvOS.simruntime/Contents/Resources/RuntimeRoot/Developer/Library/
PrivateFrameworks/DVTInstrumentsFoundation.framework/LeakAgent
Analysis Tool Version:  iOS Simulator 12.0 (16J364)

Physical footprint:         38.9M
Physical footprint (peak):  39.0M
----

leaks Report Version: 3.0
Process 15295: 30252 nodes malloced for 5385 KB
Process 15295: 3 leaks for 144 total leaked bytes.

Leak: 0x600000d506c0  size=64  zone: DefaultMallocZone_0x11da72000
   Song  Swift  icdab_cycle
	Call stack: [thread 0x10a974380]: |
   0x10a5f678d (libdyld.dylib) start |
    0x106eba614 (icdab_cycle) main
     AppDelegate.swift:12 ....
```

The code that causes this leak is:
```
var mediaLibrary: Album?

func createRetainCycleLeak() {
    let salsa = Album()
    let carnaval = Song(album: salsa, artist: "Salsa Latin 100%",
     title: "La Vida Es un Carnaval")
    salsa.songs.append(carnaval)
}

func buildMediaLibrary() {
    let kylie = Album()
    let secret = Song(album: kylie, artist: "Kylie Minogue",
     title: "It's No Secret")
    kylie.songs.append(secret)
    mediaLibrary = kylie
    createRetainCycleLeak()
}
```

The problem is that `createRetainCycleLeak()` `carnaval` `Song` makes a strong reference to `salsa` `Album` and `salsa` makes a strong reference to `carnaval` `Song` and when we return from this method, there is no reference to either object from another object.  The two objects become disconnected from the rest of the object graph, and they cannot be automatically released due to their mutual strong references (known as a retain cycle\index{memory!retain cycle}).  A very similar object relationship for `kylie` `Album` does not trigger a leak because that is referenced by a top level graph object `mediaLibrary`

### Dynamic Linker API Usage

Sometimes programs dynamically adapt or are extensible.  For such programs, the dynamic linker\index{linker} API is used to programmatically load up extra code modules.  When the configuration or deployment of the app is faulty, this can result in crashes.

To debug such problems, set the `Dynamic Linker API Usage` flag.  This can generate many messages so may cause problems on slower platforms with limited start up times such as a 1st generation Apple Watch\index{trademark!Apple Watch}\index{watchOS}.

An example app using the dynamic linker is available on GitHub. @dynamicloadingeg

The kind of output when it is enabled is:

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

dlopen(DynamicFramework2.framework/DynamicFramework2) ==> 0x60c0001460f0
.
.
.
```

A huge amount of logging is generated.  It is best to start by searching for the `dlopen`\index{command!dlopen} command, and then looking to see what other functions in the `dlopen` family are called.

### Dynamic Library Loads

Sometimes we have an early stage app crash during the initialization phase where the dynamic loader is loading the app binary and its dependent frameworks.  If we are confident that it is not custom code using the dynamic linker API, but instead it is the assembly of frameworks into the loaded binary we care about, then switching on the `Dynamic Library Loads` flag is appropriate.  We get much shorter logs that enabling the `Dynamic Linker API Usage` flag.

Upon launch, we get a list of binaries loaded:

```
dyld: loaded: /Users/faisalm/Library/Developer/CoreSimulator/Devices/
99DB717F-9161-461A-B11F-210C389ABA12/data/Containers/Bundle/Application/
D916AC0F-6434-46A3-B18E-5EC65D194454/icdab_edge.app/icdab_edge

dyld: loaded: /Applications/Xcode.app/Contents/Developer/
Platforms/iPhoneOS.platform/Contents/Resources/RuntimeRoot/
usr/lib/libBacktraceRecording.dylib
.
.
.
```
