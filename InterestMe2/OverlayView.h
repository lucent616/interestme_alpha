//  Interest.ME
//
//  References TinderLikeAnimations by Nimrod Gutman on 1/17/14.
//  Copyright (c) 2014 Life Made Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , GGOverlayViewMode) {
    GGOverlayViewModeLeft,
    GGOverlayViewModeRight,
    GGOverlayViewModeUp
};

@interface OverlayView : UIView
@property (nonatomic) GGOverlayViewMode mode;
//@property (weak, nonatomic) IBOutlet UIImage *overlayImage;

@end