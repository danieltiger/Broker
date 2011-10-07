//
//  BKRelationshipMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKRelationshipDescription.h"

@implementation BKRelationshipDescription

@synthesize localRelationshipName,
            networkRelationshipName,
            destinationEntityName, 
            entityName,
            isToMany;

- (void)dealloc {
    [localRelationshipName release];
    [localRelationshipName release];
    [destinationEntityName release];
    [entityName release];

    [super dealloc];
}

+ (BKRelationshipDescription *)descriptionWithRelationshipDescription:(NSRelationshipDescription *)description {
    
    BKRelationshipDescription *map = [[[BKRelationshipDescription alloc] init] autorelease];

    map.localRelationshipName = description.name;
    map.destinationEntityName = description.destinationEntity.name;
    map.entityName = description.entity.name;
    map.isToMany = description.isToMany;
        
    return map;
}

@end
