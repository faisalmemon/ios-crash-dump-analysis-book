## Wake Up crash exception

The iOS platform can classify a wake up crash in some cases with an `Exception Code`.  

For example faulty networking code gave rise to the following crash, truncated for ease of demonstration:

```
Exception Type:  00000020
Exception Codes: 0xbad22222
Highlighted Thread:  3

Application Specific Information:
SBUnsuspendLimit ooVoo[360] exceeded 15 wakes in 300 sec

Thread 3 name:  com.apple.NSURLConnectionLoader
Thread 3:
0   libsystem_kernel.dylib          0x307fc010 mach_msg_trap + 20
1   libsystem_kernel.dylib          0x307fc206 mach_msg + 50
2   CoreFoundation                  0x3569b41c
__CFRunLoopServiceMachPort + 120
3   CoreFoundation                  0x3569a154 __CFRunLoopRun + 876
4   CoreFoundation                  0x3561d4d6 CFRunLoopRunSpecific + 294
5   CoreFoundation                  0x3561d39e CFRunLoopRunInMode + 98
6   Foundation                      0x3167abc2
+[NSURLConnection(Loader) _resourceLoadLoop:] + 302
7   Foundation                      0x3167aa8a -[NSThread main] + 66
8   Foundation                      0x3170e59a __NSThread__main__ + 1042
9   libsystem_c.dylib               0x30b68c16 _pthread_start + 314
10  libsystem_c.dylib               0x30b68ad0 thread_start + 0
```

The code `0xbad22222`\index{0xbad22222} is read "Bad too many times" using "too" as a pun on "2".

The ooVoo app makes heavy use of networking because it is a video chat platform.

This type of crash can be due to improper use of networking APIs. @impropersockets
