//
//  Polaroid+AddOn.m
//  InterestMe2
//
//  Created by Collin Wallace on 5/28/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "Polaroid+AddOn.h"
#import "Polaroid.h"

@implementation Polaroid (AddOn)

+ (Polaroid *)polaroidWithInfo:(NSDictionary *)photoDictionary
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Polaroid *polaroid = nil;
    
    NSString *imageURL = @"";
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Polaroid"];
    request.predicate = [NSPredicate predicateWithFormat:@"imageURL = %@", imageURL];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        polaroid = [NSEntityDescription insertNewObjectForEntityForName:@"Polaroid"
                                              inManagedObjectContext:context];
        
        polaroid.image = [[NSData alloc] init];//Call some function to download image from URL
        polaroid.imageURL = [photoDictionary objectForKey:@"imageURL"];
        polaroid.title = [photoDictionary objectForKey:@"title"];
        polaroid.genre = [photoDictionary objectForKey:@"genre"];
        
        polaroid.interestingToMe = NO;
        polaroid.boringToMe = NO;
        polaroid.savedByMe = NO;
        polaroid.sentByMe = NO;
        
        polaroid.numberOfPeopleBoredByThis = 0;
        polaroid.numberOfPeopleInterestedInThis = 0;
        polaroid.numberOfTimesSaved = 0;
        polaroid.numberOfTimesSent = 0;

        

    } else {
        polaroid = [matches firstObject];
    }
    
    return polaroid;
}

@end