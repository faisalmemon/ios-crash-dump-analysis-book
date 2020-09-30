# Migration Notes

This document summarizes the portability issues with the current code base in respect to porting
to Apple Silicon.  Note, our Xcode will only build for macOS, not iOS/tvOS/watchOS.

## Existing Code

### `icdab_sema` Needs work

This has multiple targets, `icdab_sema_{mac, ios}`.  The mac variant compiles ok on the main Xcode 12.0 beta (12A8158a).  I need to test on the Apple Silicon version.

### `icdab_as`

The prologues for the assembly of egg.s was out of date.  To get a proper modern prologue, we obtain it with the `scaffold.c` file.
>  Product > Perform Action > Assemble `scaffold.c`

### `icdab_asl`

No changes needed.

### `icdab_cycle` Needs work

I think modernising has broken it.  Need to re-check

### `icdab_edge` Needs work

Not all options cause a crash.  We don't get a crash with OvershootAllocated, and Uninitialized Memory.

### `icdab_nsdata`

No changes needed.

### `icdab_planets`

No changes needed.

### `icdab_sample`

No changes needed.

### `icdab_sema`

No changes needed.  But this app comes in two flavours, iOS and macOS so needs to be tested on Apple Silicon.

### `icdab_thread` 

This has x86 specific thread state.  Needs migration.
The API that was missing for setting thread state is now available.  Needs to be tested on Apple silicon.
It seems that setting the thread state can no longer be done by other processes, so I cannot make it say a non-zero value
for that in the crash dump.

## New Code

### Fixed arg called with variadic args

Write an example program that calls a function implemented with fixed arguments, with variadic arguments on the call site, and show it crashing on ARM; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Dynamic calls with `objc_msgSend`

Write an example program that unsafely is transformed to variadic by `objc_msgSend`; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Boolean from Int failure

Since 1024 cast to BOOL is false on x86 but true on arm64 write some code which leads to a logic crash; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Execute data as code

Write a simple program that places assembly code in a data array and then jumps into it.  This simulates writing a JIT compiler.  The aim is to trigger execute on readonly data segments; see [Porting JIT on Apple Silicon](https://developer.apple.com/documentation/apple_silicon/porting_just-in-time_compilers_to_apple_silicon)
