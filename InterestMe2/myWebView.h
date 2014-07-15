//
//  WebView.h
//  InterestMe2
//
//  Created by Collin Wallace on 7/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myWebView : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewForPolaroidSource;
@property (strong, nonatomic) NSString *webViewURL;

@end
