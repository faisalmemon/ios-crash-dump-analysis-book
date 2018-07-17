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
    void add_planet(planet additional_planet);
} database;

static const double millionKm = 1000000;
static const double pi4_3 = atan(1)*4.0*4.0/3.0; // 4π/3

void planet_database::load_data() {
    add_planet(planet("Mercury", 4878.0, 57.9 * millionKm));
    add_planet(planet("Venus", 12104, 108.2 * millionKm));
    add_planet(planet("Earth", 12756, 149.6 * millionKm));
    add_planet(planet("Mars", 6792, 227.9 * millionKm));
    add_planet(planet("Jupiter", 142984, 778 * millionKm));
    add_planet(planet("Saturn", 120536, 1427 * millionKm));
    add_planet(planet("Uranus", 51118, 2870 * millionKm));
    //No longer considered a planet but instead a dwarf planet
    //add_planet(planet("Pluto", 2370, 7375 * millionKm));

    loaded_data = true;
}

void planet_database::add_planet(planet additional_planet) {
    planets[additional_planet.get_name()] = additional_planet;
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

map<string, planet>::iterator planet::find_planet_named(string name) {
    if (!database.loaded_data) {
        database.load_data();
    }
    
    return database.planets.find(name);
}

bool planet::isEnd(map<string, planet>::iterator it) {
    if (it == database.planets.end()) {
        return true;
    }
    return false;
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

void planet::add_planet(planet extra) {
    database.add_planet(extra);
}

string planet::get_name() {
    return name;
}
