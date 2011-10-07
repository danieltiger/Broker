//
//  BKRelationshipMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKRelationshipDescription.h"

@implementation BKRelationshipDescription

@synthesize localRelationshipName, destinationEntityName, entityName, isToMany;

- (void)dealloc {
    [localRelationshipName release], self.localRelationshipName = nil;
    [destinationEntityName release], self.destinationEntityName = nil;
    [entityName release], self.entityName = nil;

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
