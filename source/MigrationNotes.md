# Migration Notes

This document summarizes the portability issues with the current code base in respect to porting
to Apple Silicon.  Note, our Xcode will only build for macOS, not iOS/tvOS/watchOS.

## icdab_thread

This has x86 specific thread state.  Needs migration.
