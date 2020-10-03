# Basic Concepts

## What is a crash?

Inside our computers is an Operating Environment.  This comprises one or more running Operating Systems, and Application Software.
Operating Systems and Application Software are distinguished by the fact that OS software runs with higher CPU privileges (kernel mode) than Application Software (user mode).

The basic conceptual model of our application software sitting on an Operating System which itself sits on hardware is normally sufficient.
However, modern computer systems have multiple co-operating subsystems.  For example, a MacBook Pro with TouchBar will have the main operating system, macOS, but also Bridge OS providing the TouchBar interface, disk encryption and "Hey Siri!" support.  The multimedia and networking chips in our computers are advanced components and can have their own real-time Operating Systems running on them.  Our Mac software will be just one of many applications running on macOS.

An application crash\index{crash!application crash} is something the Operating Environment does to our application in response to what we have done (or failed to do) in the Operating Environment that violates some _policy_ of the platform we are running on.

When the Operating System detects a problem in the Operating System, it can crash itself.  This is called a kernel panic\index{crash!kernel panic}.

## Operating Environment Policies

The policies\index{policy} of the operating environment are there to ensure security, data safety, performance, and privacy of the environment to the user.

### Nil Handling Example

Newcomers to the Apple\index{trademark!Apple} ecosystem are often surprised to learn that Objective-C\index{trademark!Objective-C} allows us to message a nil object.  It silently ignores the failed dispatch\index{nil dispatch}.  For example,
the following method runs ok.

```
- (void)nilDispatchDoesNothing
{
    NSString *error = NULL;
    assert([error length] == 0);
}
```

The Objective-C runtime authors made a judgement call, and decided it was better for an application to ignore such problems.


However if we dereference a C pointer\index{NULL dereference} we get a crash.
```
void nullDereferenceCrash() {
    char *nullPointer = NULL;
    assert(strlen(nullPointer) == 0);
}
```

The authors of the operating system have setup the system so access to this and other low memory addresses causes the hardware to trap on this illegal access\index{illegal access} and abort\index{abort} our program.

This area of memory is set aside by the operating system because it indicates a programming error of not setting up an object or data structure properly.

When things go wrong, we don't always get a crash.  Only if it is Operating Environment policy then we get a crash.

### MAC Address Example

Consider the example of getting the MAC address\index{MAC address} of our iPhone.  The Media Access Control (MAC) address is a unique code allocated to network cards to allow machines to talk to each other without duplication at the Data Link\index{network!Data Link Layer} layer of the communication stack.

Prior to iOS\index{trademark!iOS} 7\index{iOS!iOS 7}, the MAC address was not considered a sensitive API\index{API!sensitive}.  So requesting the MAC address using the `sysctl`\index{command!sysctl} API gave the real address.  To see this in action, see the `icdab_sample` app @icdabgithub.

Unfortunately, the API was abused as a way of tracking the user - a privacy violation\index{violation!privacy}.  Therefore, Apple introduced a policy from iOS 7 where they would return a fixed MAC address always.

Apple could have chosen to crash our app when any call to `sysctl` was made.  However, `sysctl` is a general-purpose low-level call which can be used for other valid purposes.  Therefore the policy set by iOS was to return a fixed MAC address `02:00:00:00:00:00`\index{02:00:00:00:00:00} whenever that was requested.

### Camera Example

Now lets consider the case of taking a photo using the camera.

Introduced in iOS 10\index{iOS!iOS 10}, when we want to access the Camera, a privacy sensitive feature, we need to define human readable text that is presented inside the system permission dialogue before access to the Camera is granted.

If we don't define the text in our `Info.plist`\index{Info.plist} for `NSCameraUsageDescription`\index{API!camera} we still see the following code evaluating true and then attempting to present the image picker.

```
func handlePickerButtonPressed() {
    if UIImagePickerController.isCameraDeviceAvailable(.front) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion:
 nil)
    }
}
```

However when we run the code, via Xcode 12.2, we see a crash with a descriptive console message:

```
2020-10-03 17:59:10.458176+0100 icdab_camera[6908:6483411]
 [access] This app has crashed because it attempted to access
 privacy-sensitive data without a usage description.  The app's
 Info.plist must contain an NSCameraUsageDescription key with a
 string value explaining to the user how the app uses this data.
Message from debugger: Terminated due to signal 9
```

