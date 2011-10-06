//
//  BKRelationshipMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKRelationshipMap.h"

@implementation BKRelationshipMap

@synthesize relationshipName, destinationEntityName, entityName, isToMany;

- (void)dealloc {
    [relationshipName release], self.relationshipName = nil;
    [destinationEntityName release], self.destinationEntityName = nil;
    [entityName release], self.entityName = nil;

    [super dealloc];
}

+ (BKRelationshipMap *)mapForRelationshipNamed:(NSString *)relationshipName
                   withRelationshipDescription:(NSRelationshipDescription *)description {
    
    BKRelationshipMap *map = [[[BKRelationshipMap alloc] init] autorelease];

    map.relationshipName = relationshipName;
    map.destinationEntityName = description.destinationEntity.name;
    map.entityName = description.entity.name;
    map.isToMany = description.isToMany;
        
    return map;
}

@end
