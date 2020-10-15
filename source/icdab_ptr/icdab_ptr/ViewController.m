//
//  ViewController.m
//  icdab_ptr
//
//  Created by Faisal Memon on 14/10/2020.
//

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
    
    NSLog(@"delta is 0x%lx clean_delta is 0x%tx\n", delta, clean_delta);
    
    ptrFn func = interestingJumpToFunc;
    func += clean_delta; // correct offset but neglects PAC component
    return func;
}

@end
