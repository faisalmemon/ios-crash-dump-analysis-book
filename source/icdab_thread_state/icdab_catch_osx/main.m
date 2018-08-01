//
//  main.m
//  icdab_catch_osx
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/ucontext.h>
#include <pthread.h>
#include <signal.h>
#define   SUSPEND_SIGNAL  SIGUSR1
#define   RESUME_SIGNAL   SIGUSR2

#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <mach/mach.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        if (argc != 2) {
            printf("Usage: icdab_catch pthread_number\n");
            return 0;
        }
        
        uint64_t pthread_number = atoll(argv[1]);
        struct _opaque_pthread_t * target_thread = (struct _opaque_pthread_t * ) pthread_number;
        pthread_kill(target_thread, SUSPEND_SIGNAL);
        
        mach_msg_type_number_t state_count;
        kern_return_t kr;
        ucontext_t *uap;
        
        ucontext_t _uap_data;
        _STRUCT_MCONTEXT _mcontext_data;
        
        /* Perform basic initialization */
        uap = &_uap_data;
        uap->uc_mcontext = (void *) &_mcontext_data;
        
        state_count = x86_THREAD_STATE64_COUNT;
        kr = thread_get_state((thread_act_t)pthread_number, x86_THREAD_STATE64, (thread_state_t) &_mcontext_data.__ss, &state_count);
        if (kr != KERN_SUCCESS) {
            printf("Fetch of x86-64 thread state failed with mach error: %x\n", kr);
            return 1;
        } else {
            printf("Got x86_THREAD_STATE64\n");
        }
    }
    return 0;
}
