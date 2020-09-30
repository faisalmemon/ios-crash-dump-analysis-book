//
//  pthread_helper.h
//  icdab_thread
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#ifndef pthread_helper_h
#define pthread_helper_h

#include <stdio.h>

#import <mach/thread_act.h>

struct thread_management_payload_struct {
    mach_port_t port;
    struct x86_debug_state state;
    mach_msg_type_number_t count;
};

void start_threads(void);

#endif /* pthread_helper_h */
