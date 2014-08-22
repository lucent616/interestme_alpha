//
//  TestFBAccessVC.m
//  InterestMe2
//
//  Created by Collin Wallace on 7/16/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "TestFBAccessVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>


@interface TestFBAccessVC ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;

@end

@implementation TestFBAccessVC

- (void)viewDidLoad
{

}
- (IBAction)getFacebook:(id)sender
{
    [self getPermissionFromFacebook];
}

- (void)getPermissionFromFacebook
{
    //ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Specify App ID and permissions
    NSDictionary *options = @{
                              ACFacebookAppIdKey: @"1437935329813368",
                              ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions"],
                              ACFacebookAudienceKey: ACFacebookAudienceFriends
                              };
    
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:options completion:^(BOOL granted, NSError *facebookError) {
                                              if (granted) {
                                                  NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                                                  self.facebookAccount = [accounts lastObject];
                                              }
                                              else
                                              {
                                                  // Handle Failure
                                                  NSLog(@"Failed to get Facebook Authorization! Error %@", facebookError);
                                              }
                                          }];
    
//    NSDictionary *parameters = @{@"message": @"My first iOS 6 Facebook posting "};
//    
//    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
//    
//    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
//                                                requestMethod:SLRequestMethodPOST
//                                                          URL:feedURL
//                                                   parameters:parameters];
//    
//    feedRequest.account = self.facebookAccount;
//    
//    [feedRequest performRequestWithHandler:^(NSData *responseData, 
//                                             NSHTTPURLResponse *urlResponse, NSError *error)
//
//     {
//         // Handle response
//     }];

    NSLog(@"Facebook Account: %@", self.facebookAccount);
}

- (IBAction)pickFriendsClick:(UIButton *)sender {
    FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
    friendPickerController.title = @"Pick Friends";
    [friendPickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [friendPickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *innerSender, BOOL donePressed) {
         if (!donePressed) {
             return;
         }
         
         NSString *message;
         
         if (friendPickerController.selection.count == 0) {
             message = @"<No Friends Selected>";
         } else {
             
             NSMutableString *text = [[NSMutableString alloc] init];
             
             // we pick up the users from the selection, and create a string that we use to update the text view
             // at the bottom of the display; note that self.selection is a property inherited from our base class
             for (id<FBGraphUser> user in friendPickerController.selection) {
                 if ([text length]) {
                     [text appendString:@", "];
                 }
                 [text appendString:user.name];
             }
             message = text;
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:"
                                     message:message
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}

@end
