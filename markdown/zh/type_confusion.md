## 类型混淆

编译器在静态类型检查方面做得非常出色。但在动态推断类型时，可能会出现问题。而 配置文件在这方面尤为麻烦。 很容易为配置参数设置错误的类型

我们借助示例代码`icdab_nsdata`来说明我们的观点。@icdabgithub

### 从配置文件中获取 NSData 对象

思考以下示例代码

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

这段代码试图做两件事。 首先，它尝试从其配置中获取 `token`。我们假设在之前的运行中，用户已经以 `SomeKey`为键值保存了一个 `NSData` 格式的 `token`。

按照设计， `NSData`  对象可以处理所提供的数据是否为 `nil` 的情况。 因此，如果尚未保存数据，代码仍可正常运行。

 `token`可能只是一个简单的十六进制字符串，例如 `7893883873a705aec69e2942901f20d7b1e28dec`

上面的代码中有一个字符串 `stringProperty`，用于模拟以下情况：用户存存储的 `token` 是一个字符串而不是 `NSData`对象。
可能是它被手动复制并粘贴到用户的 `plist` 文件中。 如果 `initWithData` 方法参数为 `NSString`，那么就无法创建 `NSData` 对象。 然后发生了崩溃。

如果我们运行该代码，我们将得到以下崩溃报告，为了便于演示，将其截断：

### 反序列化崩溃报告

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

不幸的是，这种崩溃没有将更多的有用信息（例如“特定于应用程序的信息”）注入到崩溃报告中。

但是，我们确实会在系统日志（应用程序的控制台日志）中获取信息：

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

从这里我们可以看到问题是 `__NSCFConstantString` 无法响应 `_isDispatchData`  是因为 `NSString` 不是数据所提供的对象。

Apple SDK 具有私有实现类，以支持我们使用的公共对象。 错误报告将引用这些私有类。 因此，他们的名字可能不再令人熟悉。

可以通过一种简单的方法进行管理，并找出具体的表示映射到要搜索的类类型定义的哪个对象。

方便的是，其他工程师已经在框架上使用 `class-dump` 工具来生成所有 Objective-C 的类定义，并将它们存储在 GitHub上。他们使用 `class-dump`工具。这使得 Objective-C 的所有私有框架符号都很容易搜索到。

我们可以找到关于 `_isDispatchData`的定义。 @dispatchdata

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

同样，我们可以查找 `__NSCFConstantString`。 @cfconstantstring

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
