# Hybrid Environments

We have seen that Xcode offers many automatic facilities for crash dump analysis and crash avoidance.  However, these cannot get us all the answers we need.  A complementary design oriented viewpoint is needed.

In this chapter, we shall look at a sample app `icdab_planets` that uses hybrid of programming languages and paradigms.  It shows an example of why design insights must also be considered.

## Program structure

The `icdab_planets` sample app uses a mixture of C++, and Objective-C++.  It relies on both STL\index{STL} data structures and traditional Objective-C data structures.  @icdabgithub

The model layer of the app is written in C++.  The controller layer of the app is written in Objective-C++\index{Objective-C++}.

The purpose of the app is to tell us how many Pluto sized planets would fit inside Jupiter.

## Paradigms

Recall earlier we demonstrated that:

- Objective-C allows messaging to nil objects
- C crashes upon NULL dereference

Here we show how the C++ Standard Template Library has a back-fill strategy.

In the STL map\index{STL!map} abstraction (a Hash Table) when we query for an entry that does not exist, the STL will insert a new entry in the table for the key being queried, and then return that entry instead of returning an error or returning a nil.

## The Problem

In our sample app, which crashes upon launch, we have an assert that gets triggered.

```
double pluto_volume = pluto.get_volume();
assert(pluto_volume != 0.0);

double plutos_to_fill_jupiter
        =  jupiter.get_volume() / pluto_volume;
```

Enabling code Analysis will not find any issue or warning.

The assert is in place to avoid a division by zero.  The fact that it is triggered is good because we know where to start debugging the problem.

Pluto's volume is 0.0 because the code
```
planet pluto = planet::get_planet_with_name("Pluto");
```

returns a planet with zero diameter.

From the file `planet_data.hpp` we see the API that we rely upon is:
```
static planet get_planet_with_name(string name);
```

Therefore, whatever name we pass in, we should always get a `planet` in response; never a NULL.

The problem is that this API has not been thought deeply about.  It has just been put together as a thin wrapper around the underlying abstractions that do the work.

We have
```
planet planet::get_planet_with_name(string name) {
    if (!database.loaded_data) {
        database.load_data();
    }
    return database.planets[name];
}
```

At first glance, it might be that the database failed to load data properly.
In fact, the database is missing the entry for Pluto due to it no longer being considered a planet:

```
void planet_database::load_data() {
    planet planet_Mercury =
     planet("Mercury", 4878.0, 57.9 * millionKm);
    planets["Mercury"] = planet_Mercury;

    planet planet_Venus =
     planet("Venus", 12104, 108.2 * millionKm);
    planets["Venus"] = planet_Venus;

    planet planet_Earth =
     planet("Earth", 12756, 149.6 * millionKm);
    planets["Earth"] = planet_Earth;

    planet planet_Mars =
     planet("Mars", 6792, 227.9 * millionKm);
    planets["Mars"] = planet_Mars;

    planet planet_Jupiter =
     planet("Jupiter", 142984, 778 * millionKm);
    planets["Jupiter"] = planet_Jupiter;

    planet planet_Saturn =
     planet("Saturn", 120536, 1427 * millionKm);
    planets["Saturn"] = planet_Saturn;

    planet planet_Uranus =
     planet("Uranus", 51118, 2870 * millionKm);
    planets["Uranus"] = planet_Uranus;

    planet planet_Neptune =
     planet("Neptune", 49532, 4497 * millionKm);
    planets["Neptune"] = planet_Neptune;

//  No longer considered a planet but instead a dwarf planet
//  planet planet_Pluto =
//   planet("Pluto", 2370, 7375 * millionKm);
//  planets["Pluto"] = planet_Pluto;

    loaded_data = true;
}
```

The problem indirectly is because `database.planets[name]` discovered that there was no entry for Pluto so created one via the no-arg constructor as this is the behavior for STL map data structures.

```
planet::planet() {
    this->name = "";
    this->diameter = 0.0;
    this->distance_from_sun = 0.0;
}
```

We see the constructor makes the diameter zero in this case.

## Solutions

We see that the problem is not applying the paradigms of each framework and language properly and when we have a mixture of paradigms, those different assumptions get masked by each layer of abstraction.

In STL, we expect a `find`\index{STL!find} operation to be done, instead of the indexing operator.  This allows the abstraction to flag the absence of the item being found.

In Objective-C we expect the lookup API to be a function which returns an index given the lookup name.  In addition, the index would be `NSNotFound`\index{NSNotFound} when the operation failed.

