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
    
    self.firstSectionData = [NSMutableArray arrayWithArray:@[
                                                             @"1st section - 1",
                                                             @"1st section - 2",
                                                             @"1st section - 3",
                                                             @"1st section - 4",
                                                             @"1st section - 5",
                                                             @"1st section - 6",
                                                             ]];
    
    self.secondSectionData = [NSMutableArray arrayWithArray:@[
                                                             @"2nd section - 1",
                                                             @"2nd section - 2",
                                                             @"2nd section - 3",
                                                             @"2nd section - 4",
                                                             @"2nd section - 5",
                                                             @"2nd section - 6",
                                                             ]];
}
     

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


#pragma mark - UICollectionViewDataSource


-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return section ? self.secondSectionData.count : self.firstSectionData.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    I3SubtitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.title.text = indexPath.section ? self.secondSectionData[indexPath.row] : self.firstSectionData[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

//...

@end
