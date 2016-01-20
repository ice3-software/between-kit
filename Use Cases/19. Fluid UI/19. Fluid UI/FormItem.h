//
//  FormItem.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 A simple enum used to denote the type of form field an instance of `FormItem`
 represents. View controllers should use this type to determine how to render
 the item data.
 
 */
typedef NS_ENUM(NSInteger, FormItemType){
    FormItemTypeTextField,
    FormItemTypeTextArea,
    FormItemTypeButton,
    FormItemTypeSwitch,
};


/**
 
 Model for a 'form item' - used to manage the data associated with each
 for field in the main FluidUI form. 
 
 Uses the `FormItemType` enum to denote the 'type' of field, i.e. what 
 component it represents and also provides an agnostic `value` property
 which can be used to store the value of the field.
 
 @note It might be cleaner to create separate classes for each type of
 component (e.g. `FormSwitchField`, `FormButtonField`, etc) and determine
 how to render it based on its `class`.. but for now this is easier.
 
 */
@interface FormItem : NSObject

@property (nonatomic, assign) FormItemType type;

/** @var NSNumber | NSString | nil depending on value of type */

@property (nonatomic, copy) id value;

@end
