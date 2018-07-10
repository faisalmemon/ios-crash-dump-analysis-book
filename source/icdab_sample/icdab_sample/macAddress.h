//
//  macAddress.h
//  icdab_sample
//
//  Created by Faisal Memon on 10/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#ifndef macAddress_h
#define macAddress_h

#import <Foundation/Foundation.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#endif /* macAddress_h */

@interface MacAddress: NSObject;
- (NSString *)getMacAddress;
@end
