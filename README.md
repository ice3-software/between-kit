iOS Drag-n-Drop Between Helper
==============================

Objective-C helper class(es) for the iOS platform that handle drag and drop logic between 2 UITableView s and/or UICollectionView s.


Installation
------------

To use this in your project, copy the I3DragBetweenHelper class into your project directory - there is no Podspec (at the moment).

This repo also contains and example project where you can see the helper class in action.

This project requires ARC to compile.


Basic Usage
-----------

The helper has requires 2 view objects to be inejcted as the dragging targets:

- The source view. This must be either a UITableView or a UICollectionView
- The destination view. This, like the source, must either be a UITableView or a UICollectionView

These are the views the which we will drag items between.

The helper also requires a 'superview' UIView to be injected. This is the view that contains both of the dragging target views.
The UIPanGestureRecognizer is attached to this view by the helper and this view's frame is where all panning events are listened for.

Here is a simple example of how to configure the helper:

	UIView* view = self.view // View controller's main view
	UITableView* sourceTable = self.sourceTable; // A table configured for the View controller via IB
	UITableView* destinationTable = self.destinationTable // A table configured for the View controller via IB
	
	I3DragBetweenHelper* helper = [[I3DragBetweenHelper alloc] initWithSuperview:view 
                                						 				 srcView:sourceTable
                                               						  	 dstView:destinationTable];

Now we have a helper configured to act on the appropriate view objects, but it doesn't do much. Next we need to implement a delegate for the Helper, so that we can deal with dropping events appropriately:

	helper.delegate = self; // The UIViewController must implement the I3DragBetweenDelegate protocol

See the various example cases for how to actually implement I3DragBetweenDelegate methods and further configure the helper to do cool things.



Stabillity
----------

At the moment, this helper is not yet stable - use it at your own risk.

Its been tested on iOS 6 and iOS 7 iPads for dragging between a UITableView and a UICollectionView.

Below are the test/example cases included in the project.

######Example Case 1 - I32RearrangeableTablesViewController######
- 2 Table Views
- Src table does not accept cells from the Dst table
- Dst table does not accept cells from the Src table
- Src table is rearrangeable
- Dst table is rearrangeable
- Also demonstrates how to 'hide' the cell that's being dragged whlist its dragging

######Example Case 2 - I32ExchangeableTableViewsController######
- 2 Table Views
- Src table accepts cells from the Dst table
- Dst table accepts cells from the Src table
- Src table is not rearrangeable
- Dst table is not rearrangeable

######Example Case 3 - I32RearrangeableExchangeableTablesViewController######
- 2 Table Views
- Src table accepts cells from the Dst table
- Dst table accepts cells from the Src table
- Src table is rearrangeable
- Dst table is rearrangeable
- Both tables contain 1 cell that isn't draggable but is rearrangeable
- Both tables contain 1 cell that isn't rearrangeable but is draggable
- Both tables contain 1 cell that is neither draggable nor rearrangeable

######Example Case 4 - I3UnrearrangebleTableToTableViewController######
- 2 Table Views
- Src table does not accept cells from the Dst table
- Dst table accepts cells from the Src table
- Src table is not rearrangeable
- Dst table is rearrangeable
- Dst table contains 1 undraggable, unrearrangeable placeholder cell
- If a cell from the Dst table is dragged outside of the table is is removed

######Example Case 5 - I32ExchangeableCollectionViewsController######
- 2 Collection Views
- Src accepts cells from Dst
- Dst accepts cells form Src
- Src is rearrangeable
- Dst is rearrangeable
- Both collections contain 1 cell that is neither draggable nor rearrangeable


Recent Changes
--------------

- The helper no longer uses the actual sub view for the dragging cell - now, instead it generates a dummy cell for dragging. Its left up to the user to 'hide' the cell whlist its being dragged in the appropriate delegate methods, see Example Case 1. This breaks anything using the previous version.



Notes on App Store Approval
---------------------------

I haven't used this helper in an App Store approved project yet - the rearranging functionallity is already built into UITableView/UICollectionView s in the form of 'Edit mode', and I have no idea how Apple will respond to this ad-hoc approach to rearranging table/collection views. It might _just_ be a cause for rejection, but who knows..

Just something to bear in mind.
