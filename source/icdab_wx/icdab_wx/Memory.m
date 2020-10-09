//
//  memory.m
//  icdab_wx
//
//  Created by Faisal Memon on 08/10/2020.
//

#import <Foundation/Foundation.h>

#import "Memory.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

@implementation Memory

#define SIZE 4096
#define SHM_NAME "map-jit-memory"

#define PT_TRACE_ME 0
int ptrace(int, pid_t, caddr_t, int); // private method

+ (void)crashThenStallCrashReporting:(BOOL)stall {
    int fd = open(SHM_NAME, O_RDWR | O_CREAT, 0666);
    int result = ftruncate(fd, SIZE);
    
    // we are not privileged so this will not be successful
    void *buf1 = mmap(0,
                      SIZE,
                      PROT_READ | PROT_WRITE,
                      MAP_JIT,
                      fd,
                      0);
    
    if (stall) {
        ptrace(PT_TRACE_ME, 0, NULL, 0);
    }
    
    // trigger crash by accessing a bad buffer
    strcpy(buf1, "Modified buffer");
    
    result = munmap(buf1, SIZE);
    result = shm_unlink(SHM_NAME);
}

@end

