# Bad Memory Crashes

In this chapter, we study bad memory crashes.

These crashes are distinguished by reporting Exception Type,
`EXC_BAD_ACCESS (SIGSEGV)`\index{signal!SIGSEGV},
or `EXC_BAD_ACCESS (SIGBUS)`\index{signal!SIGBUS} in their Crash Report.

We look at a range of crashes obtained by searching the Internet.

## General principles

In operating systems, memory is managed by first collating contiguous memory\index{memory!contiguous} into memory pages, and then collating pages\index{memory!page} into segments\index{memory!segment}.  This allows metadata properties to be assigned to a segment that applies to all pages within the segment.  This allows the code of our program (the program _TEXT_) to be set to read only but executable.  This improves performance and security.

SIGBUS\index{signal!SIGBUS} (bus error)\index{bus error} means the memory address is correctly mapped into the address space of the process, but the process is not allowed to access the memory.

SIGSEGV\index{signal!SIGSEGV} (segment violation)\index{violation!segment} means the memory address is not even mapped into the process address space\index{process!address space}.
