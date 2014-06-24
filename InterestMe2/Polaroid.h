//
//  Polaroid.h
//  InterestMe2
//
//  Created by Collin Wallace on 6/2/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Polaroid : NSManagedObject

@property (nonatomic) BOOL boringToMe;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic) BOOL interestingToMe;
@property (nonatomic) int32_t numberOfPeopleBoredByThis;
@property (nonatomic) int32_t numberOfPeopleInterestedInThis;
@property (nonatomic) int32_t numberOfTimesSaved;
@property (nonatomic) int32_t numberOfTimesSent;
@property (nonatomic) BOOL savedByMe;
@property (nonatomic) BOOL sentByMe;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSManagedObject *wasBoringToThisUser;
@property (nonatomic, retain) NSManagedObject *wasInterestingToThisUser;
@property (nonatomic, retain) NSManagedObject *wasSavedByThisUser;
@property (nonatomic, retain) NSManagedObject *wasSentByThisUser;

@end
