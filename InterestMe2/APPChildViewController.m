//
//  APPChildViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPChildViewController.h"

@interface APPChildViewController ()

@end

@implementation APPChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *tutorialImageNames = @[@"home",
                                   @"right",
                                   @"collection",
                                   @"left",
                                   @"fullscreen",
                                   @"webview",
                                   @"up",
                                   @"repost",
                                   @"repost_message",
                                   @"settings"];
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];
    self.tutorialImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"interestMe_iPhone_screenshots_%@_.png",tutorialImageNames[self.index]]];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
