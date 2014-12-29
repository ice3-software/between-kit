
//
//  TableViewCellAware.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

/**
 
 Simple protocol that defines how UI components, intended to be used inside of 
 a `UITableViewCell`s content view, should reference their parent cell.
 
 The reason for this protocol is that when we assign a target / action to a
 component inside a `UITableViewCell`, in the action we will need to determine
 on which cell the given component was interacted with.
 
 Take, for example, a `UIButton` in a `UITableViewCell`. Say we have the following
 in our view controller:
 
 
 ```Objective-C
 
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
     SpecialButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCellIdentifier" forIndexPath:indexPath];
     
     [buttonCell.button addTarget:self action:@selector(handleCellButtonPress:) forControlEvents:UIControlEventTouchUpInside];
     
     return buttonCell;

 }
 
 -(void) handleCellButtonPress:(UIButton *)button{
    
    /// I need to update the data source somehow. How do I know on which index path
    /// the cell containing the button sits?
 
 }
 
 ```
 
 In the `handleCellButtonPress:` method, there is no clean way for us to determine 
 the index path of the cell form which the `UIControlEventTouchUpInside` originates.
 
 If we subclass `UIButton` to implement this protocol, and configure the cell so that
 it has a weak reference to its parent cell, it becomes much easier...
 
 
 ```Objective-C
 
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    SpecialButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCellIdentifier" forIndexPath:indexPath];
     
    /// @note It would be much cleaner to make this assignment in the impl of 
    /// `SpecialButtonCell`
 
    buttonCell.cellAwareButton.parentCell = buttonCell;
 
    [buttonCell.cellAwareButton addTarget:self action:@selector(handleCellButtonPress:) forControlEvents:UIControlEventTouchUpInside];
     
    return buttonCell;
 
 }
 
 -(void) handleCellButtonPress:(ParentAwareButton *)button{
 
    /// Now I can grab the index path directly from the parentCell reference
 
    NSIndexPath *index = [self.tableView indexPathForCell:button.parentCell];
 
    /// Update the data source however...
 
 }
 
 ```
 
 That's my approach anyway. Seems to work nicely.
 
 */
@protocol ParentCellAware <NSObject>

@required

@property (nonatomic, weak) UITableViewCell *parentCell;

@end