# Siri Crash

Looking at the 09:52 crash we see

`Exception Type:        EXC_BAD_ACCESS (SIGSEGV)`

This means we are accessing memory which does not exist.
The program that was running (known as the TEXT) was

`    __TEXT                 0000000100238000-0000000100247000 [   60K] r-x/rwx SM=COW  /System/Library/CoreServices/Siri.app/Contents/XPCServices/SiriNCService.xpc/Contents/MacOS/SiriNCService
`

This is interesting because normally its applications that crash.  Here we see a software component crashing.
The Siri service is a distributed app which uses cross process communication (xpc) to do its work.
We see that from references to xpc as above.

What method were we trying to call on an object that no longer exists?
Helpfully, the crash dump provides the answer:

`
Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:
`

Now we have to a first level approximation answered the _what_, _where_  and _when_ aspect of the crash.
It was a Siri component that crashed, in SiriNCService when didUnlockScreen was called on a non-existent object.

Now to understand further we need to reach for the `class-dump` tool.

`class-dump SiriNCService > SiriNCService.classdump.txt`

Looking at a portion of the output is the following:

```
@property __weak SiriNCService *service; // @synthesize service=_service;
- (void).cxx_destruct;
- (BOOL)isSiriListening;
- (void)_didUnlockScreen:(id)arg1;
- (void)_didLockScreen:(id)arg1;
```

We see that there is indeed a method, didUnlockScreen, and we see that there is a service object which is owned **weakly**.  This means that the object is not retained and could get freed.  It typically means we a user of the SiriNCService but not the owner.  We do not own the lifecycle of the object.

The underlying software engineering problem here is one of lifecycle.  Part of the application has a object lifecycle we were not expecting.  The consumer should have been written to detect the absence of the service as a robustness and defensive programming best practice.  What can happen is that the software is maintained over time, and the lifecycles of objects grow more complex over time as new functionality is added but the old code using the objects is not updated in sync.
