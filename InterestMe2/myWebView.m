//
//  WebView.m
//  InterestMe2
//
//  Created by Collin Wallace on 7/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "myWebView.h"
#import "DraggableViewController.h"

@interface myWebView ()

@end

@implementation myWebView
@synthesize webViewForPolaroidSource = _webViewForPolaroidSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"hehe: %@", self.webViewURL);
    
    self.webViewForPolaroidSource.delegate = self;
    
    [self.view bringSubviewToFront:self.webViewForPolaroidSource];
    
    NSString *urlText = [NSString stringWithFormat:@"%@",self.webViewURL];
    NSLog(@"URL Text: %@", urlText);
    NSURL *url = [NSURL URLWithString:urlText];
    NSLog(@"URL: %@", url);
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [self.webViewForPolaroidSource loadRequest:requestURL];

}
- (IBAction)returnToDraggableView:(id)sender
{
    NSLog(@"Return to Draggable View");
    // dismiss
     [self dismissViewControllerAnimated:YES completion:nil];
    
    //DraggableViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DraggableView"];
    
    //[self presentViewController:dvc animated:YES completion:nil];
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DraggableView" bundle: nil];
    
    
    
    //[self.navigationController pushViewController:viewWithTag animated:YES];
    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *tutorialVC = [storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
//    tutorialVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:tutorialVC animated:YES completion:nil];
//    
}

#pragma mark - Optional UIWebViewDelegate delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
