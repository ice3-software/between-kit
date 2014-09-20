#README

This is the tests directory for the framework.

###Fixtures

Because OCMock can't reliably stub `respondsToSelector` for protocol mocks, e.g.


```objective-c

id mockDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
OCMStub([mockDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)]).andReturn(YES);


```

We have had to create 'fixtures' for the different possible implementations of the `I3DragDataSource` protocol, each with different variations on required method implementations.

Fixture `@interface` and `@implementation` declarations are both in their header files as they are intended to be small, dummy classes.