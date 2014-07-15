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
#import "settingViewCell.h"

@interface SettingsCDTVC ()
@property (strong, nonatomic) NSMutableDictionary *settingsLabels;
@property (nonatomic) NSUInteger tableIndex;
@property (strong, nonatomic) NSMutableDictionary *filterBank;


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
    
    DraggableViewController *prevVC = self.navigationController.viewControllers[0];
    self.filterBank = prevVC.filterBank;
    
//    for (NSString *each_genre in self.filterBank)
//    {
//        self.genreSwitch.on = [[self.filterBank objectForKey:[NSString stringWithFormat:@"%@",each_genre]] intValue] == 1 ? YES : NO;
//    }
    
    /*
    
    self.artSwitch.on = [self.filterBank[@"art"] intValue] == 1 ? YES : NO;
    self.carsSwitch.on = [self.filterBank[@"cars"] intValue] == 1 ? YES : NO;
    self.designSwitch.on = [self.filterBank[@"design"] intValue] == 1 ? YES : NO;
    self.homesSwitch.on = [self.filterBank[@"homes"] intValue] == 1 ? YES : NO;
    
*/

}
- (void)setupMyFilters
{
    DraggableViewController *prevVC = self.navigationController.viewControllers[0];
    prevVC.filterBank = self.filterBank;
    [prevVC updatePolaroidBank];
}

- (IBAction)switchWasChanged:(UISwitch *)sender
{
    CGPoint touchPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    
    settingViewCell *currentCell = (settingViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.filterSwitch.isOn)
    {
        [self.filterBank setObject:@1 forKey:currentCell.genreLabel.text];
    }
    else
    {
        [self.filterBank setObject:@0 forKey:currentCell.genreLabel.text];
    }
    NSLog(@"The new FilterBank : %@", self.filterBank);
    [self setupMyFilters];
}

/////////////////////////////////////WHEN I WANT TO ADD DYNAMIC LABELS


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
    
    settingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[settingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *cellGenre = [[self.filterBank allKeys] objectAtIndex:indexPath.row];
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

/////////END OF DYNAMIC LABELS

@end
