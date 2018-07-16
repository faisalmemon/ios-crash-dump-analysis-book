//
//  PlanetModel.h
//  icdab_planets
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlanetInfo: NSObject
@property (nonatomic, strong) NSString *name;
@property double diameter;
@property double distanceFromSun;
@property double volume;
@end

@interface PlanetModel : NSObject

@property (nonatomic, strong) NSDictionary<NSString*, PlanetInfo *> *planetDict;

@end

NS_ASSUME_NONNULL_END
