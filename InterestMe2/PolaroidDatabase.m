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

@interface PolaroidDatabase()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation PolaroidDatabase

+ (PolaroidDatabase *)sharedDefaultPolaroidDatabase
{
    return [self sharedPolaroidDatabaseWithName:@"PolaroidDatabase_DEFAULT2"];
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
        // photos is an array of photoDictionary
        NSArray *polaroids = @[
            //Art
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/cd/37/36/cd3736dbd5d56a9bdf08421196c2b404.jpg",
              @"title": @"Topographical Man",
              @"genre": @"Art",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/4f/9f/97/4f9f976730766fc91510f9a6d9e890d0.jpg",
              @"title": @"Eyeball Fish",
              @"genre": @"Art",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/33/95/42/3395428376b68f5109460a9a33e1f0e0.jpg",
              @"title": @"Weeping Tree",
              @"genre": @"Art",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/65/7b/07/657b07d37e88783c19332ef6c530bf00.jpg",
              @"title": @"Kisses in the rain",
              @"genre": @"Art",
              },
            @{@"imageURL": @"http://media-cache-ak0.pinimg.com/736x/fb/f7/ac/fbf7ac0a15de4d90cce6d1d4158817af.jpg",
              @"title": @"Eyes on you",
              @"genre": @"Art",
              },
            
            //Cars
            @{@"imageURL": @"http://media-cache-ak0.pinimg.com/736x/55/0b/c8/550bc8adf0631391759da352b3aa5344.jpg",
              @"title": @"McClarin 12C",
              @"genre": @"Cars",
            },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/cd/06/c6/cd06c6d68cbb6266fc05080dcbcbaafd.jpg",
              @"title": @"1932 Packard",
              @"genre": @"Cars",
              },
            @{@"imageURL": @"http://media-cache-ak0.pinimg.com/736x/a1/c9/a3/a1c9a3e2a570151f2351aa1ca72e4629.jpg",
              @"title": @"Chevy Camaro",
              @"genre": @"Cars",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/d1/33/48/d133480af0706f52f961ee363dc6fb63.jpg",
              @"title": @"Lamborghini Aventador",
              @"genre": @"Cars",
              },
            @{@"imageURL": @"http://media-cache-ak0.pinimg.com/736x/ff/8f/9f/ff8f9f3df4eca006aebb06c028f35aca.jpg",
              @"title": @"Mercedes G-Wagon",
              @"genre": @"Cars",
              },
            
            //Design
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/fd/e0/db/fde0dbb18fc3ef85cdd9cefae81a2cec.jpg",
              @"title": @"Glass Pitcher",
              @"genre": @"Design",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/fd/eb/6e/fdeb6ef8e3fc66a849f1b95deada8729.jpg",
              @"title": @"Foldup Chair",
              @"genre": @"Design",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/66/bb/f6/66bbf6e5d0e51496b5a1dc015a87dd9f.jpg",
              @"title": @"Bookshelf Chair",
              @"genre": @"Design",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/fc/ab/4f/fcab4f4dd1b44d9570886d844d344398.jpg",
              @"title": @"Rotating Clock",
              @"genre": @"Design",
              },
            @{@"imageURL": @"http://media-cache-ak0.pinimg.com/736x/fe/1e/54/fe1e5425997a4ad0eea9e36d1a0a29a0.jpg",
              @"title": @"Flair Chair",
              @"genre": @"Design",
              },
            
            //Homes
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/8d/f7/1e/8df71e52915e3f182e5149ac1d5fbd8b.jpg",
              @"title": @"Dream Bathroom",
              @"genre": @"Homes",
              },
            @{@"imageURL": @"http://media-cache-cd0.pinimg.com/736x/b4/2c/be/b42cbe7c72d60da25eede69c4e5493d2.jpg",
              @"title": @"Antebellum Home",
              @"genre": @"Homes",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/86/40/76/864076816345aa615d572ebf1d3f9108.jpg",
              @"title": @"My Nook",
              @"genre": @"Homes",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/d5/41/d9/d541d918abd0f63893face29a155d39b.jpg",
              @"title": @"Reading Spots",
              @"genre": @"Homes",
              },
            @{@"imageURL": @"http://media-cache-ec0.pinimg.com/736x/e4/2f/db/e42fdb717c6fc1245ddd526fefac545a.jpg",
              @"title": @"Dream Foyer",
              @"genre": @"Homes",
              },
            ];
        
        if (polaroids)
        {
            [self.managedObjectContext performBlock:^{
                // load up the Core Data database
                for (NSDictionary *photoDictionary in polaroids)
                {
                    [Polaroid polaroidWithInfo:photoDictionary inManagedObjectContext:self.managedObjectContext];
                }
                
                if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(YES);
                });
            }];
            
         }
    }
    else
    {
        if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(NO);
        });
    }
}

@end
