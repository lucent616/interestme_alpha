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
        
        polaroid.imageURL =[photoDictionary valueForKeyPath:@"image_url"];
        polaroid.title = [photoDictionary valueForKeyPath:@"title"];
        polaroid.polaroidDescription = [photoDictionary valueForKey:@"description"];
        polaroid.genre = [photoDictionary valueForKey:@"genre"];
        polaroid.polaroid_ID = [[photoDictionary valueForKey:@"id"] integerValue];
        polaroid.sourceURL = [photoDictionary valueForKey:@"source_url"];
        
        
                           
        
        //NSLog(@"Polaroid: %@", polaroid);

        polaroid.image = [[NSData alloc] init];//Call some function to download image from URL?
        
        polaroid.interestingToMe = NO;
        polaroid.boringToMe = NO;
        polaroid.savedByMe = NO;
        polaroid.sentByMe = NO;
        
        polaroid.numberOfPeopleBoredByThis = [[photoDictionary valueForKey:@"boring_count"] intValue];
        polaroid.numberOfPeopleInterestedInThis = [[photoDictionary valueForKey:@"interesting_count"] intValue];
        polaroid.numberOfTimesSaved = [[photoDictionary valueForKey:@"saved_count"] intValue];
        polaroid.numberOfTimesSent = [[photoDictionary valueForKey:@"sent_count"] intValue];

    } else {
        polaroid = [matches firstObject];
    }
    
    return polaroid;
}

@end