# Basic Concepts

## What is a crash?

An application crash is something the Operating Environment does to your application in response to what you have done in the Operating Environment that violates some _policy_ of the platform you are running on.

The policies of the operating environment are there to ensure security, data safety, performance, and privacy of the environment to the user.

The classic case is when your application tries to reference memory location 0 (deferences a `nil`).  That area of memory is set aside by the operating system because it indicates a programming error of not setting up an object properly leaving the default 0 where a non-zero value was expected.

When things go wrong, you don't always get a crash.  Only if it is Operating Environment policy that you crash.

Consider the example of getting the MAC address of your iPhone.

Prior to iOS 7, the MAC address was not considered a sensitive API.  So requesting the MAC address gave the real address.  The icdab_sample app attempts to do this.  However, the API was abused as a way of tracking the user - a privacy violation.  Therefore a policy was established from iOS 7.  Apple could have chosen to crash your app when the call to `sysctl` was made.
However, this is a general purpose low level call which can be used for valid purposes.  Therefore the policy set by iOS was to return you a fixed MAC address `02:00:00:00:00:00` whenever that was requested.

Now lets consider the case of taking a photo using the camera.

Introduced in iOS 10, when you want to access the Camera, a privacy sensitive feature, you need to define human readable text that is presented inside the system permission dialogue before access to the Camera is granted.
