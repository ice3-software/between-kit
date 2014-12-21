#Use Case 6: _7. Rearrangeable Collection View (Sift)_

- Demonstrates 1 `UICollectionView`
- Uses `UILongPressGestureRecongizer` to detect and coordinate drags
- This collection view is rearrangeable - drag and drop the rows to order them
- On drop, the dragging cell is deleted from its origin and inserted into the collection at the destination index. The intermediate cells are 'sifted' up one index.
- Drills into `I3BasicRenderDelegate` to turn 'exchange' animation off.
- Recreates the behaviour of the traditional `moving` property of the `UICollectionView`
