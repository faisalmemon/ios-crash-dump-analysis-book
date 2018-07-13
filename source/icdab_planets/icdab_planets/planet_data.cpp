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
    bool loaded_data;
    
    void load_data();
} database;

void planet_database::load_data() {
    planet planet_mercurcy = planet("mercury", 4.0, 4.0);
    planets["mercury"] = planet_mercurcy;
    loaded_data = true;
}

bool planet::operator<(const planet& r ) const
{
    if (this->name < r.name)  return true;
    if (this->name > r.name)  return false;
    
    if (this->diameter < r.diameter)  return true;
    if (this->diameter > r.diameter)  return false;
    
    if (this->distance_from_sun < r.distance_from_sun)  return true;
    if (this->distance_from_sun > r.distance_from_sun)  return false;
    
    // Otherwise both are equal
    return false;
}

planet::~planet() {
}

planet::planet() {
    this->name = "";
    this->diameter = 0.0;
    this->distance_from_sun = 0.0;
}

planet::planet(const planet& other) {
    this->name = other.name;
    this->diameter = other.diameter;
    this->distance_from_sun = other.distance_from_sun;
}

planet::planet(string name, double diameter, double distance_from_sun) {
    this->name = name;
    this->diameter = diameter;
    this->distance_from_sun = distance_from_sun;
}

planet planet::get_planet_with_name(string name) {
    if (!database.loaded_data) {
        database.load_data();
    }
    return database.planets[name];
}

double planet::get_diameter(void) {
    return diameter;
}

double planet::get_distance_from_sun(void) {
    return distance_from_sun;
}
