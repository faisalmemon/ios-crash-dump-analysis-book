# 混合环境

我们已经了解到 Xcode 提供了许多用于崩溃转储分析和预防崩溃的自动工具。然而这些并不能为我们提供需要的所有答案。我们需要有一个面向设计的观点来思考问题。

在本章中，我们将去研究一个使用混合语言和编程范式的示例应用程序 `icdab_planets`。它告诉我们为什么还必须考虑设计问题。

## 项目结构

示例应用程序 `icdab_planets` 采用 C++ 和 Objective-C++ 的混合编程。它同时依赖于 STL 数据结构和传统的 Objective-C 数据结构。

应用程序的 `model` 层是用 C++ 编写的。应用程序的 `controller`层是用 Objective-C++ 编写的。

该应用程序的目的是告诉我们木星内部可以容纳多少个冥王星大小的行星。

## 范式

回想一下，我们证明了：

- Objective-C 允许向 nil 对象发送消息
- C  语言环境中，引用NULL 时会发生崩溃

这里，我们展示了 C++ 标准模板库具有怎样 `back-fill` 策略。

在 STL 映射抽象（哈希表）中，当我们查询一个不存在的条目时，STL 将在表中插入一个新的条目，用于查询所查询的关键字，然后返回该条目，而不是返回一个错误或返回一个 nil。

## 问题

在示例应用程序（该应用程序在启动时崩溃）中，有一个断言被触发。 

```
double pluto_volume = pluto.get_volume();
assert(pluto_volume != 0.0);

double plutos_to_fill_jupiter
        =  jupiter.get_volume() / pluto_volume;
```

启动代码分析并不会发现任何问题或警告。

代码中的断言是为了避免被零除。 事实上断言被触发其实很好，因为我们知道从哪里开始调试问题。

因为这段代码，冥王星的质量为 0.0。
```
planet pluto = planet::get_planet_with_name("Pluto");
```

返回直径为零的行星。

在代码文件 `planet_data.hpp`中我们可以看到这个 API：
```
static planet get_planet_with_name(string name);
```

因此，无论我们传递任何名称，我们都能得到一个`planet`作为回应；这个值永远不为 `NULL`。

问题是对于该 API 需要更为严谨的思考。它只是为了完成工作而做的一个简单的抽象。

这里有
```
planet planet::get_planet_with_name(string name) {
    if (!database.loaded_data) {
        database.load_data();
    }
    return database.planets[name];
}
```

乍一看，可能是由于数据库没办法正确加载数据。
事实上是因为数据中缺少冥王星对应的条目：

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

这个问题的间接表现是 `database.planets[name]` 并没有获取到冥王星的数据，因此通过`no-arg`构造函数创建了一个条目，这是 STL 映射数据结构的行为。

```
planet::planet() {
    this->name = "";
    this->diameter = 0.0;
    this->distance_from_sun = 0.0;
}
```

在这种情况下，我们看到默认构造函数中将直径为零。

## 解决方案

我们发现问题是因为没有合适的运用各种语言的框架和范式，当我们混用这些范式时，每个抽象层都会掩盖不同的假设。

在 STL 中，我们期望完成`find` 操作，而不是索引操作符。这就允许抽象标记可以找不到的对应的条目。

在 Objective-C 中，我们期望 lookup API 是一个返回给定查找名称的索引的函数。另外，当操作失败时，索引将被置为 `NSNotFound`。

在此代码示例中，每个抽象层都假设另一侧将边缘案例重新映射为适当的形式。

### STL 解决方案

从 STL 的角度来看，我们有一个可以`正确地`执行操作代码变体。在文件`example/planets_stl`中。 在方法获取时，我们可以有一个辅助的方法：

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

对于一个主要使用 Objective-C 语言的开发者来说这段代码很难理解。但是如果该项目主要以 C++ 开发的话，具有特定的相关平台经验，那么这也许是可以接受的。如果代码库只使用了部分的 C++ 代码，那么更好的解决方案是将特定范式限制在文件中，并应用外观设计模式，在特定的平台代码端提供遵循 Objective-C 范式的 API 版本。 

然后，ViewController 代码中可以不使用 Objective-C++，而是将其作为 Objective-C 文件。

### 外观模式解决方案

> 外观模式是一种设计模式，我认为是类似于工厂模式的，请查看[维基百科](https://zh.wikipedia.org/wiki/%E5%A4%96%E8%A7%80%E6%A8%A1%E5%BC%8F)

这里有一个外观模式解决方案 `example/facade_planets` 用来解决混合编程的问题

外观模式解决方案:
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

然后，API 调用方变成纯粹的 Objective-C 类：

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

## 经验教训

这里的经验是崩溃可能来自特殊情况处理。由于不同的语言和框架以它们自己惯用的方式处理特殊的情况，因此如果可能的话，将代码分离出来并使用一个特定的外观来保持各种范式清晰分离是比较安全的。
