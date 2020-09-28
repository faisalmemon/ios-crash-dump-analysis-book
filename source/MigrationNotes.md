# Migration Notes

This document summarizes the portability issues with the current code base in respect to porting
to Apple Silicon.  Note, our Xcode will only build for macOS, not iOS/tvOS/watchOS.

## Existing Code

### `icdab_thread` Needs work

This has x86 specific thread state.  Needs migration.

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

## New Code

### Fixed arg called with variadic args

Write an example program that calls a function implemented with fixed arguments, with variadic arguments on the call site, and show it crashing on ARM; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Dynamic calls with `objc_msgSend`

Write an example program that unsafely is transformed to variadic by `objc_msgSend`; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Boolean from Int failure

Since 1024 cast to BOOL is false on x86 but true on arm64 write some code which leads to a logic crash; see [Addressing Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code)

### Execute data as code

Write a simple program that places assembly code in a data array and then jumps into it.  This simulates writing a JIT compiler.  The aim is to trigger execute on readonly data segments; see [Porting JIT on Apple Silicon](https://developer.apple.com/documentation/apple_silicon/porting_just-in-time_compilers_to_apple_silicon)
