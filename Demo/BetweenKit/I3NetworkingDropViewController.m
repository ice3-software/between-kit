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
#import <BetweenKit/I3GestureCoordinator.h>


@interface I3NetworkingDropViewController ()

@property (nonatomic, strong) NSArray *emptyGists;

@property (nonatomic, strong) NSMutableArray *userGists;

@property (nonatomic, strong) I3GistService *gistService;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end

@implementation I3NetworkingDropViewController


-(void) viewDidLoad{

    [super viewDidLoad];
    
    [self.emptyGistCollection registerNib:[UINib nibWithNibName:I3GistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3GistCollectionViewCellIdentifier];
    [self.userGistCollection registerNib:[UINib nibWithNibName:I3GistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3GistCollectionViewCellIdentifier];
    
    self.userGists = [[NSMutableArray alloc] init];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.emptyGistCollection, self.userGistCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
    [self initialiseEmptyGists];
    
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
    
    I3GistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3GistCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *gistData = [self dataForCollection:collectionView];
    I3Gist *gist = [gistData objectAtIndex:indexPath.item];
    
    NSLog(@"Cell for gist: %@", gist);
    
    cell.descriptionLabel.text = gist.gistDescription ?: @"";
    cell.createdAtLabel.text = gist.formattedCreatedAt ?: @"";
    cell.ownerUrlLabel.text = gist.ownerUrl ?: @"";
    cell.commentsCountLabel.text = [gist.commentsCount stringValue] ?: @"";
    cell.isEmptyGist = gist.state == I3GistStateEmpty;
    
    if(gist.state == I3GistStateDownloading){
        [cell startDownloadingIndicator];
    }
    
    return cell;
}


#pragma mark - Helpers


-(NSIndexPath *)indexPathForUserGist:(I3Gist *)gist{
    return [NSIndexPath indexPathForItem:[self.userGists indexOfObject:gist] inSection:0];
}


-(NSArray *)dataForCollection:(UICollectionView *)collection{
    return collection == self.userGistCollection ? self.userGists : self.emptyGists;
}


-(void) initialiseEmptyGists{

    self.gistService = [[I3GistService alloc] init];
    
    [self.gistService findGistsWithCompleteBlock:^(NSArray *gists) {
        
        self.emptyGists = gists;
        NSLog(@"Our empty gists: %@, with a count of %d", self.emptyGists, self.emptyGists.count);
        [self.emptyGistCollection reloadData];
        
    } withFailBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Failed to retrieve Gists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }];

}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return collection == self.emptyGistCollection;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:self.userGists.count inSection:0];
    
    I3Gist *emptyGist = self.emptyGists[from.row];
    I3Gist *userGist = [emptyGist copy];
    
    [self.userGists addObject:userGist];
    
    [self.gistService downloadFullGist:userGist withCompleteBlock:^{
        
        NSIndexPath *indexOnDownload = [self indexPathForUserGist:userGist];
        [self.userGistCollection reloadItemsAtIndexPaths:@[indexOnDownload]];
        
    } withFailBlock:^{

        NSIndexPath *indexOnFail = [self indexPathForUserGist:userGist];
        I3GistCollectionViewCell *cell = (I3GistCollectionViewCell *)[self.userGistCollection itemAtIndexPath:indexOnFail];
        
        [cell highlightAsFailed:^{

            NSIndexPath *indexAfterHighlighted = [self indexPathForUserGist:userGist];

            [self.userGists removeObject:userGist];
            [self.userGistCollection deleteItemsAtIndexPaths:@[indexAfterHighlighted]];
            
        }];
        
    }];

    [self.userGistCollection insertItemsAtIndexPaths:@[toIndex]];

}


@end
