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
#import <mach/thread_act.h>
#include <sys/types.h>

/*
 The purpose of this program is to try to do a thread_set_state from another
 process, and then crash, so that we can produce a crash dump that shows the
 thread crashed, but in its history, had someone externally affect it.
 */

/* A task that takes some time to complete. The id identifies distinct
 tasks for printed messages. */
void *task(long id) {
    printf("Task %ld started\n", id);
    int i;
    double result = 0.0;
    for (i = 0; i < 100000000; i++) {
        result = result + sin(i) * tan(i);
        //printf("intermediate result %f ", result);
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

void * thread_routine_1() {
    threaded_task(500);
    return NULL;
}

/*
 Task related articles:
 https://knight.sc/reverse%20engineering/2019/04/15/detecting-task-modifications.html
 https://bazad.github.io/2018/10/bypassing-platform-binary-task-threads/
 */


int set_thread_state_from_another_process(mach_port_t port, thread_state_t revised_state, mach_msg_type_number_t state_count) {
    pid_t processId;
    if ((processId = fork()) == 0) {
        printf("Spawned child process id %ld\n", (long)processId);
        kern_return_t kr;
        kr = thread_set_state(port, x86_THREAD_STATE64, revised_state, state_count);
        if (kr != KERN_SUCCESS) {
            printf("set state thread 1 failed with Mach error: 0x%x\n", kr);
            return EXIT_FAILURE;
        }
    } else if (processId < 0) {
        perror("fork error");
    } else {
        return EXIT_SUCCESS;
    }
    return EXIT_FAILURE;
}

kern_return_t
get_debug_state(mach_port_t port, struct x86_debug_state* result, mach_msg_type_number_t* state_count) {
    kern_return_t kr;
    kr = thread_get_state(port, x86_DEBUG_STATE, (thread_state_t)result, state_count);
    if (kr != KERN_SUCCESS) {
        printf("Getting x86 thread debug state failed with Mach error: 0x%x\n", kr);
    }
    return kr;
}

kern_return_t
set_debug_state(mach_port_t port, struct x86_debug_state* update, mach_msg_type_number_t state_count) {
    kern_return_t kr;

    kr = thread_set_state(port, x86_DEBUG_STATE, (thread_state_t)update, state_count);
    if (kr != KERN_SUCCESS) {
        printf("Setting x86 thread debug state failed with Mach error: 0x%x\n", kr);
    }
    return kr;
}

void start_threads() {
    
    kern_return_t kr;
    mach_msg_type_number_t state_count = x86_THREAD_STATE64_COUNT;

    pthread_t thread1;
    if (pthread_create_suspended_np(&thread1, NULL, thread_routine_1, NULL) != 0) {
        abort();
    }
    
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
    
    struct x86_debug_state debug_state;
    mach_msg_type_number_t debug_state_count = x86_DEBUG_STATE_COUNT;
    get_debug_state(mach_thread1, &debug_state, &debug_state_count);
    debug_state.uds.ds64.__dr0 = 43;
    set_debug_state(mach_thread1, &debug_state, debug_state_count);
    
    kr = thread_set_state(mach_thread1, x86_THREAD_STATE64, (thread_state_t) &x86_state, state_count);
    if (kr != KERN_SUCCESS) {
        printf("set state from same process thread 1 failed with Mach error: 0x%x\n", kr);
        return;
    }

    if (set_thread_state_from_another_process(mach_thread1, (thread_state_t) &x86_state, state_count) != EXIT_SUCCESS) {
        return;
    }
    
    kr = thread_resume(mach_thread1);
    if (kr != KERN_SUCCESS) {
        printf("resume thread 1 failed with Mach error: %d", kr);
        return;
    }
    
    x86_state.uts.ts64.__rip = 44;
    if (set_thread_state_from_another_process(mach_thread1, (thread_state_t) &x86_state, state_count) != EXIT_SUCCESS) {
        return;
    }
    sleep(60);

    abort();
}
