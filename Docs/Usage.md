#Usage

###Overview

This document describes how you can use `BetweenKit` in your application. It introduces the concepts of the domain and then explores the core framework components. It provides example code snippets where possible but for full working examples, see the various [use cases]() and [unit tests]().

###Problem Domain

It isn't particularly easy to build smooth drag-and-drop into your iOS applications, especially when you are dealing with multiple data-view components such as tables and collections. To achieve drag-and-drop in the past I've found myself building complex view controllers that deal with all manner of things including gesture handling, geometric conversion, data manipulation and rendering. The view controllers quickly became difficult to maintain and the unsegregated nature of the drag-and-drop functionality meant that reusing and extending it was nearly impossible.

###Premises

`BetweenKit` aims to abstracting away the various `UIKit` interactions required to implement drag-and-drop, and expose a clean API. It relies on a series of premises about drag-and-drop from which we can model the domain:

- A <u>__collection__</u> is a view that contains and array of child <u>__items__</u>.
- A <u>__drag arena__</u> consists of a <u>__superview__</u> and an ordered set of <u>__collections__</u> that exist as subviews within that superview.
- The order of the collections in the drag arena determines their drag / drop priority. That is, if a collection sits at the beginning of the drag arena's ordered set of collections, then drags and drops occurring on that collection will be recognized in place of any of the later collections in the set.
- A drag <u>__starts__</u> if and only if a gesture is started within the bounds of a <u>__draggable__</u> item of a collection in the drag arena.
- <u>__Dragging__</u> occurs if and only if, immediately after a drag has been started, the location of the gesture changes within the drag arena.
- A drag <u>__stops__</u> if and only if immediately after dragging the gesture stops, is cancelled or finishes.
- A <u>__deletion__</u> occurs if and only if the drag stops at a point which is specified as being <u>__deletable__</u>. For example, the user may designate certain bounds within the drag arena to be 'delete on drop' areas.
- A <u>__rearrange__</u> occurs if and only if the drag stops within the bounds of the collection that it started in, on a different item in that collection which is specified as being <u>__rearrangeable__</u>, and on a point in the drag arena that is not specified as being deletable.
- A <u>__drop__</u> occurs if and only if the drag stops within the bounds of another collection in the drag arena, on a specific item or point that is specified as <u>__droppable__</u> within that collection, and on a point in the drag arena which is not specified as being deletable.


###Collections


Classes that conform to the `I3Collection` protocol are our <u>__collections__</u> and should be subclasses of `UIView`. Implementations of `I3Collection` should use `NSIndexPath`s to access their child items for obvious conventional reasons.

The framework comes bundled with some convenient implementations of this protocol in the form of class categories for `UITableView` and `UICollectionView`, but there's no reason why you can't implement your own if required. This is a good example of the framework's loose coupling - its dependent on an abstractions not on concrete types.


###Drag Arena

`I3DragArena` is our <u>__drag arena__</u>. Its only hard dependency is a `superview`, which should be injected via its constructor. You can register collections in the drag arena by adding them to its `collections` property, which is an `NSMutableOrderedSet`.

Note that it is your responsibillity to make sure the following preconditions to using the `I3DragArena` are met:

- That the `superview` is not `nil`
- That in the `superview` is above any view added to the `collections` set in the view heirarchy
- That any instance added to the `collections` set is of the type `UIView<I3Collection>`

The following snippet demonstrates building a `I3DragArena` using the provided `UITableView` collection category:

```Objective-C

#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/I3DragArea.h>

...

/// Dependencies are pulled form somewhere

UIView *superview = ...
UITableView *table1 = ...
UITableView *table2 = ...

/// Create a drag arena

I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:@[table1, table2]];

/// You can manipulate the registered ordered set of collections

UITableView *table3 = ...
UITableView *table4 = ...

[arena.collections addObject:table3];
[arena.collections insertObject:table4 atIndex:1];
[arena.collections removeObjectAtIndex:0];


```

###Gesture Coordinator

The next component is responsible for listening for and coordinating gestures in order to recognize the different drag/drop events: drag <u>__starting__</u>, <u>__dragging__</u>, drag <u>__stopping__</u>, <u>__deletion__</u>, <u>__rearranging__</u> and <u>__dropping__</u>... the `I3GestureCoordinator`.

It has a couple of hard dependencies:

- The `I3DragArena`, which should be injected via the constructor
- A `UIGestureRecongizer` configured to listen to the arena's superview, which can either be injected via the constructor or will be created 'behind the scenes' as a `UIPanGestureRecongizer` if `nil` is passed to the constructor

and a couple of soft dependencies:

- An object implementing the `I3DragDataSource` protocol
- An object implementing the `I3DragRenderDelegate` protocol

###Data Source

Classes that conform to `I3DragDataSource` act as our data sources. This (again, for obvious conventional reasons) closely resembles the data source pattern used by `UITableView`s and `UICollectionView`s.

