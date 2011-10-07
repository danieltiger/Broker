//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKAttributeMap.h"

@implementation BKAttributeMap

@synthesize entityName, 
            localAttributeName, 
            networkAttributeName, 
            attributeType;

- (void)dealloc {
    [entityName release], self.entityName = nil;
    [localAttributeName release], self.localAttributeName = nil;
    [networkAttributeName release], self.networkAttributeName = nil;
    
    [super dealloc];
}

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description {
    
    BKAttributeMap *map = [[[BKAttributeMap alloc] init] autorelease];
    
    map.entityName = description.entity.name;
    map.localAttributeName = description.name;
    map.attributeType = description.attributeType;
    
    return map;
}

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description
                  registerNetworkAttributeNames:(NSArray *)networkNames
                         forLocalAttributeNames:(NSArray *)localNames {
    return nil;
}


@end
