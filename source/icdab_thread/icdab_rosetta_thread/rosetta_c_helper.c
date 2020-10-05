//
//  rosetta_c_helper.c
//  icdab_rosetta_thread
//
//  Created by Test Secure on 05/10/2020.
//  Copyright © 2020 Faisal Memon. All rights reserved.
//

#include <sys/sysctl.h>
#include <unistd.h>
#include <errno.h>
#include "rosetta_c_helper.h"

int processIsTranslated() {
   int ret = 0;
   size_t size = sizeof(ret);
   if (sysctlbyname("sysctl.proc_translated", &ret, &size, NULL, 0) == -1)
   {
      if (errno == ENOENT)
         return 0;
      return -1;
   }
   return ret;
}
