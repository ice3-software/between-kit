#What's New

This document, as the title suggests, details what's new in the  `2.0.0` release of this codebase (`BetweenKit`) and how its moved on since the original `1.0.0` release (`i3-dragndrop`).

We've used the feedback recieved over the past year to re-design the original `i3-dragndrop` helper and develop the concept into a fully-fledged user interface framework for iOS. An unfortunate caveat is that `BetweenKit` is completely backwards in-compatible with `i3-dragndrop`, which has now deprecated.

Hopefully this guide will provide some useful pointers for migrating your codebase to the new release.


Originally, there was but 1 protocol: the `I3DragBetweenDelegate`. The design of this protocol was fraught with redundancy.

Well no more! We have 2 replacement protocols for you:

- `I3Collection`
- `I3DragDataSource`

`I3Collection`s are the dynamic replacement for the old `dstView` and `srcView`s, which could only be either of type `UICollectionView` or `UITableView`. We've variablized the concepts `dst` and `src` such that you can have any number of collection views on your screen, and you can even implement your own. As long as they are of type `UIView<I3Collection>`, you're good to go. 

By registering your collections with the `I3DragArena` in a particular order, you can also control their drag-and-drop priority.
 
__This resolves: #5, #6, #7, #16 and #22__

The `I3DragDataSource` is the shiny new replacement for the `I3DragBetweenDelegate`, which clearly defines 2 sets of methods: assertions and mutations. 

The the assertion methods can be loosely mapped from the `I3DragBetweenDelegate` to the `I3DragDataSource` as follows: 

	isCell... -> can...

The responsibillity of mutating the data source wasn't really well defined in the original `I3DragBetweenDelegate` and is much harder to map. 

__This resolves:  #15__

The 'rendering' capabillities of the codebase were also completely private, and there was no way of extending how drag-and-drops _looked and felt_ on the screen. As the `I3DragBetweenDelegate` did not expressly define extension points the only way one could customize the drag-and-drop rendering would be to extend the `I3DragBetweenDelegate` and start hack-ily overriding private methods. 

Now we have the `I3DragRenderDelegate` protocol, which will allow you to completely customize how the rendering of the drag-and-drops is dealt with is you so desire.



- Drops on a specific point in a collection

Which means that now, you can drop things on the empty part of your collections! The previous suggested work-around to this limitation was to add a static 'placeholder' cell to your collection and configure it to recieve drops. No longer a problem.

__This resolves: #15__




###Cloning Instabillity

This was clearly a massive issue with `i3-dragndrop`: we used the `NSKeyArchiver` and `NSKeyUnarchiver` to create copies of the dragging item in question. It often caused hard crashes due to various conflicting `UIView` properties and also made it very difficult to create your own subclasses of `UITableViewCell` to drag about.

We've fixed that now with the use of the new `I3CloneView`. This class simply renders the given `sourceView` into a `UIImage` off-screen and then renders the `UIImage` into its frame on `drawRect`, which so far, has worked pretty flawlessly.

__This resolves: #8, #23, #12, #29__
