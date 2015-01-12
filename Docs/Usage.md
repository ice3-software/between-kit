#Usage

###Overview

This document, in tandem with the framework's use cases and unit tests, aims to describe how you can use BetweenKit in your app. It briefly introduces the problem domain and framework components, and then proceeds to explain how to leverage these components with a series of step-by-step usage guides.

###Problem Domain

It isn't particulary easy to build smooth drag-and-drop into your iOS applications, especially when you are dealing with multiple data-view components such as tables and collections. To achieve drag-and-drop in the past I've found myself building complex view controllers that deal with all manner of things including gesture handling, geometric conversion, data manipulation and rendering. The view controllers quickly became difficult to maintain and the tightly coupled nature of the drag-and-drop functionallity ment that reusing and extending it was impossible.

`BetweenKit` aims to abstracting away the various `UIKit` interactions required to implement drag-and-drop, and expose a clean API.

`BetweenKit` relies on a series of premises about drag-and-drop-ing from which we model the domain.

######Drag Start

- Gesture started: `GestureStarted`
- Gesture started within bounds of collection: `StartedInCollection`
- Gesture started within bounds of an item in collection: `StartedInItem`
- Gesture started within bounds of an item only if its in the bounds of a collection: 
		
		StartedInItem → StartedInCollection

- Item in collection is draggable: `ItemDraggable`
- Drag started: `DragStarted`
- A drag started if and only if a gesture starts within the coordinates of a draggable item in a collection:
	
		DragStarted ⇔ GestureStarted ∧ StartedInItem ∧ ItemDraggable

- Gesture is being performed: `GesturePerforming`
- Dragging occurs if and only if a drag has started and a gesture is currently being performed: 

		Dragging ⇔ GesturePerforming ∧ DragStarted

- Gesture stops: `GestureStop`
- Drag stops if and only if a drag has been started and a gesture stops:

		DragStop ⇔ DragStarted ∧ GestureStop

- Gesture is at deleteable point: `AtDeleteablePoint`
- Item is deleted if a drag stops at a point that is deletable:

		DragStop ∧ AtDeleteablePoint → Delete 

- Gesture stops within bounds of a collection: `StopsInCollection`
- Gesture stops within a different collection to which it started in: `StopsInNewCollection`
- Gesture can stop in new collection only if it stops in a collection

		StopsInNewCollection → StopsInCollection

- Gesture stops within bounds of item of collection: `StopsInItem`
- Gesture stops within bounds of an item only if its in the bounds of a collection: 
		
		StopInItem → StopInCollection

- Gesture stops within bounds of the same item as it started on: `StopInSameItem`
- Gesture stops within bounds of the same item only if it stops within the same collection

		¬StopsInNewCollection →

- Items are rearranged in a collection if a drag has been started, the gesture stops at a point in the same collection as it started, the gesture stops in an item in the collection and the item  is not the item as where the gesture started:

		DragStop ∧ StopInSameCollection → Rearrange


- Core Components
- Interfaces and boundaries
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