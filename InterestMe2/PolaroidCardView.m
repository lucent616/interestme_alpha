//
//  PlayingCardView.m
//  SuperCard
//
//  Created by CS193p Instructor on 4/17/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PolaroidCardView.h"
#import "DraggableViewController.h"
#import "UIImage+AddOn.h"
#import "OverlayView.h"

@interface PolaroidCardView()
@property (nonatomic, strong) UIImageView *polaroidImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PolaroidCardView

#pragma mark - Drawing

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 2
#define POLAROID_HEIGHT_SCALE 0.85
#define POLAROID_WIDTH_SCALE 0.95


#pragma mark Properties

- (void)didAddSubview:(UIView *)subview
{
    
}

- (UIImageView *)polaroidImageView
{
    if (!_polaroidImageView) _polaroidImageView = [[UIImageView alloc] init];
    return _polaroidImageView;
}

- (UIImage *)image
{
    return self.polaroidImageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.polaroidImageView.image = image;
    
    self.title.text = self.polaroid.title;
    self.description.text = self.polaroid.polaroidDescription;
    

    
    [self.polaroidImageView sizeToFit];
    [self.spinner stopAnimating];
}


#pragma mark Multithreaded Image Downloading

- (void)startDownloadingImage
{
    self.image = nil;
    if (self.polaroid.imageURL)
    {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.polaroid.imageURL]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error)
        {
            if (!error)
            {
                if ([[request.URL absoluteString] isEqual:self.polaroid.imageURL])
                {
                    self.polaroid.image = [NSData dataWithContentsOfURL:localfile];
                    UIImage *image = [UIImage imageWithData:self.polaroid.image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.polaroidImage = image;
                        [self setNeedsDisplay];
                    });
                }
            }
        }];
        
        [task resume];
    }
}

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

//DRAWS A POLAROID
- (void)drawRect:(CGRect)rect
{
    CGSize targetSize = CGSizeMake(self.bounds.size.width* POLAROID_WIDTH_SCALE, self.bounds.size.height*POLAROID_HEIGHT_SCALE);
    
    
    //UIImage *polaroidImage = [self imageByScalingAndCroppingForSize:self.polaroidImage targetSize:targetSize];//WHERE I WANT TO TRY THE NEW RESIZING METHOD
    UIImage *polaroidImage = [UIImage imageToFitSize:self.polaroidImage size:targetSize method:MGImageResizeCrop];
    CGRect imageRect = self.bounds;
    imageRect.size.width = self.bounds.size.width * POLAROID_WIDTH_SCALE; //sets the image width to be the same as the view bounds
    imageRect.size.height = self.bounds.size.height * POLAROID_HEIGHT_SCALE;
    float offsetValue = (self.bounds.size.width-imageRect.size.width)/2;
    
    CGRect movedImageRect =  CGRectOffset (imageRect, offsetValue, offsetValue);
    [polaroidImage drawInRect:movedImageRect];
    
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    self.overlayView.backgroundColor = [UIColor whiteColor];
    self.overlayView.alpha = 0;
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_send.png"]];
    [self.overlayView addSubview:self.imageView];
}

- (void)shadePolaroidBackground
{
    self.layer.masksToBounds = NO;
    //self.cornerRadius = 2; // if you like rounded corners
    self.layer.shadowOffset = CGSizeMake(6, 8);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

- (void)unshadePolaroidBackground
{
    self.layer.masksToBounds = NO;
    //self.cornerRadius = 2; // if you like rounded corners
    self.layer.shadowOffset = CGSizeMake(6, 8);
    self.layer.shadowRadius = 0;
    self.layer.shadowOpacity = 0.0;
}

- (void)hideOverlay
{
    [self updateOverlay:0 yDistance:0];
}

- (void)updateOverlay:(CGFloat)xDistance yDistance:(CGFloat)yDistance
{
    CGFloat distance;
    if (yDistance < 0 && fabs(xDistance) < 70)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_send.png"];
        distance = yDistance;
    }
    else if (xDistance > 0 && fabs(yDistance) < 300)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_interesting.png"];
        distance = xDistance;
        
    }
    else if (xDistance < 0 && fabs(yDistance) < 300)
    {
        self.imageView.image = [UIImage imageNamed:@"overlay_boring.png"];
        distance = xDistance;
    }
    CGFloat overlayStrength = MIN(fabs(distance) / 100, 0.4);
    self.overlayView.alpha = overlayStrength;
}

//END OF DRAWING POLAROID

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
