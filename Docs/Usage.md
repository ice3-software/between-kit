#Usage

###Overview

This document, in tandem with the framework's use cases and unit tests, aims to describe how you can use BetweenKit in your app. It briefly introduces the problem domain and framework components, and then proceeds to explain how to leverage these components with a series of step-by-step usage guides.

###Problem Domain

It isn't particulary easy to build smooth drag-and-drop into your iOS applications, especially when you are dealing with multiple data-view components such as tables and collections. To achieve drag-and-drop in the past I've found myself building complex view controllers that deal with all manner of things including gesture handling, geometric conversion, data manipulation and rendering. The view controllers quickly became difficult to maintain and the unsegregated nature of the drag-and-drop functionallity ment that reusing and extending it was nearly impossible.

`BetweenKit` aims to abstracting away the various `UIKit` interactions required to implement drag-and-drop, and expose a clean API. It relies on a series of premises about drag-and-drop-ing from which we can model the domain:

- A <u>__collection__</u> is a view that contains and array of child <u>__items__</u>
- A <u>__drag arena__</u> consists of a <u>__superview__</u> and an ordered set of <u>__collections__</u> that exist as subviews within that superview.
- The order of the collections in the drag arena determine their drag / drop priority. That is, if a collection sits at the beginning of the drag arena's ordered set of collections, then drags and drops occuring on that collection will be recognized in place of any of the later collections in the set.
- A drag <u>__starts__</u> if and only if a gesture is started within the bounds of a <u>__draggable__</u> item of a collection in the drag arena.
- <u>__Dragging__</u> occurs if and only if, immediately after a drag has been started, the location of the gesture changes within the drag arena.
- A drag <u>__stops__</u> if and only if immediately after dragging the gesture stops, is cancelled or finishes.
- A <u>__deletion__</u> occurs if and only if the drag stops at a point which is specified as being <u>__deleteable__</u>. For example, the user may designate certain bounds within the drag arena to be 'delete on drop' areas.
- A <u>__rearrange__</u> occurs if and only if the drag stops within the bounds of the collection that it started in, on a different item in that collection which is specified as being <u>__rearrangeable__</u>, and on a point in the drag arena that is not specified as being <u>__deleteable__</u>
- A <u>__drop__</u> occurs if and only if the drag stops within the bounds of another collection in the drag arena, on a specific item or point that is specified as <u>__droppable__</u> within that collection, and on a point in the drag arena which is not specified as being <u>__deleteable__</u>.




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