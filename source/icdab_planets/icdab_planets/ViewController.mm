//
//  ViewController.mm
//  icdab_planets
//
//  Created by Faisal Memon on 13/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    planet pluto = planet::get_planet_with_name("Pluto");
    
    double diameter = pluto.get_diameter();
    
    NSLog(@"Pluto diameter is %f", diameter);
    
//    NSString *planetName = [NSString stringWithCString:pluto.name
//                       encoding:[NSString defaultCStringEncoding]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
