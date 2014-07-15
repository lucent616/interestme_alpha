//
//  LoginViewController.m
//  InterestMe2
//
//  Created by Collin Wallace on 7/1/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "LoginViewController.h"
#import "DraggableViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailInputField;
@property (strong, nonatomic) NSDictionary *userInformationFromServer;


@end

@implementation LoginViewController

- (IBAction)login:(id)sender
{
    [self fetchUserID:^(BOOL success){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)fetchUserID:(void (^)(BOOL success))completionHandler
{
    NSString *userInputEmail = self.emailInputField.text;
    NSString *urlQuery = [NSString stringWithFormat:@"http://thawing-ocean-9569.herokuapp.com/user/find?email=%@", userInputEmail];
    
    NSURL *url = [[NSURL alloc] initWithString:urlQuery];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("Polaroid User Fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        self.userInformationFromServer = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                       options:0
                                                                         error:NULL];
        
        [self saveData];
        
            if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });
    });
}

- (void)saveData
{
    NSUserDefaults *loginDefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *userId = @{@"id": self.userInformationFromServer[@"id"]};
    
    [loginDefault setObject:userId forKey:@"userInfo"];
    [loginDefault synchronize];
}
@end
