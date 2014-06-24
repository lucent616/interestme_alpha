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

//@property (strong, nonatomic) NSString *polaroidImageFileName;
//@property (strong, nonatomic) NSURL *polaroidImageURL;
@property (strong, nonatomic) Polaroid *polaroid;
@property (strong, nonatomic) UIImage *polaroidImage;


- (void)shadePolaroidBackground;
- (void)unshadePolaroidBackground;
- (void)startDownloadingImage;


@end
