//
//  FlickrDatabase.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PolaroidDatabase.h"
#import "FlickrFetcher.h"
#import "Polaroid+AddOn.h"
#import "Polaroid.h"
#import "DraggableViewController.h"

@interface PolaroidDatabase()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *polaroidArrayFromServer;
@end

@implementation PolaroidDatabase

+ (PolaroidDatabase *)sharedDefaultPolaroidDatabase
{
    return [self sharedPolaroidDatabaseWithName:@"Polaroid"];
}

+ (PolaroidDatabase *)sharedPolaroidDatabaseWithName:(NSString *)name
{
    static NSMutableDictionary *databases = nil;
    if (!databases) databases = [[NSMutableDictionary alloc] init];
    
    PolaroidDatabase *database = nil;
    
    if ([name length]) {
        database = databases[name];
        if (!database) {
            database = [[self alloc] initWithName:name];
            databases[name] = database;
        }
    }
    
    return database;
}

- (instancetype)initWithName:(NSString *)name
{
    BOOL deleteOldFile = YES;
    
    self = [super init];
    if (self) {
        if ([name length]) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
            url = [url URLByAppendingPathComponent:name];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
            {
                if(deleteOldFile)
                {
                    NSError *error;
                    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
                    
                    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                          if (success)
                          {
                              self.managedObjectContext = document.managedObjectContext;
                              [self fetchWithCompletionHandler:^(BOOL success){
                                  [self postNotification];
                              }];
                          }
                    }];
                }
                else
                {
                    [document openWithCompletionHandler:^(BOOL success) {
                        if (success)
                        {
                            self.managedObjectContext = document.managedObjectContext;
                            [self fetchWithCompletionHandler:^(BOOL success){
                                [self postNotification];
                            }];

                        }
                    }];
                }
            }
            else
            {
                [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                      if (success)
                      {
                          self.managedObjectContext = document.managedObjectContext;
                          [self fetchWithCompletionHandler:^(BOOL success){
                              [self postNotification];
                          }];
                      }
                    
                  }];
            }
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
   }

- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PolaroidDatabaseAvailable
                                                        object:self];

}

- (void)fetch
{
    [self fetchWithCompletionHandler:nil];
}

- (void)buildWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    //[Polaroid polaroidWithInfo:photoDictionary inManagedObjectContext:self.managedObjectContext];
}

- (void)fetchWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    if (self.managedObjectContext)
    {
        [self fetchPhotos:completionHandler];
    }
    else
    {
        if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(NO);
        });
    }
}

////////////////////////////////////////////////////GET DATA FROM SERVER
- (void)fetchPhotos:(void (^)(BOOL success))completionHandler
{
    NSNumber *lastFetchedPolaroidId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFetchedPolaroidId"];
    
    if(!lastFetchedPolaroidId)
        lastFetchedPolaroidId = [NSNumber numberWithInt:0];
    
    int fetchLimit = 20;

    NSString *fetchURL = [NSString stringWithFormat:@"http://thawing-ocean-9569.herokuapp.com/polaroids/%@/%d",lastFetchedPolaroidId,fetchLimit];
    NSLog(@"Fetching polaroid data from the server");
    NSURL *url = [[NSURL alloc] initWithString:fetchURL];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("Polaroid Polaroid Fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        self.polaroidArrayFromServer = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        [self.managedObjectContext performBlock:^{

            NSNumber *tempID = [NSNumber numberWithInt:0];
            
            NSLog(@"Polaroids fetched from the server: %@", self.polaroidArrayFromServer);
            
            for (NSDictionary *photoDictionary in _polaroidArrayFromServer)
            {
                Polaroid *polaroid = [Polaroid polaroidWithInfo:photoDictionary inManagedObjectContext:self.managedObjectContext];
                
                if([tempID intValue] < polaroid.polaroid_ID)
                    tempID = [NSNumber numberWithInt:polaroid.polaroid_ID];
            }
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:tempID forKey:@"lastFetchedPolaroidId"];
            [userDefault synchronize];

            
            if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });

        }];
    });
}

////////////////////////END GET DATA FROM SERVER

@end
