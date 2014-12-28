//
//  FormItem.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FormItemType){
    FormItemTypeTextField,
    FormItemTypeTextArea,
    FormItemTypeButton,
    FormItemTypeSwitch,
};

@interface FormItem : NSObject

@property (nonatomic, assign) FormItemType type;

/** @var NSNumber | NSString | nil depending on value of type */

@property (nonatomic, copy) id value;

@end
