//
//  SettingsTVC.m
//  InterestMe2
//
//  Created by Collin Wallace on 5/26/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "SettingsCDTVC.h"
#import "PolaroidCollectionViewController.h"
#import "DraggableViewController.h"
#import "Polaroid+AddOn.h"
#import "SettingsTableViewCell.h"

@interface SettingsCDTVC ()
@property (strong, nonatomic) NSMutableDictionary *settingsLabels;
@property (nonatomic) NSUInteger tableIndex;
@property (strong, nonatomic) NSMutableDictionary *filterBank;
@property (strong, nonatomic) NSDictionary *filterInformation;
@property (strong, nonatomic) DraggableViewController *prevVC;

@end

@implementation SettingsCDTVC

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
    
    self.prevVC = self.navigationController.viewControllers[0];
    [self setupMyFilters];
    
}

- (void)setupMyFilters
{
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"] != nil)
    {
        NSLog(@"Filter preferences read from draggable view");
        self.filterInformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"];
        self.filterBank = [self.filterInformation[@"filterBank"] mutableCopy];
        
        NSLog(@"Filter bank from draggable view was: %@", self.filterBank);
    }
    else
    {
        NSLog(@"No current Filter Bank found");
        self.filterBank = self.prevVC.filterBank;
        NSLog(@"Original Filter Bank: %@", self.filterBank);
    }
}

- (void)saveFilterPreferences
{
    NSUserDefaults *filterDefaults = [NSUserDefaults standardUserDefaults];
    
    self.filterInformation = @{@"filterBank": self.filterBank};
    NSLog(@"Filter bank settings when saved on settings page: %@", self.filterBank);
    
    [filterDefaults setObject:self.filterInformation forKey:@"User Filter Preferences"];
    [filterDefaults synchronize];
}

- (IBAction)switchWasChanged:(UISwitch *)sender
{
    CGPoint touchPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    
    SettingsTableViewCell *currentCell = (SettingsTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.filterSwitch.isOn)
    {
        [self.filterBank setObject:@1 forKey:currentCell.genreLabel.text];
    }
    else
    {
        [self.filterBank setObject:@0 forKey:currentCell.genreLabel.text];
    }
    NSLog(@"The user new filter bank is: %@", self.filterBank);
    
    [self saveFilterPreferences];
    //[self.prevVC updatePolaroidBank];
    [self.prevVC trackRemainingPolaroids];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filterBank count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GenreTableCell";
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *cellGenre = [[[self.filterBank allKeys] sortedArrayUsingSelector: @selector(compare:)] objectAtIndex:indexPath.row];
    cell.genreLabel.text = cellGenre;
    int switchValue = [[self.filterBank objectForKey:cellGenre] intValue];
    if ( switchValue == 1)
         {
             cell.filterSwitch.on = YES;
         }
         else
         {
             cell.filterSwitch.on = NO;
         }
    return cell;
}

@end
