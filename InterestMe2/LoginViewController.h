//
//  LoginViewController.h
//  InterestMe2
//
//  Created by Collin Wallace on 7/1/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *passwordRememberSwitch;

@end
