# Pointer Authentication

In this chapter we shall examine Pointer Authentication, and related crashes.

Devices using the Apple A12\index{CPU!A12} chip, or later, utilise a security feature known as _Pointer Authentication_\index{Pointer Authentication} as part of the ARMv8.3-A\index{ARM!v8.3-A} architecture.  For example, iPhone XS\index{trademark!iPhone XS}, iPhone XS Max\index{trademark!iPhone XS Max}, and iPhone XR\index{trademark!iPhone XR} use the A12 chip.  The basic idea is that there are unused bits in a 64-bit pointer because it can already address such a vast range of addresses, only 40 bits are allocated to such purposes. @iospac  The remaining bits can therefore be used to store a hash value computed after combining the intended pointer address with a context value and a secret key.  Then if the pointer address were to be changed, either because of a bug or malicious action, the pointer would be known to be invalid and would eventually cause a `SIGSEGV` if it were to be used to change the control flow of a program.

In actual fact, Pointer Authentication is used in a number of scenarios, such as ensuring C++ virtual dispatch tables have not been tampered with.  But we shall look only at the simple case of an incorrectly manipulated jump address.

Pointer Authentication is enabled by Apple in the kernel on Devices using the A12 chip, and newer.  For user space code, Pointer Authentication is an opt-in feature.  It can be enabled via the Build Settings for the project as seen here in Figure _Enable Pointer Authentication_ for `icdab_ptr`  @icdabgithub  We add Architecture `arm64e` to the Architectures setting.

![Enable Pointer Authentication](screenshots/enable_ptr_auth.png)


## Manipulating Pointers

Let us consider the following program which manipulates pointers, albeit in an artificial way, to expose some of the ideas behind pointer authentication.

```
#import "ViewController.h"

#include "ptrauth.h"

@interface ViewController ()

@end

@implementation ViewController

typedef void(*ptrFn)(void);

static void interestingJumpToFunc(void) {
    NSLog(@"Simple interestingJumpToFunc\n");
}

// this function's address is where we will be jumping to
static void nextInterestingJumpToFunc(void) {
    NSLog(@"Simple nextInterestingJumpToFunc\n");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ptrFn result = [self generatePtrToFn];
    NSLog(@"ptrFn result is %p\n", result);
    result(); // will crash; deferences a pointer with a bad PAC
}

- (ptrFn)generatePtrToFn {
    uintptr_t a1 = (uintptr_t)interestingJumpToFunc;
    uintptr_t a2 = (uintptr_t)nextInterestingJumpToFunc;
    NSLog(@"ptr addresses as uintptr_t are 0x%lx 0x%lx\n",
          a1, a2);
    ptrdiff_t delta = a2 - a1;
    ptrdiff_t clean_delta =
    ptrauth_strip(&nextInterestingJumpToFunc,
                  ptrauth_key_asia) -
    ptrauth_strip(&interestingJumpToFunc,
                  ptrauth_key_asia);
    
    NSLog(@"delta is 0x%lx clean_delta is 0x%tx\n", delta,
 clean_delta);
    
    ptrFn func = interestingJumpToFunc;
    func += clean_delta; // correct offset but neglects PAC
 component
    return func;
}
```

If we run the above program, we get a crash.  The logging output of the program is:

```
ptr addresses as uintptr_t are 0x2946180102c55dd8
 0x22b810102c55df8
delta is 0xd8e5690000000020 clean_delta is 0x20
ptrFn result is 0x2946180102c55df8
```

We see that when a pointer to function, `interestingJumpToFunc`, is obtained, and then stored in an integer big enough to hold a pointer address, we get a large value, `0x2946180102c55dd8`.  That is because the top 24 bits of the address are the Pointer Authentication Code (PAC)\index{Pointer Authentication Code}\index{PAC}.  The PAC in this instance is `0x294618` and the effective pointer is `0x0102c55dd8`.

The next pointer, which is physically adjacent, `nextInterestingJumpToFunc` is `0x22b810102c55df8`; clearly it shares a similar effective address, `0x0102c55df8`, but has an entirely different PAC, `0x22b81`.

When we compute the delta between the pointers, we will clearly get a nonsense address because of the PAC portion of the value of the pointers.  In order to correctly calculate the delta between the effective address of the pointers, we need to use the `ptrauth_strip` utility function.  This is implemented as a built-in macro assembly instruction.

After macro preprocessing, the code is:

```
ptrdiff_t clean_delta =
    __builtin_ptrauth_strip(&nextInterestingJumpToFunc,
 ptrauth_key_asia) -

    __builtin_ptrauth_strip(&interestingJumpToFunc,
 ptrauth_key_asia);
```

The assembly instructions produced are of the form:
```
	xpaci	x9
```
when the `__builtin_ptrauth_strip` strip function is used.  This removes the PAC from a register, in this case `x9`.

The benefit of using the strip functions was that we are able to correctly determine the distance between the two functions of interest.  It is `0x20`.  Our function `generatePtrToFn` essentially just adds the delta onto the address of `interestingJumpToFunc` to calculate the address of `nextInterestingJumpToFunc`, but it does it erroneously; it leaves the PAC for `interestingJumpToFunc` in the address it has calculated.

Notice none of this pointer manipulation causes a crash.  The time of checking the pointer is when it is used for changing the link register\index{register!link}.  That is, when we act upon the pointer value to change the control flow of the program.

In the function `viewDidLoad()` when have the code 
```
result(); // will crash; deferences a pointer with a bad PAC
```

The pointer used is our bad pointer `0x2946180102c55df8`.  The bad pointer is detected by the assembly instruction

```
blraaz	x8
```

This is Branch with Link to Register, with pointer authentication using Instruction Key A.

Note that when we were stripping the pointer, we used `ptrauth_key_asia` to remove Instruction Key A.  However, we do not have access to the special values needed to do the reverse, to sign a pointer with Instruction Key A with the appropriate "salt" values to get a contextually correct signed pointer.

Now that we have examined our faulty code, let us look what happens when it crashes.

