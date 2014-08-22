//
//  settingViewCell.h
//  InterestMe2
//
//  Created by Collin Wallace on 7/12/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;

@end
