//
//  CDWAppDelegate.h
//  InterestMe2
//
//  Created by Collin Wallace on 4/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewController.h"
#import "Polaroid.h"
#import "SettingsCDTVC.h"

@interface CDWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) DraggableViewController *draggableViewController;

@end
