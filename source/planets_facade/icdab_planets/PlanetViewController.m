//
//  PlanetViewController.m
//  icdab_planets
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//
#import "PlanetViewController.h"
#import "PlanetModel.h"

@interface PlanetViewController () {
}

@property (weak, nonatomic) IBOutlet UILabel *jupiterLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutoLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *plutosInJupiterLabelOutlet;

@property (nonatomic, strong) PlanetModel *planetModel;
@end


@implementation PlanetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.planetModel = [[PlanetModel alloc] init];
    
    if (self.planetModel == nil) {
        return;
    }
    
    double pluto_diameter = self.planetModel.planetDict[@"Pluto"].diameter;
    double jupiter_diameter = self.planetModel.planetDict[@"Jupiter"].diameter;
    double plutoVolume = self.planetModel.planetDict[@"Pluto"].volume;
    double jupiterVolume = self.planetModel.planetDict[@"Jupiter"].volume;
    double plutosInJupiter = jupiterVolume/plutoVolume;

    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:@"Number of Plutos that fit inside Jupiter = %f",
     plutosInJupiter];

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
