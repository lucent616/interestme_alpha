//
//  SettingsTVC.h
//  InterestMe2
//
//  Created by Collin Wallace on 5/26/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *artSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *carsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *designSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *homesSwitch;

@end
