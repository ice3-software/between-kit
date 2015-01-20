#Usage

###Overview

This document, in tandem with the framework's use cases and unit tests, aims to describe how you can use BetweenKit in your app. It briefly introduces the problem domain and framework components, and then proceeds to explain how to leverage these components with a series of step-by-step usage guides.

###Problem Domain

It isn't particulary easy to build smooth drag-and-drop into your iOS applications, especially when you are dealing with multiple data-view components such as tables and collections. To achieve drag-and-drop in the past I've found myself building complex view controllers that deal with all manner of things including gesture handling, geometric conversion, data manipulation and rendering. The view controllers quickly became difficult to maintain and the unsegregated nature of the drag-and-drop functionallity ment that reusing and extending it was nearly impossible.

###Premises

`BetweenKit` aims to abstracting away the various `UIKit` interactions required to implement drag-and-drop, and expose a clean API. It relies on a series of premises about drag-and-drop-ing from which we can model the domain:

- A <u>__collection__</u> is a view that contains and array of child <u>__items__</u>
- A <u>__drag arena__</u> consists of a <u>__superview__</u> and an ordered set of <u>__collections__</u> that exist as subviews within that superview.
- The order of the collections in the drag arena determine their drag / drop priority. That is, if a collection sits at the beginning of the drag arena's ordered set of collections, then drags and drops occuring on that collection will be recognized in place of any of the later collections in the set.
- A drag <u>__starts__</u> if and only if a gesture is started within the bounds of a <u>__draggable__</u> item of a collection in the drag arena.
- <u>__Dragging__</u> occurs if and only if, immediately after a drag has been started, the location of the gesture changes within the drag arena.
- A drag <u>__stops__</u> if and only if immediately after dragging the gesture stops, is cancelled or finishes.
- A <u>__deletion__</u> occurs if and only if the drag stops at a point which is specified as being <u>__deleteable__</u>. For example, the user may designate certain bounds within the drag arena to be 'delete on drop' areas.
- A <u>__rearrange__</u> occurs if and only if the drag stops within the bounds of the collection that it started in, on a different item in that collection which is specified as being <u>__rearrangeable__</u>, and on a point in the drag arena that is not specified as being deleteable.
- A <u>__drop__</u> occurs if and only if the drag stops within the bounds of another collection in the drag arena, on a specific item or point that is specified as <u>__droppable__</u> within that collection, and on a point in the drag arena which is not specified as being deleteable.


###Core Components

Classes that conform to the `I3Collection` protocol are our <u>__collections__</u>, and should be subclasses of `UIView`. Implementations of `I3Collection` should use `NSIndexPath`s to access its child items for obvious conventional reasons.

The framework comes bundled with some convenient implementations of this protocol in the form of class categories for `UITableView` and `UICollectionView`, but there's no reason why you can't implement your own if required. This is a good example of the framework's loose coupling - its dependent on an interface not on concrete types.

`I3DragArena` is our <u>__drag arena__</u>. Its only hard dependency is a `superview` which should be injected via its constructor. You can register collections in the drag arena by adding them to its `collections` property, which is an `NSMutableOrderedSet`.

Note that it is your responsibillity to make sure the following preconditions to using the `I3DragArena` are met:

- That the `superview` is not `nil`
- That the `superview` is a eventual superview of any view added to the `collections` set
- That any instance added to the `collections` set is of the type `UIView<I3Collection>`

The following snippet demonstrates building a `I3DragArena` using the provided `UITableView` category implementations:

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

The next component is responsible for listening for and coordinating gestures in order to recognize the drag/drop events defined in the premises.

It has a couple of hard dependency: 

- the drag arena which should be injected via the constructor
- a `UIGestureRecongizer` configured to listen to the arena's superview, which can either be injected or will be created 'behind the scenes' as a `UIPanGestureRecongizer` if `nil` is passed

And a couple of soft dependencies:

- an object implementing the `I3DragDataSource` protocol
- an object implementing the `I3DragRenderDelegate` protocol

Classes that conform to `I3DragDataSource` act as our data sources. This (again, for obvious convential reasons) closely resembles the data source pattern used by `UITableView`s and `UICollectionView`s. 

Our data source is repsonsible for managing all the data associated with items in the environment's collections. It exposes a set of assertion methods, which are used to by the coordinator to determine whether a particular item or point has a particular property. For example the results of

``` Objective-C
-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection;
```

is used by the data source to determine whether a drag can start on particular item at a given index path in a given collection. Typically the implementation of assertion methods do not mutate the object, that is they should normally provide an interface by which the gesture coordinator can query how the collections should be handled without having to worry about side affects.

Our data source also implements some methods for mutating the data, for example

``` Objective-C
-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection;
```

should be implemented to update the data in the event that an item at `from` is dropped from the `fromCollection` to the item at `to` in the `toCollection`. These methods are called by the gesture coordinator whenever the relevant drag/drop event occurs.

This snippet demonstrates a very basic examples of an `I3DragDataSource` implementation


``` Objective-C

#import.... 

...

@implementation

...


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


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    UITableView *targetTableView = (UITableView *)collection;
    NSMutableArray *targetDataset = targetTableView == self.leftTable ? self.leftData : self.rightData;
    
    [targetDataset exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [targetTableView reloadRowsAtIndexPaths:@[to, from] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{
    
    UITableView *fromTable = (UITableView *)fromCollection;
    UITableView *toTable = (UITableView *)toCollection;
    
    /** Determine the `from` and `to` datasets */
    
    BOOL isFromLeftTable = fromTable == self.leftTable;
    
    NSNumber *exchangingData = isFromLeftTable ? [self.leftData objectAtIndex:fromIndex.row] : [self.rightData objectAtIndex:fromIndex.row];
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    NSMutableArray *toDataset = isFromLeftTable ? self.rightData : self.leftData;
    
    
    /** Update the data source and the individual table view rows */
    
    [fromDataset removeObjectAtIndex:fromIndex.row];
    [toDataset insertObject:exchangingData atIndex:toIndex.row];
    
    [fromTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:fromIndex.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [toTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:toIndex.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
}

```





- Preconditions / Postconditions
- Secondary / Utility Components

###Setting up a Drag/Drop Environment

- Using helper class methods
- What assumptions do these methods make?

- From scratch
- When would one want to set one up from scratch instead of using the class methods?

###Implementing a data source

- A data source is required
- How does one implement a data source?
- Which methods should one implement?
- Which methods are optional?

###Collections

- Go into detail about the existing class categories
- The ins-and-outs of what you can do with them
- Maybe even implementing your own... ?

###Custom Rendering

- Point to use case
- Extending basic delegate
- Conforming to the delegate protocol

___

<u>Documenation</u>: BetweenKit 2.0.0