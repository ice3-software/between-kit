#Use Case 10: _2 Collection Views All Properties_

- Demonstrates 2 `UICollectionViews`s
- Uses `UILongPressGestureRecognizer` to detect and coordinate drags
- All draggable properties: droppable, rearrangeable, deletable
- Customizes the rendering by drilling down into the `I3BasicRenderDelegate`
- Different cells are configured to respond differently to drags:
	- Green can be moved but not deleted
	- Blue can be moved and deleted
	- Reds can't be manipulated
