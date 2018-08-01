//
//  main.m
//  icdab_thread_state
//
//  Created by Faisal Memon on 31/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/ucontext.h>
#include <pthread.h>

#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <mach/mach.h>


int main (int argc, char *argv[]) {
    kern_return_t kr;
    ucontext_t *uap;
    
    ucontext_t _uap_data;
    _STRUCT_MCONTEXT _mcontext_data;
    
    /* Perform basic initialization */
    uap = &_uap_data;
    uap->uc_mcontext = (void *) &_mcontext_data;
    
    /* Fetch the thread states */
    thread_t thread = pthread_mach_thread_np(pthread_self());
    mach_msg_type_number_t state_count;
    
    /* Sanity check */
#if defined(__i386__)
    // thread state
    state_count = x86_THREAD_STATE32_COUNT;
    kr = thread_get_state(thread, x86_THREAD_STATE32, (thread_state_t) &_mcontext_data.__ss, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86 thread state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_THREAD_STATE32\n");
    }
    
#ifndef NO_FLOAT_STATE
    // floating point state
    state_count = x86_FLOAT_STATE32_COUNT;
    kr = thread_get_state(thread, x86_FLOAT_STATE32, (thread_state_t) &_mcontext_data.__fs, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86 float state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_FLOAT_STATE32\n");
    }
#endif
    
    // exception state
    state_count = x86_EXCEPTION_STATE32_COUNT;
    kr = thread_get_state(thread, x86_EXCEPTION_STATE32, (thread_state_t) &_mcontext_data.__es, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86 exception state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_EXCEPTION_STATE32\n");
    }
    
    return 0;
#elif defined(__x86_64__)
    
    // thread state
    state_count = x86_THREAD_STATE64_COUNT;
    kr = thread_get_state(thread, x86_THREAD_STATE64, (thread_state_t) &_mcontext_data.__ss, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86-64 thread state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_THREAD_STATE64\n");
    }
    
    // floating point state
    state_count = x86_FLOAT_STATE64_COUNT;
    kr = thread_get_state(thread, x86_FLOAT_STATE64, (thread_state_t) &_mcontext_data.__fs, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86-64 float state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_FLOAT_STATE64\n");
    }
    
    // exception state
    state_count = x86_EXCEPTION_STATE64_COUNT;
    kr = thread_get_state(thread, x86_EXCEPTION_STATE64, (thread_state_t) &_mcontext_data.__es, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86-64 exception state failed with mach error: %d\n", kr);
        return 1;
    } else {
        printf("Got x86_EXCEPTION_STATE64\n");
    }
    
    return 0;
#else
#error Unsupported Architecture
#endif
}
