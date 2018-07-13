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

class planet_database;

class planet {
    string name;
    double diameter;
    double distance_from_sun;
    
public:
    planet();
    planet(string name, double diameter, double distance_from_sun);
    planet(const planet& other);
    virtual ~planet();
    bool operator<(const planet& l) const;

    string get_name(void);
    double get_diameter(void);
    double get_distance_from_sun(void);
    
public:
    static planet get_planet_with_name(string name);
    
    friend planet_database;
};



#endif /* planet_data_hpp */
