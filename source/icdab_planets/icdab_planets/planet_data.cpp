//
//  planet_data.cpp
//  icdab_planets
//
//  Created by Faisal Memon on 13/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#include "planet_data.hpp"
#include <map>

struct planet_database {
    map<string, planet> planets;
} database;

planet planet::get_planet_with_name(string name) {
    return database.planets[name];
}
