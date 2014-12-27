//
//  GistViewController.m
//  17. Async Networking Collections
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "GistViewController.h"
#import "GistService.h"
#import "GistCollectionViewCell.h"
#import "AvailableGistCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


@interface GistViewController ()

@property (nonatomic, strong) NSArray *availableGists;

@property (nonatomic, strong) NSMutableArray *userGists;

@property (nonatomic, strong) GistService *gistService;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation GistViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    self.gistService = [[GistService alloc] init];
    
    [self.availableGistCollection registerNib:[UINib nibWithNibName:AvailableGistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:AvailableGistCollectionViewCellIdentifier];
    [self.userGistCollection registerNib:[UINib nibWithNibName:GistCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:GistCollectionViewCellIdentifier];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.availableGistCollection, self.userGistCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    ((I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate).draggingItemOpacity = 0.4;
    
}


-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self initialiseAvailableGists];
    
    self.userGists = [[NSMutableArray alloc] init];
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    return [self dataForCollection:collectionView].count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *data = [self dataForCollection:collectionView];
    
    if(collectionView == self.availableGistCollection){
        
        AvailableGistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AvailableGistCollectionViewCellIdentifier forIndexPath:indexPath];
        
        GistDescriptor *gist = [data objectAtIndex:indexPath.item];
        
        cell.descriptionLabel.text = [self politeString:gist.gistDescription];
        
        return cell;
        
    }
    else{
        
        GistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GistCollectionViewCellIdentifier forIndexPath:indexPath];
        
        id datum = [data objectAtIndex:indexPath.item];
        CGFloat labelAlpha;
        
        if([datum isKindOfClass:[Gist class]]){
            
            Gist *gist = datum;
            
            cell.descriptionLabel.text = [self politeString:gist.gistDescription];
            cell.createdAtLabel.text = [self politeString:gist.formattedCreatedAt];
            cell.ownerUrlLabel.text = [self politeString:gist.ownerUrl];
            cell.commentsCountLabel.text = [self politeString:[gist.commentsCount stringValue]];
            cell.backgroundColor = [UIColor lightGrayColor];
            
            [cell.downloadingIndicator stopAnimating];
            
            labelAlpha = 1;
        }
        else{
            
            GistDescriptor *metaGist = datum;
            
            cell.descriptionLabel.text = [self politeString:metaGist.gistDescription];
            cell.backgroundColor = metaGist.hasFailed ? [UIColor redColor] : [UIColor lightGrayColor];
            
            if(metaGist.hasFailed){
                [cell.downloadingIndicator stopAnimating];
            }
            else{
                [cell.downloadingIndicator startAnimating];
            }
            
            labelAlpha = 0.1;
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
    return !string || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@""] ? @"Unknown" : string;
}


-(NSIndexPath *)indexPathForUserGist:(id) gist{
    return [NSIndexPath indexPathForItem:[self.userGists indexOfObject:gist] inSection:0];
}


-(NSArray *)dataForCollection:(UICollectionView *)collection{
    return collection == self.userGistCollection ? self.userGists : self.availableGists;
}


-(void) initialiseAvailableGists{
    
    [self.gistService findGistsWithCompleteBlock:^(NSArray *gists) {
        
        self.availableGists = gists;
        [self.availableGistCollection reloadData];
        
    } withFailBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Failed to retrieve Gists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }];
    
}


-(void) deleteCellForGist:(GistDescriptor *)gist{
    
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
    GistDescriptor *metaGist = [self.availableGists[from.row] copy];
    
    [self.userGists addObject:metaGist];
    [self.userGistCollection insertItemsAtIndexPaths:@[toIndex]];
    
    [self.gistService findGistByGithubId:metaGist.githubId withCompleteBlock:^(Gist *gist) {
        
        NSIndexPath *indexOnDownload = [self indexPathForUserGist:metaGist];
        
        [self.userGists replaceObjectAtIndex:indexOnDownload.item withObject:gist];
        [self.userGistCollection reloadItemsAtIndexPaths:@[indexOnDownload]];
        
    } withFailBlock:^{
        
        metaGist.hasFailed = YES;
        
        [self.userGistCollection reloadItemsAtIndexPaths:@[[self indexPathForUserGist:metaGist]]];
        [self deleteCellForGist:metaGist];
        
    }];
    
    [self.userGistCollection reloadItemsAtIndexPaths:@[toIndex]];
    [self.userGistCollection scrollToItemAtIndexPath:toIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
}


@end