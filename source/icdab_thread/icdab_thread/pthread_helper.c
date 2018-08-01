//
//  pthread_helper.c
//  icdab_thread
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#include "pthread_helper.h"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

/* A task that takes some time to complete. The id identifies distinct
 tasks for printed messages. */
void *task(long id) {
    printf("Task %ld started\n", id);
    int i;
    double result = 0.0;
    for (i = 0; i < 100000000; i++) {
        result = result + sin(i) * tan(i);
        printf("intermediate result %f ", result);
    }
    printf("Task %ld completed with result %e\n", id, result);
    return NULL;
}

/* Same as 'task', but meant to be called from different threads. */
void *threaded_task(long t) {
    long id = (long) t;
    printf("Thread %ld started\n", id);
    task(id);
    printf("Thread %ld done\n", id);
    pthread_exit(0);
}

/* Run 'task' num_tasks times serially. */
void *serial(int num_tasks) {
    int i;
    for (i = 0; i < num_tasks; i++) {
        task(i);
    }
    pthread_exit(NULL);
}



#import <pthread.h>
#import <mach/thread_act.h>

// These two functions are declared in mach/thread_policy.h, but are commented out.
// They are documented here: https://developer.apple.com/library/mac/#releasenotes/Performance/RN-AffinityAPI/_index.html
kern_return_t    thread_policy_set(
                                   thread_t            thread,
                                   thread_policy_flavor_t        flavor,
                                   thread_policy_t            policy_info,
                                   mach_msg_type_number_t        count);

kern_return_t    thread_policy_get(
                                   thread_t            thread,
                                   thread_policy_flavor_t        flavor,
                                   thread_policy_t            policy_info,
                                   mach_msg_type_number_t        *count,
                                   boolean_t            *get_default);


void * thread_routine_1() {
    threaded_task(500);
    return NULL;
}

void * thread_routine_2() {
    threaded_task(1000);
    return NULL;
}

void start_threads() {
    
    kern_return_t kr;
    mach_msg_type_number_t state_count = x86_THREAD_STATE64_COUNT;

    pthread_t thread1;
    if(pthread_create_suspended_np(&thread1, NULL, thread_routine_1, NULL) != 0) abort();
    mach_port_t mach_thread1 = pthread_mach_thread_np(thread1);
    thread_affinity_policy_data_t policyData1 = { 1 };
    thread_policy_set(mach_thread1, THREAD_AFFINITY_POLICY, (thread_policy_t)&policyData1, 1);
    
    x86_thread_state_t x86_state;
    kr = thread_get_state(mach_thread1, x86_THREAD_STATE64, (thread_state_t) &x86_state, &state_count);
    if (kr != KERN_SUCCESS) {
        printf("Fetch of x86 thread state failed with Mach error: %d", kr);
        return;
    }
    x86_state.uts.ts64.__rip = 33;

    kr = thread_set_state(mach_thread1, x86_THREAD_STATE64, (thread_state_t) &x86_state, state_count);
    if (kr != KERN_SUCCESS) {
        printf("set state thread 1 failed with Mach error: %d", kr);
        return;
    }
    kr = thread_resume(mach_thread1);
    if (kr != KERN_SUCCESS) {
        printf("resume thread 1 failed with Mach error: %d", kr);
        return;
    }
    x86_state.uts.ts64.__rip = 44;
    kr = thread_set_state(mach_thread1, x86_THREAD_STATE64, (thread_state_t) &x86_state, state_count);
    if (kr != KERN_SUCCESS) {
        printf("set state thread 1 rip 44 failed with Mach error: %d", kr);
        return;
    }
    sleep(5);
    abort();
}
