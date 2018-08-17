# Bad Memory Crashes

In this chapter, we study bad memory crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_BAD_ACCESS (SIGSEGV)`\index{signal!SIGSEGV},
or `EXC_BAD_ACCESS (SIGBUS)`\index{signal!SIGBUS} in their Crash Report.

We look at a range of crashes obtained by searching the Internet.

## General principles

In operating systems, memory is managed by first collating contiguous memory into memory pages, and then collating pages into segments.  This allows meta data properties to be assigned to a segment that applies to all pages within the segment.  This allows the code of your program (the program _TEXT_) to be set to read only but executable.  This improves performance and security.

SIGBUS (bus error) means the memory address is correctly mapped into the address space of the process, but the process is not allowed to access the memory.

SIGSEGV (segment violation) means the memory address is not even mapped into the process address space.

## Segment Violation (SEGV) crashes



EXC_BAD_ACCESS (SIGSEGV)

EXC_BAD_ACCESS
fud_crash_osx
kiosk_startup

SIGSEGV
leak_agent_crash
siri_crash

SIGBUS
xmbc_sigbus
jablotron_sigbus_align_ios