### Lessons Learnt

Note the contrast here.  In both cases there was a privacy sensitive API\index{API!privacy}.  However, in the camera case, Apple chose a policy of crashing our app instead of giving a warning, allowing a boilerplate standard explanation dialog, or returning a `false` value to indicate the source type was not available.

This seems like a harsh design choice.  The API in question originates from iOS 4.0\index{iOS!iOS 4}.  When Xcode 10.0 was introduced (this delivers the iOS 12\index{iOS!iOS 12} SDK) the behavior of the API changed.  It returns `false` if the camera is not available due to a missing privacy string in the application `Info.plist`  However by, Xcode 12.x (this delivers iOS 14.x\index{iOS!iOS 14} SDK) logic has changed back to to the original logic of returning `true`.

This underlies the point about there being two entities involved, the program and the operating environment\index{operating environment} (which includes its policies).  Having correct source code does not guarantee crash free running.  When we see a crash we need to think about the operating environment as much as the code itself.

## Application policies

The application we are writing can also request a crash.  This is typically done via `assert`\index{assert} calls in our code.  These calls ask the Operating Environment to terminate our app if any `assert` has failed.  The Operating Environment then aborts our app.
In the Crash Report we get a:

`Exception Type:  EXC_CRASH (SIGABRT)`\index{signal!SIGABRT}

to indicate it was the application that requested the crash in the first place.

### When should we crash?

We can apply similar standards as the Operating Environment for our crash policy.

If our code detects a data integrity issue\index{crash!data integrity}, we could crash to prevent further data corruption\index{crash!data corruption}.

### When should we not crash?

If the problems have resulted directly from some
IO problem (file or network access for example) or some human input problem (such as a bad date value) then we should not crash.  

It's our job as the application developer to shield the lower level parts of the system from unpredictability present in the real world.  Such problems are better dealt with by logging, error handling, user alerts, and IO retries.

## Engineering Guidance

How should we guard against the privacy problems described above?

The thing to keep in mind is that any code that touches upon the policies the Operating Environment has guards for is a good candidate for automated testing.

In the `icdab_sample` project we have created Unit tests and UI tests.

Test cases always feel over-the-top when applied to trivial programs.  But consider a large program that has an extensive `Info.plist`\index{Info.plist} file.  A new version of the app is called for so another `Info.plist` is created.  Then keeping the privilege settings in sync between the different build targets becomes an issue.  The UI test code shown here which merely launches the camera can catch such problems easily so has practical business value.  

Similarly, if our app has a lot of low-level code and then is ported\index{software!porting} from iOS to tvOS\index{operating system!tvOS}\index{trademark!tvOS}, for example, how much of that OS-sensitive code is still applicable?

Unit testing\index{testing!unit} a top level function comprehensively for different design concerns can pay off the effort invested in it before delving deeper and unit testing the underlying helper function calls in our code base.  It's a strategic play allowing us to get some confidence in our application and early feedback on problem areas when porting to other platforms within the Apple Ecosystem (and beyond).

### Unit Testing the MAC Address

The code to get the MAC address is not trivial.  Therefore it merits some level of testing.

Here is a snippet from the Unit tests:

```
    func getFirstOctectAsInt(_ macAddress: String) -> Int {
        let firstOctect = macAddress.split(separator: ":").first!
        let firstOctectAsNumber = Int(String(firstOctect))!
        return firstOctectAsNumber
    }

    func testMacAddressNotNil() {
        let macAddress = MacAddress().getMacAddress()
        XCTAssertNotNil(macAddress)
    }

    func testMacAddressIsNotRandom() {
        let macAddressFirst = MacAddress().getMacAddress()
        let macAddressSecond = MacAddress().getMacAddress()
        XCTAssert(macAddressFirst == macAddressSecond)
    }

    func testMacAddressIsUnicast() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 1))
    }

    func testMacAddressIsGloballyUnique() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 2))
    }
```

In fact, the last test fails because the OS returns a local address.

### UI Testing Camera access

For testing camera access, we have written a simple UI test case\index{testing!UI} which just presses the __Choose Picture__ button.

```
func testTakePhoto() throws {
    let app = XCUIApplication()
    app.launch()
    app.buttons["Choose Picture"].tap()
}
```

This UI test code caused an immediate crash.
