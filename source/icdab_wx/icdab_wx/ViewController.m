//
//  ViewController.m
//  icdab_wx
//
//  Created by Faisal Memon on 08/10/2020.
//

#import "ViewController.h"
#import "Memory.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Memory map_jit_memory];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
