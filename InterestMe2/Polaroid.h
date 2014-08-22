//
//  Polaroid.h
//  InterestMe
//
//  Created by Collin Wallace on 7/25/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Polaroid : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic) BOOL boringToMe;
@property (nonatomic) NSTimeInterval dateTaken;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic) BOOL interestingToMe;
@property (nonatomic) int32_t numberOfPeopleBoredByThis;
@property (nonatomic) int32_t numberOfPeopleInterestedInThis;
@property (nonatomic) int32_t numberOfTimesSaved;
@property (nonatomic) int32_t numberOfTimesSent;
@property (nonatomic) int32_t polaroid_ID;
@property (nonatomic, retain) NSString * polaroidDescription;
@property (nonatomic) BOOL savedByMe;
@property (nonatomic) BOOL sentByMe;
@property (nonatomic, retain) NSString * sourceURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) BOOL viewed;
@property (nonatomic, retain) NSSet *allUsersBoredByThisPolaroid;
@property (nonatomic, retain) NSSet *allUsersInterestedByThisPolaroid;
@property (nonatomic, retain) NSSet *allUsersThatSavedThisPolaroid;
@property (nonatomic, retain) NSSet *allUsersThatSentThisPolaroid;
@end

@interface Polaroid (CoreDataGeneratedAccessors)

- (void)addAllUsersBoredByThisPolaroidObject:(User *)value;
- (void)removeAllUsersBoredByThisPolaroidObject:(User *)value;
- (void)addAllUsersBoredByThisPolaroid:(NSSet *)values;
- (void)removeAllUsersBoredByThisPolaroid:(NSSet *)values;

- (void)addAllUsersInterestedByThisPolaroidObject:(User *)value;
- (void)removeAllUsersInterestedByThisPolaroidObject:(User *)value;
- (void)addAllUsersInterestedByThisPolaroid:(NSSet *)values;
- (void)removeAllUsersInterestedByThisPolaroid:(NSSet *)values;

- (void)addAllUsersThatSavedThisPolaroidObject:(User *)value;
- (void)removeAllUsersThatSavedThisPolaroidObject:(User *)value;
- (void)addAllUsersThatSavedThisPolaroid:(NSSet *)values;
- (void)removeAllUsersThatSavedThisPolaroid:(NSSet *)values;

- (void)addAllUsersThatSentThisPolaroidObject:(User *)value;
- (void)removeAllUsersThatSentThisPolaroidObject:(User *)value;
- (void)addAllUsersThatSentThisPolaroid:(NSSet *)values;
- (void)removeAllUsersThatSentThisPolaroid:(NSSet *)values;

@end
