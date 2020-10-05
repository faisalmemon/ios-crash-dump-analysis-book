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
#include <sys/types.h>

/*
 The purpose of this program is to try to do a thread_set_state from another
 process, and then crash, so that we can produce a crash dump that shows the
 thread crashed, but in its history, had someone externally affect it.
 
 Unfortunately, it seems that we cannot successfully call `set_thread_state`
 from another process.  Tested macOS Catalina 10.15.7 (19H2).
 */

/* A task that takes some time to complete. The id identifies distinct
 tasks for printed messages. */
void *
task(long id) {
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
void *
threaded_task(long t) {
    long id = (long) t;
    printf("Thread %ld started\n", id);
    task(id);
    printf("Thread %ld done\n", id);
    pthread_exit(0);
}

void *
thread_routine_1() {
    threaded_task(500);
    return NULL;
}

/*
 Task related articles:
 https://knight.sc/reverse%20engineering/2019/04/15/detecting-task-modifications.html
 https://bazad.github.io/2018/10/bypassing-platform-binary-task-threads/
 https://gist.github.com/Coneko/4234842
 */

#if TARGET_CPU_X86_64
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
    } else {
        printf("Successfully set x86 thread debug state\n");
    }
    return kr;
}
#endif // TARGET_CPU_X86_64

#if TARGET_CPU_ARM64
kern_return_t
get_debug_state(mach_port_t port, struct arm_unified_thread_state* result, mach_msg_type_number_t* state_count) {
    kern_return_t kr;
    kr = thread_get_state(port, ARM_DEBUG_STATE, (thread_state_t)result, state_count);
    if (kr != KERN_SUCCESS) {
        printf("Getting arm64 thread debug state failed with Mach error: 0x%x\n", kr);
    }
    return kr;
}

kern_return_t
set_debug_state(mach_port_t port, struct x86_debug_state* update, mach_msg_type_number_t state_count) {
    kern_return_t kr;
    kr = thread_set_state(port, ARM_DEBUG_STATE, (thread_state_t)update, state_count);
    if (kr != KERN_SUCCESS) {
        printf("Setting arm64 thread debug state failed with Mach error: 0x%x\n", kr);
    } else {
        printf("Successfully set arm64 thread debug state\n");
    }
    return kr;
}
#endif // TARGET_CPU_ARM64

void *
set_thread_state_from_another_thread(struct thread_management_payload_struct *payload) {
    set_debug_state(payload->port, &payload->state, payload->count);
    return NULL;
}

kern_return_t
set_debug_state_from_another_process(struct thread_management_payload_struct *payload) {
    kern_return_t kr = KERN_SUCCESS;
    pid_t processId;
    
    if ((processId = fork()) == 0) {
        printf("Spawned child process id %ld\n", (long)processId);
        kr = set_debug_state(payload->port, &payload->state, payload->count);
    }
    return kr;
}

void start_threads() {
    pthread_t thread1;
    if (pthread_create_suspended_np(&thread1, NULL, thread_routine_1, NULL) != 0) {
        abort();
    }
    
    mach_port_t mach_thread1 = pthread_mach_thread_np(thread1);
    thread_affinity_policy_data_t policyData1 = { 1 };
    thread_policy_set(mach_thread1, THREAD_AFFINITY_POLICY, (thread_policy_t)&policyData1, 1);
    thread_resume(mach_thread1);
    
#if TARGET_CPU_X86_64
    struct x86_debug_state debug_state;
    mach_msg_type_number_t debug_state_count = x86_DEBUG_STATE_COUNT;
#endif
#if TARGET_CPU_ARM64
    struct arm_unified_thread_state debug_state;
    mach_msg_type_number_t debug_state_count = ARM_DEBUG_STATE_COUNT;
#endif
    get_debug_state(mach_thread1, &debug_state, &debug_state_count);
#if TARGET_CPU_X86_64
    debug_state.uds.ds64.__dr0 = 43;
#endif
#if TARGET_CPU_ARM64
    debug_state.ts_64.__pad = 43;
#endif
    struct thread_management_payload_struct payload = {
        .port = mach_thread1,
        .state = debug_state,
        .count = debug_state_count
    };
    
    pthread_t thread2;
    if (pthread_create_suspended_np(&thread2,
                                    NULL,
                                    (pthread_create_suspended_np_cmd)
                                    set_thread_state_from_another_thread,
                                    &payload) != 0) {
        abort();
    }
    
    mach_port_t mach_thread2 = pthread_mach_thread_np(thread2);
    thread_affinity_policy_data_t policyData2 = { 1 };
    thread_policy_set(mach_thread2, THREAD_AFFINITY_POLICY, (thread_policy_t)&policyData2, 1);
    thread_resume(mach_thread2);
    
    set_debug_state_from_another_process(&payload);
    sleep(60);

    abort();
}
