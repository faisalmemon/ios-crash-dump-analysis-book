# Basic Concepts

## What is a crash?

An application crash is something the Operating Environment does to your application in response to what you have done (or failed to do) in the Operating Environment that violates some _policy_ of the platform you are running on.

## Operating Environment Policies

The policies of the operating environment are there to ensure security, data safety, performance, and privacy of the environment to the user.

### Nil Handling Example

Newcomers to the Apple ecosystem are often surprised to learn that Objective-C allows you to message a nil object.  It silently ignores the failed dispatch.  For example
the following method runs ok.

```
- (void)nilDispatchDoesNothing
{
    NSString *error = NULL;
    assert([error length] == 0);
}
```

The Objective-C runtime authors made a judgement call, and decided it was better for an application to ignore such problems.


However if you deference a C pointer you get a crash.
```
void nullDereferenceCrash() {
    char *nullPointer = NULL;
    assert(strlen(nullPointer) == 0);
}
```

The authors of the operating system have setup the system so access to this and other low memory addresses causes the hardware to trap on this illegal access and abort your program.

This area of memory is set aside by the operating system because it indicates a programming error of not setting up an object or data structure properly.

When things go wrong, you don't always get a crash.  Only if it is Operating Environment policy then you get a crash.

### MAC Address Example

Consider the example of getting the MAC address of your iPhone.  The Media Access Control (MAC) address is a unique code allocated to network cards to allow machines to talk to each other without duplication at the Data Link layer of the communication stack.

Prior to iOS 7, the MAC address was not considered a sensitive API.  So requesting the MAC address gave the real address.  The `icdab_sample` app attempts to do this.  See @icdabgithub. However, the API was abused as a way of tracking the user - a privacy violation.  Therefore a policy was established from iOS 7.  Apple could have chosen to crash your app when the call to `sysctl` was made in order to get the MAC address.
However, this is a general purpose low level call which can be used for other valid purposes.  Therefore the policy set by iOS was to return you a fixed MAC address `02:00:00:00:00:00` whenever that was requested.

### Camera Example

Now lets consider the case of taking a photo using the camera.

Introduced in iOS 10, when you want to access the Camera, a privacy sensitive feature, you need to define human readable text that is presented inside the system permission dialogue before access to the Camera is granted.

If you don't define the text in your `Info.plist` for `NSCameraUsageDescription` you still the following code returning true and then attempting to present the image picker.

```
if UIImagePickerController
            .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
```

However when you run the code you see a crash and descriptive console message:

```
2018-07-10 20:09:21.549897+0100 icdab_sample[1775:15601294]
 [access] This app has crashed because it attempted to access
  privacy-sensitive data without a usage description.  
  The app's Info.plist must contain an NSCameraUsageDescription
   key with a string value explaining to the user how the app
   uses this data.
Message from debugger: Terminated due to signal 9
```

### Lessons Learnt

Note the contrast here.  In both cases there was a privacy sensitive API.  But in the camera case, Apple chose a policy of crashing your app instead of giving a warning, allowing a boilerplate standard explanation dialog, or returning a `false` value to indicate the source type was not available.

This underlies the point about there being two entities involved, the program and the operating environment (which includes its policies).  Having correct source code does not guarantee crash free running.  And when we see a crash we need to think about the operating environment as much as the code itself.

## Application policies

It's not just the Operating Environment that can define a policy for when to crash.
The application you are writing can also request a crash.  This is typically done via `assert` calls in your code.  These calls ask the Operating Environment to terminate your app if the assert has failed.  The Operating Environment then aborts your app.
In the crash report you get a

`Exception Type:  EXC_CRASH (SIGABRT)`

to indicate it was the application that requested the crash in the first place.

### When should you crash?

You can apply similar standards as the Operating Environment for your crash policy.

If your code detects a data integrity issue, you could crash to prevent further data corruption.

### When should you not crash?

If the problems have resulted directly from some
IO problem (file or network access for example) or some human input problem (such as a bad date value) then you should not crash.  

It's your job as the application developer to shield the lower level parts of the system from unpredictability present in the real world.  Such problems are better dealt with by logging, error handling, user alerts, and IO retries.

## Engineering Guidance

How should we guard against the privacy problems described above?

The thing to keep in mind is that any code that touches upon the policies the Operating Environment has guards for is a good candidate for automated testing.

In the `icdab_sample` project we have created Unit tests and UI tests.

Test cases always feel over-the-top when applied to trivial programs.  But consider a large program which has an extensive `Info.plist` file.  A new version of the app is called for so another `Info.plist` is created.  Then keeping the privilege settings in sync between the different build targets becomes an issue.  The UI test code shown here which merely launches the camera can catch such problems easily so has practical business value.  

Similarly if your app has a lot of low level code and then is ported from iOS to tvOS for example, how much of that OS-sensitive code is still applicable?

Unit testing a top level function comprehensively for different design concerns can pay off the effort invested in it before delving deeper and unit testing the underlying helper function calls in your code base.  Its a strategic play allowing you to get some confidence in your application and early feedback on problem areas when porting to other platforms within the Apple Ecosystem (and beyond).

### Unit Testing the MAC Address

The code to get the MAC address is not trivial.  So it merits some level of testing.

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

For testing camera access we have written a simple UI test case which just presses the Take Photo button (by means of an accessibility identifier `takePhotoButton`)

```
func testTakePhoto() {
    let app = XCUIApplication()
    app.buttons["takePhotoButton"].tap()
}
```

This UI test code caused an immediate crash.
