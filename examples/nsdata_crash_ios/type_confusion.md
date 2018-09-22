## Type confusion

The compiler does an excellent job of static type checking.  When types are inferred dynamically problems can arise.  Configuration files are further troublesome in this area.  It can be easy to set the wrong type for a configuration parameter.

We use the example code, `icdab_nsdata`, to illustrate our point.  @icdabgithub

### Extracting NSData from a configuration file

Consider the example code:

```
- (BOOL)application:(UIApplication *)application
 didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application
    // launch.

    NSData *myToken = [[NSData alloc] initWithData:
    [[NSUserDefaults standardUserDefaults]
     objectForKey:@"SomeKey"]];

    NSLog(@"My data is %@ - ok since we can handle a nil",
     myToken);

    id stringProperty = @"Some string";
    NSData *problemToken = [[NSData alloc]
     initWithData:stringProperty];

    NSLog(@"My data is %@ - we have probably crashed by now",
     problemToken);
    return YES;
}
```

This code tries to do two things.  Firstly, it tries to get a data token from its configuration.
We assume from a previous run, the user defaults saved an `NSData` token under the key `SomeKey`

By design, the `NSData` abstraction can handle whether the supplied data is `nil`.  So if no token has yet been set, we are still ok.

It might be the case that the token data is just a simple hex string like `7893883873a705aec69e2942901f20d7b1e28dec`

The above code has `stringProperty` that is supposed to model the case where the data token was recorded as a string in the user defaults instead of as `NSData`.
Perhaps it was manually copy-pasted into the `plist` file of the user defaults.  If the `initWithData` method is passed an `NSString` it cannot create an `NSData` object.  We get a crash.

If we run the code, we get the following Crash Report, truncated for ease of demonstration:

### Deserialization Crash Report

```
Incident Identifier: 12F72C5C-E9BD-495F-A017-832E3BBF285E
CrashReporter Key:   56ec2b40764a1453466998785343f1e51c8b3849
Hardware Model:      iPod5,1
Process:             icdab_nsdata [324]
Path:                /private/var/containers/Bundle/Application/
98F79023-562D-4A76-BC72-5E56D378AD98/
icdab_nsdata.app/icdab_nsdata
Identifier:          www.perivalebluebell.icdab-nsdata
Version:             1 (1.0)
Code Type:           ARM (Native)
Parent Process:      launchd [1]
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Triggered by Thread:  0

Filtered syslog:
None found

Last Exception Backtrace:
0   CoreFoundation                	0x25aa3916
 __exceptionPreprocess + 122
1   libobjc.A.dylib               	0x2523ee12
 objc_exception_throw + 33
2   CoreFoundation                	0x25aa92b0
-[NSObject+ 1045168 (NSObject) doesNotRecognizeSelector:]
 + 183
3   CoreFoundation                	0x25aa6edc
 ___forwarding___ + 695
4   CoreFoundation                	0x259d2234
 _CF_forwarding_prep_0 + 19
5   Foundation                    	0x2627e9a0
-[_NSPlaceholderData initWithData:] + 123
6   icdab_nsdata                  	0x000f89ba
-[AppDelegate application:
didFinishLaunchingWithOptions:] + 27066 (AppDelegate.m:26)
7   UIKit                         	0x2a093780
 -[UIApplication _handleDelegateCallbacksWithOptions:
 isSuspended:restoreState:] + 387
8   UIKit                         	0x2a2bb2cc
 -[UIApplication _callInitializationDelegatesForMainScene:
 transitionContext:] + 3075
9   UIKit                         	0x2a2bf280
-[UIApplication _runWithMainScene:transitionContext:
completion:] + 1583
10  UIKit                         	0x2a2d3838
__84-[UIApplication _handleApplicationActivationWithScene:
transitionContext:completion:]_block_invoke3286 + 31
11  UIKit                         	0x2a2bc7ae
 -[UIApplication workspaceDidEndTransaction:] + 129
12  FrontBoardServices            	0x27146c02
 __FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 13
13  FrontBoardServices            	0x27146ab4
-[FBSSerialQueue _performNext] + 219
14  FrontBoardServices            	0x27146db4
-[FBSSerialQueue _performNextFromRunLoopSource] + 43
15  CoreFoundation                	0x25a65dfa
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__
 + 9
16  CoreFoundation                	0x25a659e8
__CFRunLoopDoSources0 + 447
17  CoreFoundation                	0x25a63d56
 __CFRunLoopRun + 789
18  CoreFoundation                	0x259b3224
 CFRunLoopRunSpecific + 515
19  CoreFoundation                	0x259b3010
CFRunLoopRunInMode + 103
20  UIKit                         	0x2a08cc38
 -[UIApplication _run] + 519
21  UIKit                         	0x2a087184
 UIApplicationMain + 139
22  icdab_nsdata                  	0x000f8830
 main + 26672 (main.m:14)
23  libdyld.dylib                 	0x2565b86e tlv_get_addr
 + 41
```

