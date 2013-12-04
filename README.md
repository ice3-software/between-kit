iOS Drag-n-Drop Between Helper
==============================

Objective-C helper class(es) for the iOS platform that handle drag and drop logic between 2 UITableView s and/or UICollectionView s.


Installation
------------

To use this in your project, copy the I3DragBetweenHelper class into your project directory - there is no Podspec (at the moment).

This repo also contains and example project where you can see the helper class in action.

This project requires ARC to compile.


Stabillity
----------

At the moment, this helper is not yet stable - use it at your own risk.

Its been tested on iOS 6 and iOS 7 iPads for dragging between a UITableView and a UICollectionView

Use Cases:
- 2 UICollectionViews
- 2 UITableViews
- UITableView as the Src, UICollectionView as the Dst
- UITableView as the Dst, UICollectionView as the Src
- Different exchangeable/draggable configuration for all the above


