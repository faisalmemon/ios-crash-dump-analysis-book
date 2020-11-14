## Mac Hosting iOS apps

A surprising "bonus feature" arising from the introduction of Apple Silicon Macs is that since they share the same CPU architecture as iOS devices, it is possible for unmodified iOS apps to run on macOS.  For this to work, Apple Silicon Macs in macOS have special support libraries.

The way we can think about it is that macOS is the _host_ that provides support libraries and frameworks, such as `UIKit`, that iOS _guest_ apps expect to be in place.

When such an app crashes, we get a crash report that is a macOS crash report, but most of the details involve iOS libraries.
