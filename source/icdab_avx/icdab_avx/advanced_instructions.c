//
//  advanced_instructions.c
//  icdab_avx
//
//  Created by Faisal Memon on 06/10/2020.
//

/*
 https://www.codeproject.com/Articles/874396/Crunching-Numbers-with-AVX-and-AVX
 
 This function is uses an unsafe practice of not checking whether the platform
 supports the instructions it wants to execute beforehand.  Ideally, a higher
 level library, such as the Accelerate Framework should be used.
 
 For this project, our non-default settings are:
 
    Build Active Architecture Only set to YES for both Debug and Release.
    - This stops an ARM-64 version being build from an Intel Mac.
    Enable Additional Vector Extensions set to "AVX"
    - This allows the _mm256_* instructions to be compiled.
 
 We perform Product > Archive but from an Intel Mac.
 The app is then run on an Apple Silicon Mac.  It will crash.
 */

#include "advanced_instructions.h"

#include <immintrin.h>
#include <stdio.h>

#include <sys/sysctl.h>
#include <unistd.h>
#include <errno.h>

void
compute_delta() {
    
    /* Initialize the two argument vectors */
    __m256 evens = _mm256_set_ps(2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0);
    __m256 odds = _mm256_set_ps(1.0, 3.0, 5.0, 7.0, 9.0, 11.0, 13.0, 15.0);
    
    /* Compute the difference between the two vectors */
    __m256 result = _mm256_sub_ps(evens, odds);
    
    /* Display the elements of the result vector */
    float* f = (float*)&result;
    printf("%f %f %f %f %f %f %f %f\n",
           f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7]);
    
    return;
}

bool
avx_v1_supported() {
    
    int ret = 0;
    size_t size = sizeof(ret);
    if (sysctlbyname("hw.optional.avx1_0", &ret, &size, NULL, 0) == -1)
    {
       if (errno == ENOENT)
          return false;
       return false;
    }
    bool supported = (ret != 0);
    return supported;
}

