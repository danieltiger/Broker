//
//  BKRelationshipMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import "BKRelationshipDescription.h"

@implementation BKRelationshipDescription

@synthesize destinationEntityName, 
            isToMany;

- (void)dealloc {
    [destinationEntityName release];

    [super dealloc];
}

+ (BKRelationshipDescription *)descriptionWithRelationshipDescription:(NSRelationshipDescription *)description {
    
    BKRelationshipDescription *map = [[[BKRelationshipDescription alloc] init] autorelease];

    map.localPropertyName = description.name;
    map.destinationEntityName = description.destinationEntity.name;
    map.entityName = description.entity.name;
    map.isToMany = description.isToMany;
        
    return map;
}

@end
