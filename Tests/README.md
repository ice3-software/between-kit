#Unit Tests

Here be our unit test harness application. To run the unit tests:


	./Build/run_tests.sh
	
The unit tests come bundled with some utilities that should help you write clean tests, avoiding fragility and obscurity.
	

###Fixtures

- `I3CollectionFixture`: this class encapsulates all the boilerplate of mocking an `I3Collection`. Originally, we were mocking the `I3Collection` protocol and stubbing _all_ of the relevant methods in our unit test setup blocks which led to obscure tests and too much setup duplication to manage. Use this fixture whenever you want to deal with `I3Collection`.


- `I3DataSourceControllerFixture`: a subclass of `UIViewController` that implements `I3DragDataSource`.


- `I3DragDataSourceFixtures`: a collection of `I3DragDataSource` implementing classes that all implement different variations of the optional methods. This is used in the unit tests to test that `I3GestureCoordinator` responds correctly to different combinations of assertions and mutation method implementations.


###Creation Methods

- `I3CoordinatorCreationMethods`: a collection of methods for setting up  `I3GestureCoordinator`s and relevant dependencies.


###Assertions

- `EXPMatchers+haveStartedDrag`: a custom Expecta matcher for asserting whether a drag has started in a coordinator at a given point.


___<u>Documentation</u>: BetweenKit 2.0.0