#Use Case 19: _Fluid UI_

- Demonstrates how one might use `BetweenKit` to build a completely customizable user interface.

- 2 'toolbar' collection views, one containing arbitrary icons (top left) and another containing a series of '+' icons (bottom).

- All the icons can be rearranged as well as dropped between the 2 toolbars.

- When selected, arbitrary icons will just show an alert view with some simple text inside. These are the available arbitrary icons:

	- Comments
	- Cube
	- Bomb
	- Bug
	- Bell

- The different flavours of '+' icons will add different form fields to the third collection in the UI: the table view in the centre of the page.

- The table view in the centre is a customizable form - as noted above, users can use the 4 '+' icons to add different types of fields to the form table:

	- Button fields
	- Switch fields
	- Text fields
	- Text areas

- Once added, the position of these custom form fields can be  changed within the form or they can be deleted via the 'Scrap Field' area.

- Note that this uses the `UILongPressGestureRecognizer` to detect drags; dragging in the form fields can only be initiated inside of their 'move' icons.

- Currently very limited and fraught with user experience issues.
