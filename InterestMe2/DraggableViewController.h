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
#import "PolaroidCardView.h"


@class PolaroidWithinDraggableView;

@interface DraggableViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet PolaroidCardView *frontPolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *middlePolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *backPolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *tempPolaroidCardView;
@property (strong, nonatomic) UIImage *polaroidThumbnailImage;
@property (strong, nonatomic) NSString *polaroidThumbnailImageURL;
@property (nonatomic) int imageIndex;
@property (nonatomic) int interestMeScore;
@property (nonatomic, strong) NSMutableArray *photoBank;
@property (strong, nonatomic) NSMutableDictionary *filterBank;
@property (nonatomic) int userID;
@property (strong, nonatomic) NSMutableArray *polaroidGenres;

- (void) updatePolaroidBank;
- (void)saveData;
- (void)trackRemainingPolaroids;

@end
