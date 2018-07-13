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
    planet jupiter = planet::get_planet_with_name("Jupiter");
    
    double pluto_diameter = pluto.get_diameter();
    double jupiter_diameter = jupiter.get_diameter();
    
    NSLog(@"Pluto diameter is %f", pluto_diameter);
    NSLog(@"Jupiter diameter is %f", jupiter_diameter);
    
    double plutos_to_fill_jupiter =  jupiter.get_volume() / pluto.get_volume();
    
    NSLog(@"Plutos that would fit inside Jupiter = %f", plutos_to_fill_jupiter);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
