//
//  planet_data.cpp
//  icdab_planets
//
//  Created by Faisal Memon on 13/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#include "planet_data.hpp"
#include <map>
#include <math.h>

struct planet_database {
    map<string, planet> planets;
    bool loaded_data;
    
    void load_data();
} database;

static const double millionKm = 1000000;
static const double pi4_3 = atan(1)*4.0*4.0/3.0; // 4π/3

void planet_database::load_data() {
    planet planet_Mercury = planet("Mercury", 4878.0, 57.9 * millionKm);
    planets["Mercury"] = planet_Mercury;
    
    planet planet_Venus = planet("Venus", 12104, 108.2 * millionKm);
    planets["Venus"] = planet_Venus;
    
    planet planet_Earth = planet("Earth", 12756, 149.6 * millionKm);
    planets["Earth"] = planet_Earth;
    
    planet planet_Mars = planet("Mars", 6792, 227.9 * millionKm);
    planets["Mars"] = planet_Mars;
    
    planet planet_Jupiter = planet("Jupiter", 142984, 778 * millionKm);
    planets["Jupiter"] = planet_Jupiter;
    
    planet planet_Saturn = planet("Saturn", 120536, 1427 * millionKm);
    planets["Saturn"] = planet_Saturn;
    
    planet planet_Uranus = planet("Uranus", 51118, 2870 * millionKm);
    planets["Uranus"] = planet_Uranus;
    
    planet planet_Neptune = planet("Neptune", 49532, 44969 * millionKm);
    planets["Neptune"] = planet_Neptune;
    
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

double planet::get_volume(void) {
    // 4/3πr**3 = volume of a sphere
    double radius = this->diameter / 2.0;
    double r_3 = pow(radius, 3.0);
    double volume = pi4_3 * r_3;
    return volume;
}
