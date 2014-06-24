//
//  SettingsTVC.m
//  InterestMe2
//
//  Created by Collin Wallace on 5/26/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "SettingsTVC.h"
#import "DraggableViewController.h"

@interface SettingsTVC ()
@property (strong, nonatomic) NSMutableDictionary *settingsLabels;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (nonatomic) NSUInteger tableIndex;
@property (strong, nonatomic) NSMutableDictionary *filterBank;



@end

@implementation SettingsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    DraggableViewController *prevVC = self.navigationController.viewControllers[0];
    self.filterBank = prevVC.filterBank;
    
    self.artSwitch.on = [self.filterBank[@"art"] intValue] == 1 ? YES : NO;
    self.carsSwitch.on = [self.filterBank[@"cars"] intValue] == 1 ? YES : NO;
    self.designSwitch.on = [self.filterBank[@"design"] intValue] == 1 ? YES : NO;
    self.homesSwitch.on = [self.filterBank[@"homes"] intValue] == 1 ? YES : NO;

}





- (void)setupMyFilters
{
    [self.filterBank setValue:self.artSwitch.on?@1:@0 forKey:@"art"];
    [self.filterBank setValue:self.carsSwitch.on?@1:@0 forKey:@"cars"];
    [self.filterBank setValue:self.designSwitch.on?@1:@0 forKey:@"design"];
    [self.filterBank setValue:self.homesSwitch.on?@1:@0 forKey:@"homes"];


    DraggableViewController *prevVC = self.navigationController.viewControllers[0];
    prevVC.filterBank = self.filterBank;
    [prevVC updatePolaroidBank];
}

- (IBAction)switchWasChanged:(id)sender
{
    [self setupMyFilters];
}

/////////////////////////////////////WHEN I WANT TO ADD DYNAMIC LABELS
-(NSMutableDictionary *)settingsLabels
{
    if(!_settingsLabels)
    {
        _settingsLabels = [@{@"genre":@[@"Art",
                                        @"Cars",
                                        @"Design",
                                        @"Homes"],
                             @"filter":@[@"Popular",
                                         @"Art",
                                         @"Architecture",
                                         @"Automobilese",
                                         @"Home Decor"]
                             } mutableCopy];
    }
    self.tableIndex = 0;
    return _settingsLabels;
}
/////////END OF DYNAMIC LABELS

@end
