//
//  FullScreenViewController.h
//  InterestMe2
//
//  Created by Collin Wallace on 5/7/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenViewController : UIViewController

@property (strong, nonatomic) NSString *fullScreenSourceURL;
@property (strong, nonatomic) NSString *fullScreenTitle;
@property (strong, nonatomic) NSString *fullScreenDescription;

@property (nonatomic, strong) NSURL *imageURL;

- (void)handleSingleTap;

@end
