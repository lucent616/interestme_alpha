//
//  FullScreenViewController.m
//  InterestMe2
//
//  Created by Collin Wallace on 5/7/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "FullScreenViewController.h"
#import "DraggableViewController.h"

@interface FullScreenViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGR;

@end

@implementation FullScreenViewController

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
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.spinner stopAnimating];
}

#pragma mark Public API

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDownloadingImage];
}

#pragma mark Multithreaded Image Downloading

- (void)startDownloadingImage
{
    self.image = nil;
    if (self.imageURL)
{
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error)
                                                        {
                                                        if (!error)
                                                        {
                                                            if ([request.URL isEqual:self.imageURL])
                                                            {
                                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                            }
                                                        }
                                        }];
        [task resume];
    }
}

#pragma mark Outlets

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (IBAction)tapOnFullScreenImage:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
        [[self navigationController] setNavigationBarHidden:NO animated:NO];

}

@end
