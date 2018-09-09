//
//  Crash.m
//  icdab_edge
//
//  Created by Faisal Memon on 09/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

/*
 * Copyright (c) 2014 HockeyApp, Bit Stadium GmbH.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "Crash.h"

#import <Foundation/Foundation.h>

#import <malloc/malloc.h>
#import <mach/mach.h>

@implementation Crash: NSObject

- (void)overshootAllocated
{
    uint8_t *memory = malloc(16);
    for (int i = 0; i < 16 + 1; i++) {
        *(memory + i) = 0xff;
    }
}

- (void)corruptMalloc {
    /* Smash the heap, and keep smashing it until we eventually hit something non-writable, or trigger
     * a malloc error (e.g., in NSLog). */
    
    
    /*
     Diagnose with Guard Malloc on Simulator.
     */
    uint8_t *memory = malloc(10);
    while (true) {
        NSLog(@"Smashing [%p - %p]", memory, memory + PAGE_SIZE);
        memset((void *) trunc_page((vm_address_t)memory), 0xAB, PAGE_SIZE);
        memory += PAGE_SIZE;
    }
}

@end