Unfortunately, this type of crash does not inject further helpful information, such as `Application Specific Information`, into the Crash Report.

However, we do get information in the system log (console log of the app):

```
default	13:36:58.000000 +0000	icdab_nsdata	 
My data is <> - ok since we can handle a nil

default	13:36:58.000000 +0100	icdab_nsdata	 
-[__NSCFConstantString _isDispatchData]:
unrecognized selector sent to instance 0x3f054

default	13:36:58.000000 +0100	icdab_nsdata
	 *** Terminating app due to uncaught exception
    'NSInvalidArgumentException', reason:
    '-[__NSCFConstantString _isDispatchData]:
     unrecognized selector sent to instance 0x3f054'

	*** First throw call stack:
	(0x25aa391b 0x2523ee17 0x25aa92b5 0x25aa6ee1 0x259d2238
     0x2627e9a5 0x3d997
     0x2a093785 0x2a2bb2d1 0x2a2bf285 0x2a2d383d 0x2a2bc7b3
      0x27146c07
      0x27146ab9 0x27146db9 0x25a65dff 0x25a659ed 0x25a63d5b
       0x259b3229
      0x259b3015 0x2a08cc3d 0x2a087189 0x3d80d 0x2565b873)

default	13:36:58.000000 +0100
	SpringBoard Application
  'UIKitApplication:www.perivalebluebell.icdab-nsdata[0x51b9]'
    crashed.

default	13:36:58.000000 +0100
UserEventAgent
	 2769630555571: id=www.perivalebluebell.icdab-nsdata
   pid=386, state=0

default	13:36:58.000000 +0000	ReportCrash
	 Formulating report for corpse[386] icdab_nsdata

default	13:36:58.000000 +0000	ReportCrash
	 Saved type '109(109_icdab_nsdata)'
    report (2 of max 25) at
    /var/mobile/Library/Logs/CrashReporter/
    icdab_nsdata-2018-07-27-133658.ips
```

From here we can see the problem is that `__NSCFConstantString` is unable to respond to `_isDispatchData` because `NSString` is not a data providing object.

The Apple SDKs have private implementation classes to support the public abstractions we consume.  Error reports will refer to these private classes.  Therefore, their names can be unfamiliar.

An easy way to gather our compass, and figure out what concrete representations map to which abstraction is to search for the class type definition.

Conveniently, other engineers have run a tool over all frameworks to generate the Objective-C class definitions and have stored them on GitHub\index{trademark!GitHub}.  They use the `class-dump`\index{command!class-dump} tool. This makes all private framework symbols for Objective-C easily searchable.

We can find the definition of `_isDispatchData`. @dispatchdata

```
/* Generated by RuntimeBrowser
   Image: /System/Library/Frameworks/Foundation.framework/
   Foundation
 */

@interface _NSDispatchData : NSData

+ (bool)supportsSecureCoding;

- (bool)_allowsDirectEncoding;
- (id)_createDispatchData;
- (bool)_isDispatchData;
- (Class)classForCoder;
- (id)copyWithZone:(struct _NSZone { }*)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)enumerateByteRangesUsingBlock:(id /* block */)arg1;
- (void)getBytes:(void*)arg1;
- (void)getBytes:(void*)arg1 length:(unsigned long long)arg2;
- (void)getBytes:(void*)arg1 range:(struct _NSRange
   { unsigned long long x1; unsigned long long x2; })arg2;
- (unsigned long long)hash;
- (id)initWithCoder:(id)arg1;
- (id)subdataWithRange:(struct _NSRange
  { unsigned long long x1; unsigned long long x2; })arg1;

@end
```

Similarly, we can look up `__NSCFConstantString`. @cfconstantstring

```
/* Generated by RuntimeBrowser
   Image: /System/Library/Frameworks/CoreFoundation.framework/
   CoreFoundation
 */

@interface __NSCFConstantString : __NSCFString

- (id)autorelease;
- (id)copyWithZone:(struct _NSZone { }*)arg1;
- (bool)isNSCFConstantString__;
- (oneway void)release;
- (id)retain;
- (unsigned long long)retainCount;

@end
```
