//
//  pthread_helper.h
//  icdab_ball_osx
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#ifndef pthread_helper_h
#define pthread_helper_h

#include <sys/ucontext.h>
#include <pthread.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <mach/mach.h>
#include <stdlib.h>
#include <math.h>

uint64_t get_current_thread_details(void);

#endif /* pthread_helper_h */
