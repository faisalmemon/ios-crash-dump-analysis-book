//
//  planet_data.hpp
//  icdab_planets
//
//  Created by Faisal Memon on 13/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#ifndef planet_data_hpp
#define planet_data_hpp

#include <string>

using namespace std;

class planet {
    string name;
    double diameter;
    double distance_from_sun;
    
    static planet get_planet_with_name(string name);
};



#endif /* planet_data_hpp */
