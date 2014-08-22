//
//  FullScreenViewController.m
//  InterestMe2
//
//  Created by Collin Wallace on 5/7/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "FullScreenViewController.h"
#import "DraggableViewController.h"
#import "myWebView.h"

@interface FullScreenViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *fullScreenTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullScreenDescriptionLabel;

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
    // self.scrollView could be nil here if outlet-setting has not happened yet
    self.scrollView.zoomScale = 1;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = image ? image.size : CGSizeZero;
    if(image)
    {
        //NSLog(@"Content Size: %f, %f",self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        self.imageView.image = image; // does not change the frame of the UIImageView
        [self.imageView sizeToFit];   // update the frame of the UIImageView
        
        CGFloat actualScrollViewWidth = self.scrollView.contentSize.width;
        CGFloat actualScrollViewHeight = self.scrollView.contentSize.height;
        CGFloat scrollVisibleHeight = _scrollView.bounds.size.height;
        CGFloat scrollVisibleWidth = _scrollView.bounds.size.width;
        CGFloat heightRatio = scrollVisibleHeight / actualScrollViewHeight;
        CGFloat widthRatio = scrollVisibleWidth/actualScrollViewWidth;
//        NSLog(@"%f",heightRatio);
//        NSLog(@"%f",widthRatio);
//        NSLog(@"Window Size: %f, %f",scrollVisibleWidth, scrollVisibleHeight);
//        NSLog(@"before: %f",self.scrollView.zoomScale);
        
        if (heightRatio > widthRatio)
        {
            self.scrollView.zoomScale = heightRatio;
        }
        else
        {
            self.scrollView.zoomScale = widthRatio;
        }
        //NSLog(@"after: %f",self.scrollView.zoomScale);
        
    }
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
    self.scrollView.minimumZoomScale = .5;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.fullScreenTitleLabel.text = self.fullScreenTitle;
    self.fullScreenDescriptionLabel.text = self.fullScreenDescription;
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    [singleTapGR requireGestureRecognizerToFail : doubleTapGR];
    [doubleTapGR setDelaysTouchesBegan : YES];
    [singleTapGR setDelaysTouchesBegan : YES];
    
    [doubleTapGR setNumberOfTapsRequired : 2];
    [singleTapGR setNumberOfTapsRequired : 1];
    
    [self.scrollView addGestureRecognizer : doubleTapGR];
    [self.scrollView addGestureRecognizer : singleTapGR];
    
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)handleSingleTap
{
    //NSLog(@"You SINGLE tapped on the screen");
    [self.navigationController popViewControllerAnimated:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)handleDoubleTap
{
    //NSLog(@"You DOUBLE tapped on the screen");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    myWebView *controller = (myWebView*)[mainStoryboard instantiateViewControllerWithIdentifier: @"WebViewID"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.barStyle = UIBarStyleDefault;

    controller.webViewURL = [NSURL URLWithString:self.fullScreenSourceURL];
    
    // present
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

@end
