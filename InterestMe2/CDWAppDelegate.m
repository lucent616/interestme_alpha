//
//  CDWAppDelegate.m
//  InterestMe2
//
//  Created by Collin Wallace on 4/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "CDWAppDelegate.h"
#import "PolaroidDatabase.h"
#import "APPViewController.h"

@implementation CDWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Application entering the background");
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Application Terminating");
    [self saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

- (void)saveContext
{
    NSError *error = nil;
    PolaroidDatabase *db = [PolaroidDatabase sharedDefaultPolaroidDatabase];
    
    if (db.managedObjectContext != nil)
    {
        if ([db.managedObjectContext hasChanges] && ![db.managedObjectContext save:&error])
        {
            /*Replace this implementation with code to handle the error appropriately.
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSLog(@"Managed Object Context Saved.");
    }
    
}

@end
