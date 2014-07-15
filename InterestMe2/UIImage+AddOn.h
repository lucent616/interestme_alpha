//
//  UIImage+AddOn.h
//  InterestMe2
//
//  Created by Collin Wallace on 7/7/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MGImageResizeCrop,	// analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale	// analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} MGImageResizingMethod;


@interface UIImage (AddOn)
+ (UIImage *)imageToFitSize:(UIImage *)sourceImage size:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod;
+ (UIImage *)imageCroppedToFitSize:(UIImage *)sourceImage size:(CGSize)targetSize; // uses MGImageResizeCrop
+ (UIImage *)imageScaledToFitSize:(UIImage *)sourceImage size:(CGSize)targetSize; // uses MGImageResizeScale
@end
