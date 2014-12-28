//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3DragArena.h>


SpecBegin(I3DragArena)


    describe(@"constructor", ^{
        
        it(@"should create a mutable orderable set from the elements passed in the array", ^{

            NSObject *object1 = [[NSObject alloc] init];
            NSObject *object2 = [[NSObject alloc] init];
            NSObject *object3 = [[NSObject alloc] init];
            
            NSArray *elements = @[object1, object2, object3];
            
            I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:nil containingCollections:elements];
            
            expect([arena.collections objectAtIndex:0]).to.equal(object1);
            expect([arena.collections objectAtIndex:1]).to.equal(object2);
            expect([arena.collections objectAtIndex:2]).to.equal(object3);
            
        });
        
        it(@"should inject the superview", ^{
        
            UIView *superview = [[UIView alloc] init];
            
            I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];
            
            expect(arena.superview).to.equal(superview);
        
        });
        
    });


SpecEnd
