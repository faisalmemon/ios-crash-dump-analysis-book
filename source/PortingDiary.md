# Porting Diary

This document enumerates the documents, ideas, and activities done on the source code to prepare it to be able to adequately cover existing platforms and Apple Silicon platforms.

## New Failure Modes

From reading [macOS Architectural Differences](https://developer.apple.com/documentation/apple_silicon/addressing_architectural_differences_in_your_macos_code) I notice that it is possible to get a crash from redeclaring a fixed arg function as a variadic function and calling that variadic from other code when on Apple Silicon.

## Macros needed for multi-architecture binaries

I note the guidance for how to write macros for multi-architecture code at [Building Universal macOS Binaries](https://developer.apple.com/documentation/xcode/building_a_universal_macos_binary)
