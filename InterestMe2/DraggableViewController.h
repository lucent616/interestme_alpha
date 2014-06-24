//
//  CDWViewController.h
//  InterestMe2
//
//  Created by Collin Wallace on 4/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Foundation/Foundation.h>


@class PolaroidWithinDraggableView;

@interface DraggableViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int imageIndex;
@property (nonatomic, strong) NSMutableArray *photoBank;
@property (strong, nonatomic) NSMutableDictionary *filterBank;

-(void) updatePolaroidBank;


@end
