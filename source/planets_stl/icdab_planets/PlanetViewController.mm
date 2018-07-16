//
//  PlanetViewController.m
//  icdab_planets
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//
#import "PlanetViewController.h"

@interface PlanetViewController () {
    planet pluto;
    planet jupiter;
}

@property (weak, nonatomic) IBOutlet UILabel *jupiterLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutoLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutosInJupiterLabelOutlet;

@end


@implementation PlanetViewController

- (BOOL)loadPlanetData {
    auto pluto_by_find = planet::find_planet_named("Pluto");
    auto jupiter_by_find = planet::find_planet_named("Jupiter");
    
    if (planet::isEnd(jupiter_by_find) || planet::isEnd(pluto_by_find)) {
        return NO;
    }
    pluto = pluto_by_find->second;
    jupiter = jupiter_by_find->second;
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self loadPlanetData] == NO) {
        return;
    }

    auto pluto_vol = pluto.get_volume();
    auto jupiter_vol = jupiter.get_volume();
    
    assert (pluto_vol != 0.0);
    double plutos_to_fill_jupiter =  jupiter_vol / pluto_vol;
    
    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Number of Plutos that fit inside Jupiter = %f",
     plutos_to_fill_jupiter];
    
    double pluto_diameter = pluto.get_diameter();
    double jupiter_diameter = jupiter.get_diameter();
    self.jupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Jupiter (km) = %f",
     jupiter_diameter];
    self.plutoLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Pluto (km) = %f",
     pluto_diameter];
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
