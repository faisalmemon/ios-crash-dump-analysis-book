//
//  PlanetViewController.m
//  icdab_planets
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import "PlanetViewController.h"

@interface PlanetViewController ()

@end

@implementation PlanetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    planet pluto = planet::get_planet_with_name("Pluto");
    planet jupiter = planet::get_planet_with_name("Jupiter");
    
    double pluto_diameter = pluto.get_diameter();
    double jupiter_diameter = jupiter.get_diameter();
    
    NSLog(@"Pluto diameter is %f", pluto_diameter);
    NSLog(@"Jupiter diameter is %f", jupiter_diameter);
    
    double pluto_volume = pluto.get_volume();
    assert(pluto_volume != 0.0);
    
    double plutos_to_fill_jupiter =  jupiter.get_volume() / pluto_volume;
    
    NSLog(@"Plutos that would fit inside Jupiter = %f", plutos_to_fill_jupiter);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