In this code example, each layer of abstraction assumes the other side will re-map the edge case into an appropriate form.

### STL Solution

We have a variant of the code which does things "properly" from an STL point of view. @icdabgithub
It is `icdab_planets_stl/icdab_planets`.  On the consumer side, we have a helper method:

```
- (BOOL)loadPlanetData {
    auto pluto_by_find = planet::find_planet_named("Pluto");
    auto jupiter_by_find = planet::find_planet_named("Jupiter");

    if (planet::isEnd(jupiter_by_find) ||
     planet::isEnd(pluto_by_find)) {
        return NO;
    }
    pluto = pluto_by_find->second;
    jupiter = jupiter_by_find->second;
    return YES;
}
```

This is hard to parse if we are mainly an Objective-C programmer.  If the
project is mainly a C++ project, with a thin platform-specific layer, then perhaps
that is acceptable.  If the code base just leverages C++ code from elsewhere,
then a better solution is to confine the paradigms to their own files and apply
the facade\index{software!facade} design pattern to give a version of the API following Objective-C
paradigms on the platform-specific code side.

Then Objective-C++ can be dispensed with in the ViewController code; it can be made an Objective-C file instead.

### Facade Solution

Here is a facade\index{software!facade} implementation `icdab_planets_facade/icdab_planets` that overcomes the mixing of paradigms problem.

The facade is:
```
@implementation PlanetModel

- (id)init {
    self = [super init];

    NSString *testSupportAddPluto =
     [[[NSProcessInfo processInfo] environment]
      objectForKey:@"AddPluto"];

    if ([testSupportAddPluto isEqualToString:@"YES"]) {
        planet::add_planet(
          planet("Pluto", 2370, 7375 * millionKm));
    }

    if (self) {
        _planetDict = [[NSMutableDictionary alloc] init];
        auto pluto_by_find =
         planet::find_planet_named("Pluto");
        auto jupiter_by_find =
         planet::find_planet_named("Jupiter");

        if (planet::isEnd(jupiter_by_find) ||
         planet::isEnd(pluto_by_find)) {
            return nil;
        }
        auto pluto = pluto_by_find->second;
        auto jupiter = jupiter_by_find->second;

        PlanetInfo *plutoPlanet = [[PlanetInfo alloc] init];
        plutoPlanet.diameter = pluto.get_diameter();
        plutoPlanet.distanceFromSun =
         pluto.get_distance_from_sun();
        plutoPlanet.volume = pluto.get_volume();
        assert (plutoPlanet.volume != 0.0);
        [_planetDict setObject:plutoPlanet forKey:@"Pluto"];

        PlanetInfo *jupiterPlanet = [[PlanetInfo alloc] init];
        jupiterPlanet.diameter = jupiter.get_diameter();
        jupiterPlanet.distanceFromSun =
         jupiter.get_distance_from_sun();
        jupiterPlanet.volume = jupiter.get_volume();
        assert (jupiterPlanet.volume != 0.0);
        [_planetDict setObject:jupiterPlanet forKey:@"Jupiter"];
    }

    return self;
}

@end
```

The consumer then becomes a purely Objective-C class:

```
- (void)viewDidLoad {
    [super viewDidLoad];

    self.planetModel = [[PlanetModel alloc] init];

    if (self.planetModel == nil) {
        return;
    }

    double pluto_diameter =
     self.planetModel.planetDict[@"Pluto"].diameter;
    double jupiter_diameter =
     self.planetModel.planetDict[@"Jupiter"].diameter;
    double plutoVolume =
     self.planetModel.planetDict[@"Pluto"].volume;
    double jupiterVolume =
     self.planetModel.planetDict[@"Jupiter"].volume;
    double plutosInJupiter = jupiterVolume/plutoVolume;

    self.plutosInJupiterLabelOutlet.text =
    [NSString stringWithFormat:
    @"Number of Plutos that fit inside Jupiter = %f",
     plutosInJupiter];

    self.jupiterLabelOutlet.text =
    [NSString stringWithFormat:
     @"Diameter of Jupiter (km) = %f",
     jupiter_diameter];
    self.plutoLabelOutlet.text =
    [NSString stringWithFormat:
     @"Diameter of Pluto (km) = %f",
     pluto_diameter];
}
```

## Lessons Learnt

The lesson here is that crashes can arise from special case handling.  Since different languages and frameworks deal with special cases in their own idiomatic manner, it is safer to separate out our code and use a Facade\index{software!facade} if possible to keep each paradigm cleanly separated.
