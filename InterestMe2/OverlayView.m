//  Interest.ME
//
//  References TinderLikeAnimations by Nimrod Gutman on 1/17/14.
//  Copyright (c) 2014 Life Made Mobile, LLC. All rights reserved.
//

#import "OverlayView.h"

@interface OverlayView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_interesting.png"]];
    [self addSubview:self.imageView];

    return self;
}

- (void)setMode:(GGOverlayViewMode)mode
{
    if (mode == GGOverlayViewModeLeft)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_boring.png"];
    }
    else if (mode == GGOverlayViewModeRight)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_interesting"];
    }
    else if (mode == GGOverlayViewModeUp)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_send.png"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

}

@end