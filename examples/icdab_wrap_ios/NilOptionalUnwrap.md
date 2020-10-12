## Unwrapping a Nil Optional

The Swift Programming Language is a significant step forward towards writing safe-by-default code.

A central concept within Swift is explicitly handling optionality\index{Swift!optional}.  In type declarations, a trailing `?` indicates the value could be absent, as represented by `nil`.  These types need explicit unwrapping to access the value they store.

When a value is not available at object initialization time, but later in the lifecycle of the object, then a trailing `!` is used for types that hold the value.  This means the value can be treated in code without the need for explicit unwrapping\index{Swift!explicit unwrapping}.  It is called an implicitly unwrapped optional.
Note, from Swift 4.2, at the implementation level, it is an optional, with an annotation that indicates it can be used without explicit unwrapping.

We use the `icdab_wrap` example program to demonstrate crashes that can arise through the faulty use of optionals. @icdabgithub

### iOS UIKit Outlets

It is a standard paradigm to use a storyboard to declare the User Interface, and associate `UIViews` with `UIViewControllers`.

When the user interface updates, such as when launching our app, or performing a segue between scenes, the storyboard instantiates
supporting `UIViewControllers` and sets up fields in our `UIViewController` objects to `UIViews` that have been created.

We will have a field declaration automatically generated when we link the storyboard\index{Xcode!storyboard} to our controller code such as:
```
@IBOutlet weak var planetImageOutlet: UIImageView!
```

### Ownership rules

If we did not explicitly create an object, and we did not have ownership passed to us, we should not shorten the lifecycle\index{object!lifecycle} of the object we are passed.  

In our `icdab_wrap` example we have a parent screen, and we can tap into a child screen that has a large image of Pluto.  
The image is downloaded from the Internet.  When that screen is left, and the original screen is visited the code tries to reduce memory by letting go of the memory associated with the image.

There is a separate argument about whether such an image clean up strategy is helpful or desirable.  A profiling\index{software!profiling} tool should be used to inform us when to try to economize our memory footprint.

Our code has a bug:
```
override func viewWillDisappear(_ animated: Bool) {
        planetImageOutlet = nil
        // BUG; should be planetImageOutlet.image = nil
    }
```

Instead of setting the image of the image view to nil, we set the image view itself to `nil`

This means when we re-visit the Pluto scene, we crash when trying to store the downloaded image since our `planetImageOutlet` is `nil`

```
func imageDownloaded(_ image: UIImage) {
        self.planetImageOutlet.image = image
    }
```

This code will crash, since it implicitly unwraps the optional, which has been set to `nil`.

### Crash Report for unwrapped nil optionals

When we get a crash from the swift runtime force unwrapping\index{Swift!force unwrapping optional} a nil optional we see:
```
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x00000001ae3bbbb4
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
Terminating Process: exc handler [623]
Triggered by Thread:  0
```

The item to notice is the Exception Type, `EXC_BREAKPOINT (SIGTRAP)`\index{signal!SIGTRAP}

We see that the runtime environment raised a breakpoint exception because it saw a problem.
This is identified by seeing the swift core library at the top of the stack.

```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libswiftCore.dylib                  0x00000001ae3bbbb4 closure #1 in closure #1 in closure #1 in _assertionFailure+ 228276 (_:_:file:line:flags:) + 384
1   libswiftCore.dylib                  0x00000001ae3bbbb4 closure #1 in closure #1 in closure #1 in _assertionFailure+ 228276 (_:_:file:line:flags:) + 384
2   libswiftCore.dylib                  0x00000001ae3bb090 _assertionFailure+ 225424 (_:_:file:line:flags:) + 472
3   icdab_wrap                          0x00000001046a7da4 PlanetViewController.imageDownloaded(_:) + 48548 (PlanetViewController.swift:0)
```

#### Uninitialized pointers

Older versions of the Swift Runtime, perhaps through the underlying C++ compiler technology,  would place a special value `0xbaddc0dedeadbead`\index{0xbaddc0dedeadbead} to indicate an uninitialized pointer, such as in the following register dump.

```
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000100ecc100   x1: 0x00000001c005b9f0   
    x2: 0x0000000000000008
       x3: 0x0000000183a4906c
    x4: 0x0000000000000080   x5: 0x0000000000000020   
    x6: 0x0048000004210103
       x7: 0x00000000000010ff
    x8: 0x00000001c00577f0   x9: 0x0000000000000000  
    x10: 0x0000000000000002
      x11: 0xbaddc0dedeadbead
   x12: 0x0000000000000001  x13: 0x0000000000000002  
   x14: 0x0000000000000000
     x15: 0x000a65756c617620
   x16: 0x0000000183b9b8cc  x17: 0x0000000000000000  
   x18: 0x0000000000000000
     x19: 0x0000000000000000
   x20: 0x0000000000000002  x21: 0x0000000000000039  
   x22: 0x0000000100d3f3d0
     x23: 0x0000000000000002
   x24: 0x000000000000000b  x25: 0x0000000100d3f40a  
   x26: 0x0000000000000014
     x27: 0x0000000000000000
   x28: 0x0000000002ffffff   fp: 0x000000016f0ca8e0   
   lr: 0x00000001011f7ff8
    sp: 0x000000016f0ca8a0   pc: 0x00000001011f7ff8
    cpsr: 0x60000000
```

However, modern register dumps, and our unwrapped Nil case, show:
```
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000104708000   x1: 0x00000002820a3800   x2: 0x0000000000000007   x3: 0x00000001ba034cf0
    x4: 0x00000000000062dc   x5: 0x0000000000000013   x6: 0x0000000000000020   x7: 0x0000000000000001
    x8: 0x000000000000007f   x9: 0x0000000000000071  x10: 0x00000000000007fb  x11: 0x00000000000007fd
   x12: 0x0000000000000001  x13: 0x00000000c6609046  x14: 0x00000000c6809800  x15: 0x0000000000000013
   x16: 0x0000000080000000  x17: 0x0000000046800000  x18: 0x0000000000000000  x19: 0x000000000000002d
   x20: 0x0000000000000000  x21: 0x0000000000000002  x22: 0x0000000000000002  x23: 0x0000000000000044
   x24: 0x00000001046ab200  x25: 0x00000001047f79a0  x26: 0x00000000000020ff  x27: 0x0000000000000114
   x28: 0x00000001046ab19a   fp: 0x000000016b762830   lr: 0x465a8e01ae3bbbb4
    sp: 0x000000016b762810   pc: 0x00000001ae3bbbb4 cpsr: 0x60000000
   esr: 0xf2000001  Address size fault
```
