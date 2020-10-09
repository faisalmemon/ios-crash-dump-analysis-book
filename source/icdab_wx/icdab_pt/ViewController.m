//
//  ViewController.m
//  icdab_pt
//
//  Created by Faisal Memon on 09/10/2020.
//

#import "ViewController.h"

#import "Memory.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)triggerMemmapCrashAction:(id)sender {
    [Memory map_jit_memoryStalled:NO];
}

- (IBAction)triggerStalledCrashAction:(id)sender {
    [Memory map_jit_memoryStalled:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
