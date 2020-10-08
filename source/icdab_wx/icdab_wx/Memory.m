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

#ifndef MAP_ANONYMOUS
# define MAP_ANONYMOUS MAP_ANON
#endif

+ (void)map_jit_memory {
   int fd = open(SHM_NAME, O_RDWR | O_CREAT, 0666);
   int r = ftruncate(fd, SIZE);
   
   void *buf1 = mmap(0, SIZE, PROT_READ | PROT_WRITE, MAP_JIT, fd, 0);
   
   strcpy(buf1, "Modified buffer");
  
   r = munmap(buf1, SIZE);
   printf("munmap(buf1): %i\n", r);
   r = shm_unlink(SHM_NAME);
   printf("shm_unlink: %i\n", r);
}

+ (void)map_jit_memory1 {
    int fd = open(SHM_NAME, O_RDWR | O_CREAT, 0666);
    int r = ftruncate(fd, SIZE);
    
    void *buf1 = mmap(0, SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    size_t size = getpagesize() * 2;
    void *buf2 = mmap(0, size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    assert(buf2);
    
    // Make half of the memory inaccessible.
    assert(0 == mprotect((char *)buf2 + size / 2, size / 2, PROT_NONE));
    
    truncate(buf2, SIZE);
    *((void **)buf2) = malloc(SIZE);
    ftruncate(fd, 4096*2);
    
    strcpy(buf1, "Original buffer");
    strcpy(buf2, "Modified buffer");
    // buf1 and buf2 are now two separate buffers
    strcpy(buf1, "Modified original buffer");
    
    r = munmap(buf2, SIZE);
    printf("munmap(buf2): %i\n", r);
    r = munmap(buf1, SIZE);
    printf("munmap(buf1): %i\n", r);
    r = shm_unlink(SHM_NAME);
    printf("shm_unlink: %i\n", r);
}

+ (void)map_jit_memory_orig {
    void *result;
    int fd = open("jit-memory-shm", O_RDWR | O_CREAT, 0666);
    if (fd == -1) {
        perror("open");
        return;
    }
    
    //mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
    result = mmap(NULL, 2048, MAP_ANON, -1, fd, 0);
    NSLog(@"result was %p", result);
    if (result == MAP_FAILED) {
        NSLog(@"Map returned a failure.");
        perror("Map failed");
    }
}

@end

