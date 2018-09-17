# A Siri Crash

## Why are we looking at a Siri Crash?

Here is an example of Siri crashing on a Mac.  Note that binaries on a Mac are not encrypted.  This means we can demonstrate the use of third party tools to explore the binaries at fault.  Since only Apple has the source code for Siri, it adds to the challenge and forces us to think abstractly about the problem.

## The Crash report

Here is the Crash Report, suitably truncated for ease of demonstration:

```
Process:               SiriNCService [1045]
Path:                  
/System/Library/CoreServices/Siri.app/Contents/XPCServices/SiriNCService.xpc/
Contents/MacOS/SiriNCService
Identifier:            com.apple.SiriNCService
Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       KERN_INVALID_ADDRESS at 0x0000000000000018
Exception Note:        EXC_CORPSE_NOTIFY
VM Regions Near 0x18:
-->
    __TEXT                 0000000100238000-0000000100247000
    [   60K] r-x/rwx SM=COW  /System/Library/CoreServices/Siri.app/Contents/
    XPCServices/SiriNCService.xpc/Contents/MacOS/SiriNCService

Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:

Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   libobjc.A.dylib               	0x00007fff69feae9d objc_msgSend + 29
1   com.apple.CoreFoundation      	0x00007fff42e19f2c
 __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__ + 12
2   com.apple.CoreFoundation      	0x00007fff42e19eaf
___CFXRegistrationPost_block_invoke + 63
3   com.apple.CoreFoundation      	0x00007fff42e228cc
 __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 12
4   com.apple.CoreFoundation      	0x00007fff42e052a3
__CFRunLoopDoBlocks + 275
5   com.apple.CoreFoundation      	0x00007fff42e0492e
 __CFRunLoopRun + 1278
6   com.apple.CoreFoundation      	0x00007fff42e041a3
CFRunLoopRunSpecific + 483
7   com.apple.HIToolbox           	0x00007fff420ead96
RunCurrentEventLoopInMode + 286
8   com.apple.HIToolbox           	0x00007fff420eab06
ReceiveNextEventCommon + 613
9   com.apple.HIToolbox           	0x00007fff420ea884
_BlockUntilNextEventMatchingListInModeWithFilter + 64
10  com.apple.AppKit              	0x00007fff4039ca73 _DPSNextEvent + 2085
11  com.apple.AppKit              	0x00007fff40b32e34
-[NSApplication(NSEvent) _nextEventMatchingEventMask:untilDate:inMode:
dequeue:] + 3044
12  com.apple.ViewBridge          	0x00007fff67859df0
-[NSViewServiceApplication nextEventMatchingMask:untilDate:inMode:
dequeue:] + 92
13  com.apple.AppKit              	0x00007fff40391885
-[NSApplication run] + 764
14  com.apple.AppKit              	0x00007fff40360a72
NSApplicationMain + 804
15  libxpc.dylib                  	0x00007fff6af6cdc7 _xpc_objc_main + 580
16  libxpc.dylib                  	0x00007fff6af6ba1a xpc_main + 433
17  com.apple.ViewBridge          	0x00007fff67859c15
-[NSXPCSharedListener resume] + 16
18  com.apple.ViewBridge          	0x00007fff67857abe
NSViewServiceApplicationMain + 2903
19  com.apple.SiriNCService       	0x00000001002396e0 main + 180
20  libdyld.dylib                 	0x00007fff6ac12015 start + 1
```

## The Crash details

Looking at the 09:52 crash we see

`Exception Type:        EXC_BAD_ACCESS (SIGSEGV)`

This means we are accessing memory which does not exist.
The program that was running (known as the TEXT) was

```
/System/Library/CoreServices/Siri.app/Contents/XPCServices/SiriNCService.xpc/
Contents/MacOS/SiriNCService
```

This is interesting because normally it's applications that crash.  Here we see a software component crashing.
The Siri service is a distributed app which uses cross process communication\index{operating system!cross process communication} (xpc)\index{XPC} to do its work.
We see that from references to xpc as above.

What method were we trying to call on an object that no longer exists?
Helpfully, the crash dump provides the answer:

`
Application Specific Information:
objc_msgSend() selector name: didUnlockScreen:
`

Now we have to a first level approximation answered the _what_, _where_  and _when_ aspect of the crash.
It was a Siri component that crashed, in `SiriNCService` when `didUnlockScreen` was called on a non-existent object.

## Applying our Tool Box

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

We see that there is indeed a method, `didUnlockScreen`, and we see that there is a service object which is owned **weakly**.  This means that the object is not retained and could get freed.  It typically means we a user of the `SiriNCService` but not the owner.  We do not own the lifecycle of the object.

## Software Engineering Insights

The underlying software engineering problem here is one of lifecycle.  Part of the application has a object lifecycle we were not expecting.  The consumer should have been written to detect the absence of the service as a robustness and defensive programming best practice.  What can happen is that the software is maintained over time, and the lifecycles of objects grow more complex over time as new functionality is added but the old code using the objects is not updated in sync.

Taking one step further back we should ask what weak properties are used by this component?  From that we can create some simple unit test cases which test the code whilst those objects are nil.  Then we can go back and add robustness to the code paths that assumed the object were non-nil.

Taking a further step back, is there anything unusual in the design of this component that calls for integration testing?

```
grep -i heat SiriNCService.classdump.txt
@protocol SiriUXHeaterDelegate <NSObject>
- (void)heaterSuggestsPreheating:(SiriUXHeater *)arg1;
- (void)heaterSuggestsDefrosting:(SiriUXHeater *)arg1;
@interface SiriNCAlertViewController : NSViewController
<SiriUXHeaterDelegate, AFUISiriViewControllerDataSource,
 AFUISiriViewControllerDelegate>
    SiriUXHeater *_heater;
@property(readonly, nonatomic)
SiriUXHeater *heater; // @synthesize heater=_heater;
- (void)heaterSuggestsPreheating:(id)arg1;
- (void)heaterSuggestsDefrosting:(id)arg1;
@interface SiriUXHeater : NSObject
    id <SiriUXHeaterDelegate> _delegate;
@property(nonatomic)
__weak id <SiriUXHeaterDelegate> delegate; // @synthesize delegate=_delegate;
- (void)_suggestPreheat;
```

It seems that this component can be prepared and made ready and has a variety of levels of initialisation and de-initialisation.  Maybe this complexity is to make the user interface responsive.  But it sends us a message that this component needs an integration test suite that codifies the state machine so we know the lifecycle of the service.

## Lessons Learnt

We went from using HOWTO knowledge (understanding the Crash Report) to using tooling to get a baseline level of knowledge.  Then we started to apply Software Engineering experiences, and then we started reasoning about the actual design of the component to ask how we got here and what should be done to avoid the problem.  This journey from looking at the artefacts of a problem to getting to the root of what needs to be done is a common theme during crash dump analysis.  It cannot be achieved by just focusing on the HOWTO of comprehending crash reports.  We need to switch hats and see things from different perspectives in order to really make progress.
