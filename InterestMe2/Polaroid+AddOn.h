//
//  Polaroid+AddOn.h
//  InterestMe2
//
//  Created by Collin Wallace on 5/28/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import "Polaroid.h"

@interface Polaroid (AddOn)
+ (Polaroid *)polaroidWithInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;
@end
