#Use Case 2: _Rearrangeable Table View (Sift)_

- Demonstrates 1 `UITableView`
- Uses `UILongPressGestureRecongizer` to detect and coordinate drags
- This table view is rearrangeable - drag and drop the rows to order them
- On drop, the dragging cell is deleted from its origin and inserted into the table at the destination index. The intermediate cells are 'sifted' up one index.
- Drills into `I3BasicRenderDelegate` to turn 'exchange' animation off.
- Recreates the behaviour of the traditional `moving` property of the `UITableView`
