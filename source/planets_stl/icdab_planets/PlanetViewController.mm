//
//  PlanetViewController.m
//  icdab_planets
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//
#import "PlanetViewController.h"

@interface PlanetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *jupiterLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutoLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutosInJupiterLabelOutlet;
@end
@implementation PlanetViewController

#define original_Code 0

#if original_Code
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
    
    self.jupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Jupiter (km) = %f",
     jupiter_diameter];
    self.plutoLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Pluto (km) = %f",
                                  pluto_diameter];
    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Number of Plutos that fit inside Jupiter = %f",
                                            plutos_to_fill_jupiter];
    
    [self safelyGetPlutosInJupiter];
}
#else
- (void)viewDidLoad {
    [super viewDidLoad];
    
    auto pluto_by_find = planet::find_planet_named("Pluto");
    auto jupiter_by_find = planet::find_planet_named("Jupiter");
    
    if (planet::isEnd(jupiter_by_find) || planet::isEnd(pluto_by_find)) {
        return;
    }
    
    auto pluto_vol = pluto_by_find->second.get_volume();
    auto jupiter_vol = jupiter_by_find->second.get_volume();
    
    assert (pluto_vol != 0.0);
    double plutos_to_fill_jupiter =  jupiter_vol / pluto_vol;
    
    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Number of Plutos that fit inside Jupiter = %f",
     plutos_to_fill_jupiter];
    
    double pluto_diameter = pluto_by_find->second.get_diameter();
    double jupiter_diameter = jupiter_by_find->second.get_diameter();
    self.jupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Jupiter (km) = %f",
     jupiter_diameter];
    self.plutoLabelOutlet.text =
    [NSString stringWithFormat:@"Diameter of Pluto (km) = %f",
     pluto_diameter];
}
#endif

- (void)safelyGetPlutosInJupiter {
    auto pluto_by_find = planet::find_planet_named("Pluto");
    auto jupiter_by_find = planet::find_planet_named("Jupiter");
    
    if (planet::isEnd(jupiter_by_find) || planet::isEnd(pluto_by_find)) {
        return;
    }
    
    auto pluto_vol = pluto_by_find->second.get_volume();
    auto jupiter_vol = jupiter_by_find->second.get_volume();
    
    assert (pluto_vol != 0.0);
    double plutos_to_fill_jupiter =  jupiter_vol / pluto_vol;
    
    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Number of Plutos that fit inside Jupiter = %f",
     plutos_to_fill_jupiter];
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
