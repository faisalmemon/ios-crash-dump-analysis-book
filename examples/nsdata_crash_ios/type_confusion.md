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
Incident Identifier: 83DD2BB9-9C75-4BE5-98E5-FD3FD9CCC604
CrashReporter Key:   d3e622273dd1296e8599964c99f70e07d25c8ddc
Hardware Model:      iPhone12,1
Process:             icdab_nsdata [842]
Path:               
 /private/var/containers/Bundle/Application/93CF6ABD-2876-4DEA-9B
4D-0123C5CD8AE2/icdab_nsdata.app/icdab_nsdata
Identifier:          www.perivalebluebell.icdab-nsdata
Version:             1 (1.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           www.perivalebluebell.icdab-nsdata [1021]

Date/Time:           2020-10-12 14:14:37.8842 +0100
Launch Time:         2020-10-12 14:14:37.7953 +0100
OS Version:          iPhone OS 14.2 (18B5061e)
Release Type:        Beta
Baseband Version:    2.02.00
Report Version:      104

Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Triggered by Thread:  0

Application Specific Information:
abort() called

Last Exception Backtrace:
0   CoreFoundation                      0x1aa7cc904
 __exceptionPreprocess + 220
1   libobjc.A.dylib                     0x1bf1fbc50
 objc_exception_throw + 59
2   CoreFoundation                      0x1aa6d3b0c -[NSObject+
 183052 (NSObject) doesNotRecognizeSelector:] + 143
3   CoreFoundation                      0x1aa7cf4d0
 ___forwarding___ + 1443
4   CoreFoundation                      0x1aa7d17d0
 _CF_forwarding_prep_0 + 95
5   Foundation                          0x1aba6eabc
 -[_NSPlaceholderData initWithData:] + 131
6   icdab_nsdata                        0x10061e61c -[AppDelegate
 application:didFinishLaunchingWithOptions:] + 26140
 (AppDelegate.m:26)
7   UIKitCore                           0x1ad170604
 -[UIApplication
 _handleDelegateCallbacksWithOptions:isSuspended:restoreState:] +
 359
.
.
.
```


Furthermore, we get the following information in the system log (console log of the app):

```
2020-10-12 14:29:55.024195+0100 icdab_nsdata[881:101507] 
My data is {length = 0, bytes = 0x} - ok since we can handle a
 nil
2020-10-12 14:29:55.024276+0100 icdab_nsdata[881:101507] 
-[__NSCFConstantString _isDispatchData]: unrecognized selector
 sent to instance 0x1042480a8
2020-10-12 14:29:55.024403+0100 icdab_nsdata[881:101507] 
*** Terminating app due to uncaught exception
 'NSInvalidArgumentException', reason: '-[__NSCFConstantString
 _isDispatchData]: unrecognized selector sent to instance
 0x1042480a8'
*** First throw call stack:
(0x1aa7cc904 0x1bf1fbc50 0x1aa6d3b0c 0x1aa7cf4d0 0x1aa7d17d0
 0x1aba6eabc 0x10424661c 0x1ad170604 0x1ad17266c 0x1ad1780c8
 0x1ac7d0e28 0x1acd3e0ac 0x1ac7d19c0 0x1ac7d13c8 0x1ac7d17d0
 0x1ac7d100c 0x1ac7d9558 0x1acc4ad90 0x1acd567d4 0x1ac7d9250
 0x1ac600fac 0x1ac5ff920 0x1ac600bd4 0x1ad176268 0x1acc745bc
 0x1b9fa4afc 0x1b9fd0444 0x1b9fb3be0 0x1b9fd0108 0x104559780
 0x10455d0c0 0x1b9ff8990 0x1b9ff8620 0x1b9ff8b74 0x1aa7487f8
 0x1aa7486f4 0x1aa7479ec 0x1aa741b18 0x1aa7412a8 0x1c1ccc784
 0x1ad1742c4 0x1ad179b38 0x1042464b4 0x1aa4016c0)
libc++abi.dylib: terminating with uncaught exception of type
 NSException
*** Terminating app due to uncaught exception
 'NSInvalidArgumentException', reason: '-[__NSCFConstantString
 _isDispatchData]: unrecognized selector sent to instance
 0x1042480a8'
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
