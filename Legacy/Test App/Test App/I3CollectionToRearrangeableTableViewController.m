//
//  I3CollectionToRearrangeableTableViewController.m
//  Test App
//
//  Created by Stephen Fortune on 06/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3CollectionToRearrangeableTableViewController.h"


static NSString* DequeueReusableCell = @"DequeueReusableCell";


/* The keys for the rightData dictionary objects */

static NSString* kCellMetaKeyColor = @"kCellMetaKeyColor";
static NSString* kCellMetaKeyText = @"kCellMetaKeyText";

#define CELL_CLEAN_COLOR [UIColor whiteColor]


@interface I3CollectionToRearrangeableTableViewController()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

/* Dummy data */

/** This is an array of NSDictionary s. Each dictionary contains metadata about the 
     cell, in the form:
 
    {
        kCellMetaKeyColor : [UIColor exampleColor],
        kCellMetaKeyText : @"Example string",
    }
 
 */

@property (nonatomic, strong) NSMutableArray* rightData;

/** An array of colors to drag onto the table */

@property (nonatomic, strong) NSArray* leftData;

@end


@implementation I3CollectionToRearrangeableTableViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    
    /* All the colors in the pallet you can use to paint with */
    
    self.leftData = @[
                      [UIColor redColor],
                      [UIColor greenColor],
                      [UIColor blueColor],
                      [UIColor yellowColor],
                      [UIColor orangeColor],
                      [UIColor purpleColor],
                      [UIColor lightGrayColor],
                      [UIColor grayColor],
                      [UIColor darkGrayColor],
                      ];
    
    /* The paintable cell data objects
     
       NOTE: Ideally, this would not be an array of nested dictionaries, but an array
        of data entity objects with text and color properties. */
    
    NSArray* rightData = @[
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 1",
                                                                           }
                            ],
                           
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 2",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 3",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 4",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 5",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 6",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 7",
                                                                           }
                            ],
                           [NSMutableDictionary dictionaryWithDictionary:@{
                                                                           kCellMetaKeyColor : CELL_CLEAN_COLOR,
                                                                           kCellMetaKeyText : @"Paintable Cell 8",
                                                                           }
                            ],
                           ];
    
    self.rightData = [NSMutableArray arrayWithArray:rightData];
    
    
    [self.leftCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.leftCollection
                                                         dstView:self.rightTable];
    
    self.helper.delegate = self;
    
    self.helper.isSrcRearrangeable = NO;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.hideSrcDraggingCell = NO;
    
    self.helper.isDstRearrangeable = YES;
    self.helper.doesDstRecieveSrc = YES;
    self.helper.hideDstDraggingCell = YES;
    
    
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}



#pragma mark - Drag n drop exchange and rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    [self.rightData exchangeObjectAtIndex:toIndex withObjectAtIndex:fromIndex];
    
}

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from{
    
    
    /* Grab the appropriate data */
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    UIColor* colorFromPallet = [self.leftData objectAtIndex:fromIndex];
    
    
    /* Update the data and collections accordingly */
    
    NSMutableDictionary* rightCellData = [self.rightData objectAtIndex:toIndex];
    [rightCellData setObject:colorFromPallet forKey:kCellMetaKeyColor];
    
    [self.rightTable reloadRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationFade];
        
    
}

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from{

    /* Here we're going to 'clean' the cell before its snapped back. */
    
    NSInteger fromIndex = (from.item);
    NSMutableDictionary* rightCellData = [self.rightData objectAtIndex:fromIndex];
    [rightCellData setObject:CELL_CLEAN_COLOR forKey:kCellMetaKeyColor];
    
    /* NOTE: We're not updating the cell here - its been hidden so the affects
        won't be visible. Instead we reload the cell in dragFromDstSnappedBackFromIndexPath */
    
    return YES;
}

-(void) dragFromDstSnappedBackFromIndexPath:(NSIndexPath*) path{

    /* Reload the newly cleaned cell once its snapped back. */
    
    [self.rightTable reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
}



#pragma mark - Collection view delegate and datasource implementations


-(NSInteger) collectionView:(UICollectionView*) collectionView numberOfItemsInSection:(NSInteger) section{
    
    return self.leftData.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView*) collectionView cellForItemAtIndexPath:(NSIndexPath*) indexPath{
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell
                                                                           forIndexPath:indexPath];
    cell.backgroundColor = [self.leftData objectAtIndex:indexPath.item];
    
    return cell;
}


#pragma mark - Table view delegate and datasource implementations


-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section{
    
    return [self.rightData count];
}


-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell
                                                            forIndexPath:indexPath];
    
    
    NSInteger row = [indexPath row];
    
    /* Grab the cell metadata from its associative dictionary and apply it */
    
    NSDictionary* cellMetadata = [self.rightData objectAtIndex:row];
    NSString* cellString = [cellMetadata objectForKey:kCellMetaKeyText];
    UIColor* cellColor = [cellMetadata objectForKey:kCellMetaKeyColor];
    
    cell.textLabel.text = cellString;
    cell.textLabel.backgroundColor = cellColor;
    cell.contentView.backgroundColor = cellColor;
    
    return cell;
}

@end
