## iOS on Mac

Since Apple Silicon Macs and iOS devices share the same ARM CPU architecture, Apple has made available a "bonus feature".  It is possible for unmodified iOS apps to run on ARM-based macOS.  For this to work, ARM-based macOS has some special iOS support libraries.

The way we can think about it is that macOS is the _host_ that provides support libraries and frameworks, such as `UIKit`, that iOS _guest_ apps expect to be in place.

When such an app crashes, we get a crash report that is a macOS crash report, but most of the details involve iOS libraries.

