//
//  I3DetailViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3DetailViewController.h"
#import "I3SubtitleCollectionViewCell.h"


@interface I3DetailViewController ()

@end


@implementation I3DetailViewController


- (void)viewDidLoad {

    [super viewDidLoad];
    
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setSectionInset:UIEdgeInsetsMake(30, 0, 30, 0)];
    [self.collectionView registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    
    self.data = [NSMutableArray arrayWithArray:@[
                                                 @"Detail - 1",
                                                 @"Detail - 2",
                                                 @"Detail - 3",
                                                 @"Detail - 4",
                                                 @"Detail - 5",
                                                 @"Detail - 6",
                                                 ]];
    
}
     

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


#pragma mark - UICollectionViewDataSource


-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    I3SubtitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.title.text = self.data[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

//...

@end
