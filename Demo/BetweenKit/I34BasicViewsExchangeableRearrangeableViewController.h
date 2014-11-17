//
//  I34BasicViewsExchangeableRearrangeableViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/UIView+I3Collection.h>

@interface I34BasicViewsExchangeableRearrangeableViewController : UIViewController<I3DragDataSource>

@property (nonatomic, weak) IBOutlet UIView *topLeft;

@property (nonatomic, weak) IBOutlet UIView *topRight;

@property (nonatomic, weak) IBOutlet UIView *bottomLeft;

@property (nonatomic, weak) IBOutlet UIView *bottomRight;

@end
