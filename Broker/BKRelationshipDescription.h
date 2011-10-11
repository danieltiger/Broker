//
//  BKRelationshipMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BKPropertyDescription.h"

@interface BKRelationshipDescription : BKPropertyDescription {
@private
    NSString *destinationEntityName;
    BOOL isToMany;
}

@property (nonatomic, copy) NSString *destinationEntityName;
@property (nonatomic, assign) BOOL isToMany;

+ (BKRelationshipDescription *)descriptionWithRelationshipDescription:(NSRelationshipDescription *)description;

@end
