#Use Case 11: _3 Collections_

- Demonstrates 3 `I3Collections`: 1 `UITableView` and 2 `UICollectionViews`s. Shows how the coordinator can handle any number of collection views and is no longer constrainted to just a `src` and `dst` view.
- In practice, it may be cleaner just to use 1 `UICollectionView` with a custom layout and multiple sections.
- Uses `UILongPressGestureRecognizer` to detect and coordinate drags.
- All draggable properties: see use cases 5 and 10.
