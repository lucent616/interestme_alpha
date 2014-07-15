//
//  User.h
//  InterestMe2
//
//  Created by Collin Wallace on 6/25/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Polaroid;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet *allPolaroidsBoringToThisUser;
@property (nonatomic, retain) NSSet *allPolaroidsInterestingToThisUser;
@property (nonatomic, retain) NSSet *allPolaroidsSavedByThisUser;
@property (nonatomic, retain) NSSet *allPolaroidsSentByThisUser;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAllPolaroidsBoringToThisUserObject:(Polaroid *)value;
- (void)removeAllPolaroidsBoringToThisUserObject:(Polaroid *)value;
- (void)addAllPolaroidsBoringToThisUser:(NSSet *)values;
- (void)removeAllPolaroidsBoringToThisUser:(NSSet *)values;

- (void)addAllPolaroidsInterestingToThisUserObject:(Polaroid *)value;
- (void)removeAllPolaroidsInterestingToThisUserObject:(Polaroid *)value;
- (void)addAllPolaroidsInterestingToThisUser:(NSSet *)values;
- (void)removeAllPolaroidsInterestingToThisUser:(NSSet *)values;

- (void)addAllPolaroidsSavedByThisUserObject:(Polaroid *)value;
- (void)removeAllPolaroidsSavedByThisUserObject:(Polaroid *)value;
- (void)addAllPolaroidsSavedByThisUser:(NSSet *)values;
- (void)removeAllPolaroidsSavedByThisUser:(NSSet *)values;

- (void)addAllPolaroidsSentByThisUserObject:(Polaroid *)value;
- (void)removeAllPolaroidsSentByThisUserObject:(Polaroid *)value;
- (void)addAllPolaroidsSentByThisUser:(NSSet *)values;
- (void)removeAllPolaroidsSentByThisUser:(NSSet *)values;

@end
