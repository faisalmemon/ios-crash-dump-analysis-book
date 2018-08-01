//
//  DetailsViewController.m
//  icdab_ball_osx
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import "DetailsViewController.h"
#import "pthread_helper.h"

@interface DetailsViewController ()
@property (weak) IBOutlet NSTextField *threadInformationLabelOutlet;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    uint64_t threadNumber = get_current_thread_details();
    self.threadInformationLabelOutlet.stringValue = [NSString stringWithFormat:@"Current pthread is %llu", threadNumber];
}

@end
