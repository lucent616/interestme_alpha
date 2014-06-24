//
//  PlayingCardView.m
//  SuperCard
//
//  Created by CS193p Instructor on 4/17/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PolaroidCardView.h"
#import "DraggableViewController.h"

@interface PolaroidCardView()
@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation PolaroidCardView

#pragma mark - Drawing

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 2
#define POLAROID_HEIGHT_SCALE 0.85
#define POLAROID_WIDTH_SCALE 0.95


#pragma mark Properties

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    [self.spinner stopAnimating];
}


#pragma mark Multithreaded Image Downloading

- (void)startDownloadingImage
{
    self.image = nil;
    //NSLog(@"url: %@", self.polaroid.imageURL);
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
                    //NSLog(@"url: %@", self.polaroid.imageURL);
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
//    UITapGestureRecognizer *tapRecognizer;
//    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
//    tapRecognizer.numberOfTapsRequired = 1;
//    tapRecognizer.numberOfTouchesRequired = 1;
    
    
    //Determines how the Polaroids are drawn
    BOOL polaroidStyle = YES;
    //Trying to incorporate threading results
    
    UIImage *polaroidImage = self.polaroidImage;
        //UIImage *polaroidImage = [UIImage imageNamed:self.polaroidImageFileName];
    if (polaroidImage) {
            if (polaroidStyle)
            {
                //Polaroid style
                CGRect imageRect = self.bounds;
                imageRect.size.width = self.bounds.size.width * POLAROID_WIDTH_SCALE; //set the image width to be the same as the view bounds
                imageRect.size.height = self.bounds.size.height * POLAROID_HEIGHT_SCALE;
                float offsetValue = (self.bounds.size.width-imageRect.size.width)/2;
                
                CGRect movedImageRect =  CGRectOffset (imageRect, offsetValue, offsetValue);
                [polaroidImage drawInRect:movedImageRect];
            }
            else
            {
                //Trading Card style
                CGRect imageRect = self.bounds;
                float scaledHeight = (polaroidImage.size.width/self.bounds.size.width)*polaroidImage.size.height;//calculate the proportionate scaling of the image
                if (scaledHeight > self.bounds.size.height)
                {
                     imageRect.size.height = POLAROID_HEIGHT_SCALE * self.bounds.size.height;
                    [polaroidImage drawInRect:imageRect];
                }
                else
                {
                    [polaroidImage drawInRect:imageRect];
                }
            }
    }
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
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


@end
