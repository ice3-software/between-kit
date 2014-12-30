//
//  ViewController.m
//  18. Paint Me
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "PaintMeViewController.h"
#import "Note.h"
#import <BetweenKit/I3BasicRenderDelegate.h>
#import <BetweenKit/I3GestureCoordinator.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface PaintMeViewController ()

@property (nonatomic, strong) NSMutableArray *notes;

@property (nonatomic, strong) NSArray *colours;

@property (nonatomic, strong) I3GestureCoordinator *coordinator;

@end


@implementation PaintMeViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
 
    
    /// Calculate colours using the HSB colour space
    
    NSMutableArray *colours = [[NSMutableArray alloc] init];
    
    for(CGFloat h = 0.005; h <= 1.0; h += 0.05){
        
        UIColor* light = [UIColor colorWithHue:h saturation:1 brightness:1 alpha:1];
        UIColor* dark = [UIColor colorWithHue:h saturation:0.7 brightness:1 alpha:1];
        
        [colours addObject:light];
        [colours addObject:dark];
        
    }
    
    self.colours = [NSArray arrayWithArray:colours];
    
    
    /// Create a load of arbitrary notes
    
    self.notes = [NSMutableArray arrayWithArray:@[
                   [[Note alloc] initWithTitle:@"Determine the ideal date"],
                   [[Note alloc] initWithTitle:@"Create a guest list"],
                   [[Note alloc] initWithTitle:@"Send out invitiations"],
                   [[Note alloc] initWithTitle:@"Buy chips and other nibbles"],
                   [[Note alloc] initWithTitle:@"Ask Dom if he wants to be a the DJ"],
                   [[Note alloc] initWithTitle:@"Ask Elliot to bring his supreme crack fox humour"],
                   [[Note alloc] initWithTitle:@"Other 5 crates of premium vodka"],
                   [[Note alloc] initWithTitle:@"Tell the neighbours to expect 'loud noise and maybe some fire'"],
                   ]];

    
    /// Setup drag coordinator and collections
    
    [self.notesTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.palletCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    
    self.coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.palletCollection, self.notesTable]];
    
    I3BasicRenderDelegate *renderDelegate = (I3BasicRenderDelegate *)self.coordinator.renderDelegate;
    renderDelegate.rearrangeIsExchange = NO;
    renderDelegate.draggingItemOpacity = 0.5;
    
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


// ...


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return self.notes.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    Note *note = self.notes[indexPath.row];
    
    cell.backgroundColor = note.colour;
    cell.textLabel.text = note.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    return self.colours.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell forIndexPath:indexPath];
    cell.backgroundColor = self.colours[indexPath.item];
    
    return cell;
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    return self.palletCollection == (UICollectionView *)fromCollection && self.notesTable == (UITableView *)toCollection;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    return collection == self.notesTable;
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    UIColor *colour = [self.colours objectAtIndex:from.item];
    Note *note = [self.notes objectAtIndex:to.row];
    
    note.colour = colour;
    [self.notesTable reloadItemsAtIndexPaths:@[to]];
    
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    Note *note = self.notes[from.row];
    [self.notes removeObject:note];
    [self.notes insertObject:note atIndex:to.row];
    
    [self.notesTable beginUpdates];
    [self.notesTable deleteItemsAtIndexPaths:@[from]];
    [self.notesTable insertRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationNone];
    [self.notesTable endUpdates];
    
}


@end
