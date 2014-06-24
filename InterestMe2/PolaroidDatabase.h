//
//  FlickrDatabase.h
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//
//  This class only works on the main queue!

#import <Foundation/Foundation.h>

#define PolaroidDatabaseAvailable @"PolaroidDatabaseAvailable"

@interface PolaroidDatabase : NSObject

+ (PolaroidDatabase *)sharedDefaultPolaroidDatabase;
+ (PolaroidDatabase *)sharedPolaroidDatabaseWithName:(NSString *)name;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void)fetch;
- (void)fetchWithCompletionHandler:(void (^)(BOOL success))completionHandler;

@end