Our data source is responsible for managing all the data associated with items in the environment's collections. It exposes a set of assertion methods, which are used by the coordinator to determine whether a particular item or point has a particular property. For example the result of:

``` Objective-C
-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection;
```

is used by the coordinator to determine whether a drag can start on particular item at a given index path in a given collection. Typically the implementation of assertion methods do not mutate the state of the data source, that is they should normally provide an interface by which the gesture coordinator can query about _how_ the collections should be handled without having to worry about any side affects.

Our data source also implements some methods for mutating the data, for example:

``` Objective-C
-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection;
```

should be implemented to update the data in the event that an item at `from` is dropped from the `fromCollection` to the item at `to` in the `toCollection`. These methods are called by the gesture coordinator whenever the relevant drag/drop event occurs.

This snippet demonstrates a very basic `I3DragDataSource` implementation that supports <u>__dropping__</u> and <u>__rearranging__</u>:


``` Objective-C

#import <BetweenKit/I3DragDataSource.h>

...

@implementation

#pragma mark - I3DragDataSource assertions


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
	return YES;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
	return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint) at onCollection:(UIView<I3Collection> *)toCollection{
	return YES;
}


#pragma mark - I3DragDataSource update methods


-(NSMutableArray *)dataForCollection:(UIView *)collection{
	return collection == self.leftTable ? self.leftData : self.rightData;
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{

    UITableView *targetTableView = (UITableView *)collection;
    NSMutableArray *targetDataset = [self dataSetForCollection:collection]

    [targetDataset exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [targetTableView reloadRowsAtIndexPaths:@[to, from] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{

    UITableView *fromTable = (UITableView *)fromCollection;
    UITableView *toTable = (UITableView *)toCollection;

    NSMutableArray *fromDataset = [self dataForCollection:fromTable];
    NSMutableArray *toDataset = [self dataForCollection:toTable];
    NSNumber *dropDatum = [fromDataset objectAtIndex:fromIndex.row];

    [fromDataset removeObjectAtIndex:fromIndex.row];
    [toDataset insertObject:dropDatum atIndex:toIndex.row];

    [fromTable deleteRowsAtIndexPaths:@[fromIndex] withRowAnimation:UITableViewRowAnimationFade];
    [toTable insertRowsAtIndexPaths:@[toIndex] withRowAnimation:UITableViewRowAnimationFade];

}

@end

```

A common convention is to implement `I3DragDataSource` in your `UIViewController`.

All data source methods are optional apart from the 'drag start' assertion:

``` Objective-C
-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection
```

Every data update method has an associated assertion method; the gesture coordinator will only respond to an event if and only if, both the update methods and its associated assertion have been implemented. For example, if you implement:

``` Objective-C
-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection
```

but not:

``` Objective-C
-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection
```

then the coordinator will assume that we don't want to rearrange anything.

###Render Delegate

Classes that conform to `I3DragRenderDelegate` are responsible for rendering drag/drop events on-screen.

The framework provides a basic implementation of the `I3DragRenderDelegate` in the form of the `I3BasicRenderDelegate`. There's nothing stopping you extending `I3BasicRenderDelegate` or even implementing your own from scratch by conforming to `I3DragRenderDelegate`.

The gesture coordinator will call the render delegate whenever it wants to render a particularly event. Note that a render delegate may assume that its methods will be called by the coordinator in a specific order and it may manage the lifecycle of its state based on that order. As a general rule, its best never to call the the `I3DragRenderDelegate` methods directly - just let the coordinator call them.

Its also worth noting that the gesture coordinator retains a _strong_ reference to the render delegate to avoid you having to retain it yourself unnecessarily. For this reason, take care when implementing a render delegate that 'knows' about its gesture coordinator and remain mindful of potential retain cycles.

###Setting Up a Drag-and-Drop Environment

So to top it off, here is a snippet demonstrating setting up a drag/drop environment using all of the core components:


``` Objective-C

#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>

...

UIView *superview = ...
id<I3DragDataSource> dataSource = ...

I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:@[collection1, collection2, ...]];
I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:[[UILongPressGestureRecognizer alloc] init]];

coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
coordinator.dragDataSource = dataSource;


```

As you can see, the gesture coordinator is dependent mainly on abstractions (the `I3DragDataSource` protocol, the `I3DragRenderDelegate` protocol, the abstract `UIGestureRecongizer` class, etc.), which leaves room for a great deal of extension.


The `I3GestureCoordinator` provides a couple of helpful factory methods in the form of class methods:

``` Objective-C

+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections withRecognizer:(UIGestureRecognizer *)recognizer;

+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections;

```

You can use these methods in place of all the setup boilerplate where possible, for example

``` Objective-C

MyViewController *viewController = ...
I3DragCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:viewController withCollections:@[collection1, collection2, ...]];

```
___

<u>Documentation</u>: BetweenKit 2.0.0
