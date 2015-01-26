#What's New###Overview

This document, as the title suggests, details what's new in the  `2.0.0` release of this codebase (`BetweenKit`) and how its moved on since the original `1.0.0` release (`i3-dragndrop`).

We've used the feedback recieved over the past year to re-design the original `i3-dragndrop` helper and develop the concept into a fully-fledged user interface framework for iOS. An unfortunate caveat is that `BetweenKit` is completely backwards in-compatible with the `i3-dragndrop` helper, which has now deprecated.

Hopefully this guide will provide some useful pointers for migrating your codebase to the new release.
###Protocols

Originally, there was but 1 protocol: the `I3DragBetweenDelegate`. The design of this protocol was fraught with redundancy.

Well no more! We have 2 replacement protocols for you:

- `I3Collection`
- `I3DragDataSource`

`I3Collection`s are the dynamic replacement for the old `dstView` and `srcView`s, which could only be either of type `UICollectionView` or `UITableView`. We've variablized the concepts `dst` and `src` such that you can have any number of collection views on your screen, and you can even implement your own. As long as they are of type `UIView<I3Collection>`, you're good to go.

The `I3DragDataSource` is the shiny new replacement for the `I3DragBetweenDelegate`, which clearly defines 2 sets of methods: assertions and mutations. 

The the assertion methods can be loosely mapped from the `I3DragBetweenDelegate` to the `I3DragDataSource` as follows: 

	isCell... -> can...

The responsibillity of mutating the data source wasn't really well defined in the original `I3DragBetweenDelegate` and is much harder to map.

The 'rendering' capabillities of the codebase were also completely private, and there was no way of extending how drag-and-drops _looked and felt_ on the screen. As the `I3DragBetweenDelegate` did not expressly define extension points the only way one could customize the drag-and-drop rendering would be to extend the `I3DragBetweenDelegate` and start hack-ily overriding private methods. 

Now we have the `I3DragRenderDelegate` protocol, which will allow you to completely customize how the rendering of the drag-and-drops is dealt with is you so desire.
###Drops
Details about how drops can now both be recognized as being on a particular item in a collection or at a particular points (addressing various concerns)###Collections

Details about how there are now much less hard coded constraint in place for collections. 

- They can be anything that implementings I3Collection- You can add as many as you want
- Collection priority as order in the aren'a mutable ordered set. Allows great control over overlapping collections
Compare how the helper only allowed you to add 2 collections of predefined types.###Gesture Recongizer
Can be injected, so:
- you can use any type of recognizer
- have great control over how that recongizer is dealt with along side other gesture recongizers

Note editing / moving


###Cloning Instabillity

Note how the previous helper's use of key archiver / unarchiver caused frequent crashes and issues with custom table view and collection view cells.

Now we're using a much more robust method of cloning items: rendering into a uiimage using the clone view.

Details...


###Re-designed

- Redesigned the framework from the ground up to adhere to SOLID design principals
- Fully testable
- More extensible, customizable
- Caveat is that its completely backwards incompatible, anyone using the helper will have to migrate to using the helper
___<u>Documenation</u>: BetweenKit 2.0.0