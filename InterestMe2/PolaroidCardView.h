//
//  PlayingCardView.h
//  SuperCard
//
//  Created by CS193p Instructor on 4/17/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Polaroid+AddOn.h"

@interface PolaroidCardView : UIView


@property (strong, nonatomic) Polaroid *polaroid;
@property (strong, nonatomic) UIImage *polaroidImage;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UIView *overlayView;



- (void)shadePolaroidBackground;
- (void)unshadePolaroidBackground;
- (void)startDownloadingImage;
- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize;
- (void)updateOverlay:(CGFloat)xDistance yDistance:(CGFloat)yDistance;
- (void)hideOverlay;

@end
