#![](Docs/Images/exchange-35x35.png)&nbsp;&nbsp;BetweenKit 

[![Build Status](https://travis-ci.org/ice3-software/between-kit.svg?branch=task-28-build-2.0.0)](https://travis-ci.org/ice3-software/between-kit) [![Coverage Status](https://coveralls.io/repos/ice3-software/between-kit/badge.png?branch=task-52-static-analysis-mess-detection)](https://coveralls.io/r/ice3-software/between-kit?branch=task-52-static-analysis-mess-detection)

###Overview

BetweenKit is a robust framework, built on `UIKit` that allows you to build drag-and-drop functionallity into your iOS application user interfaces. 

BetweenKit is based on the concepts of the original [i3-dragndrop](https://github.com/ice3-software/between-kit/tree/1.1.1) helper, re-engineered from the ground up.

Check out the [website](http://ice3-software.github.io/between-kit/) and [documentation](Docs/) for more.

###Features

- __Easy to integrate__: aims to work smoothly alongside Apple's built in UI components.

- __Rich 'drag and drop' abstraction__: abstracts away the gory details of gesture handling to provide a series of high-level 'drop/drop'-like events: drag starting, rearranging, deleting, dropping, etc.

- __Fully extensible__: customize everything from the drag/drop properties of individual items in a collection, to how the various drag/drop events are rendered on-screen. SOLID design of its core components gives you the flexibillity to [inject](http://en.wikipedia.org/wiki/Dependency_inversion_principle), [extend](http://en.wikipedia.org/wiki/Open/closed_principle), [override](http://en.wikipedia.org/wiki/Liskov_substitution_principle), [conform](http://en.wikipedia.org/wiki/Interface_segregation_principle) and [take control](http://i3.ytimg.com/vi/j4cokDb68jc/hqdefault.jpg).

- __Fully tested__: ~100% unit test coverage, 20 functional use case applications, used in [production applications](Docs/Production Cases.md) on the App Store. It also comes bundled with a few test utilities to make it easier for contributors to write clean unit tests.

- __Fully documented__: full written documentation, extensive inline comments and example code provided in the 20 use cases.

- __Reliable__: tried, tested, refined, re-tried and re-tested once more.

###License 

BetweenKit is licensed under the MIT License. See [here](Docs/Licenses/BetweenKit - LICENSE.txt). 
