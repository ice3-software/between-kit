//
//  I3NetworkingDropViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3NetworkingDropViewController.h"
#import "I3GistService.h"
#import "I3GistCollectionViewCell.h"
#import "I3AvailableGistCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


NSString *const kInsertedGistIdentifier = @"kInsertedGistIdentifier";


@interface I3NetworkingDropViewController ()

@property (nonatomic, strong) NSArray *availableGists;

@property (nonatomic, strong) NSMutableArray *userGists;

@property (nonatomic, strong) I3GistService *gistService;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end

@implementation I3NetworkingDropViewController


-(void) viewDidLoad{

    [super viewDidLoad];
    
    [self.availableGistCollection registerNib:[UINib nibWithNibName:I3AvailableGistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3AvailableGistCollectionViewCellIdentifier];
    [self.userGistCollection registerNib:[UINib nibWithNibName:I3GistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3GistCollectionViewCellIdentifier];
    
    self.userGists = [[NSMutableArray alloc] init];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.availableGistCollection, self.userGistCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    ((I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate).draggingItemOpacity = 0.4;
    
}


-(void) viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self initialiseAvailableGists];

}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    NSLog(@"How many have we got ? %d", [self dataForCollection:collectionView].count);
    return [self dataForCollection:collectionView].count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *data = [self dataForCollection:collectionView];

    if(collectionView == self.availableGistCollection){
    
        I3AvailableGistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3AvailableGistCollectionViewCellIdentifier forIndexPath:indexPath];
        
        I3Gist *gist = [data objectAtIndex:indexPath.item];

        cell.descriptionLabel.text = [self politeString:gist.gistDescription];
        
        return cell;

    }
    else{
        
        I3GistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3GistCollectionViewCellIdentifier forIndexPath:indexPath];
        I3Gist *gist = [data objectAtIndex:indexPath.item];
        
        cell.descriptionLabel.text = [self politeString:gist.gistDescription];
        cell.createdAtLabel.text = [self politeString:gist.formattedCreatedAt];
        cell.ownerUrlLabel.text = [self politeString:gist.ownerUrl];
        cell.commentsCountLabel.text = [self politeString:[gist.commentsCount stringValue]];
        cell.backgroundColor = gist.state == I3GistStateFailed ? [UIColor redColor] : [UIColor lightGrayColor];
        
        CGFloat labelAlpha;
        
        if(gist.state == I3GistStateDownloading || gist.state == I3GistStateFailed){
            [cell.downloadingIndicator startAnimating];
            labelAlpha = 0.1;
        }
        else{
            [cell.downloadingIndicator stopAnimating];
            labelAlpha = 1;
        }

        cell.descriptionLabel.alpha = labelAlpha;
        cell.createdAtLabel.alpha = labelAlpha;
        cell.ownerUrlLabel.alpha = labelAlpha;
        cell.commentsCountLabel.alpha = labelAlpha;

        return cell;

    }
}


#pragma mark - Helpers


-(NSString *)politeString:(NSString *)string{
    return !string || [string isEqualToString:@""] ? @"Unknown" : string;
}


-(NSIndexPath *)indexPathForUserGist:(I3Gist *)gist{
    return [NSIndexPath indexPathForItem:[self.userGists indexOfObject:gist] inSection:0];
}


-(NSArray *)dataForCollection:(UICollectionView *)collection{
    return collection == self.userGistCollection ? self.userGists : self.availableGists;
}


-(void) initialiseAvailableGists{

    self.gistService = [[I3GistService alloc] init];
    
    [self.gistService findGistsWithCompleteBlock:^(NSArray *gists) {
        
        self.availableGists = gists;
        [self.availableGistCollection reloadData];
        
    } withFailBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Failed to retrieve Gists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }];

}


-(void) deleteCellForGist:(I3Gist *)gist{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSIndexPath *indexAfterHighlight = [self indexPathForUserGist:gist];
        
        [self.userGists removeObjectAtIndex:indexAfterHighlight.item];
        [self.userGistCollection deleteItemsAtIndexPaths:@[indexAfterHighlight]];
        
    });

}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return collection == self.availableGistCollection;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:self.userGists.count inSection:0];
    I3Gist *emptyGist = self.availableGists[from.row];
    I3Gist *userGist = [emptyGist copy];
    
    [self.userGists addObject:userGist];
    [self.userGistCollection insertItemsAtIndexPaths:@[toIndex]];

    [self.gistService downloadFullGist:userGist withCompleteBlock:^{
        
        NSIndexPath *indexOnDownload = [self indexPathForUserGist:userGist];
        [self.userGistCollection reloadItemsAtIndexPaths:@[indexOnDownload]];
        
    } withFailBlock:^{

        NSIndexPath *indexOnFail = [self indexPathForUserGist:userGist];
        [self.userGistCollection reloadItemsAtIndexPaths:@[indexOnFail]];
        [self deleteCellForGist:userGist];
        
    }];

    [self.userGistCollection reloadItemsAtIndexPaths:@[toIndex]];
    [self.userGistCollection scrollToItemAtIndexPath:toIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];

}


@end
