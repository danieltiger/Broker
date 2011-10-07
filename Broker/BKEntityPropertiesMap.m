//
//  BKEntityPropertiesMap.m
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKEntityPropertiesMap.h"
#import <CoreData/CoreData.h>


@implementation BKEntityPropertiesMap

@synthesize entityName, propertiesMap;

- (void)dealloc {
    [entityName release], self.entityName = nil;
    [propertiesMap release], self.propertiesMap = nil;
    
    [super dealloc];
}

+ (BKEntityPropertiesMap *)mapForEntityName:(NSString *)entityName 
                 withPropertiesByName:(NSDictionary *)properties {
    
    BKEntityPropertiesMap *map = [[[BKEntityPropertiesMap alloc] init] autorelease];
    
    NSMutableDictionary *tempPropertiesMap = [[[NSMutableDictionary alloc] init] autorelease];
    
    map.entityName = entityName;
    
    for (NSString *property in properties) {
        
        // Either an NSAttributeDescription or an NSRelationshipDescription
        id description = [properties objectForKey:property];
        
        if ([description isKindOfClass:[NSAttributeDescription class]]) {
            BKAttributeMap *map = [BKAttributeMap mapWithAttributeDescription:(NSAttributeDescription *)description];
            [tempPropertiesMap setObject:map forKey:property];
        }
        
        if ([description isKindOfClass:[NSRelationshipDescription class]]) {
            BKRelationshipMap *map = [BKRelationshipMap mapWithRelationshipDescription:(NSRelationshipDescription *)description];
            [tempPropertiesMap setObject:map forKey:property];
        }
    }
    
    // Done!
    map.propertiesMap = tempPropertiesMap;
    
    return map;
}

- (BKAttributeMap *)attributeMapForLocalProperty:(NSString *)property {
   
    id map = [self.propertiesMap objectForKey:property];
    
    if (map && [map isKindOfClass:[BKAttributeMap class]]) {
        return (BKAttributeMap *)map;
    } else {
        return nil;
    }
    
}

- (BKAttributeMap *)attributeMapForNetworkProperty:(NSString *)property {
    // TODO: Support network/local property name mismatch
    return [self attributeMapForLocalProperty:property];
}

- (BKRelationshipMap *)relationshipMapForProperty:(NSString *)property {
    
    id map = [self.propertiesMap objectForKey:property];
    
    if (map && [map isKindOfClass:[BKRelationshipMap class]]) {
        return (BKRelationshipMap *)map;
    } else {
        return nil;
    }
    
}

- (BOOL)isPropertyRelationship:(NSString *)property {
    
    id map = [self.propertiesMap objectForKey:property];
    
    if (map && [map isKindOfClass:[BKRelationshipMap class]]) {
        return YES;
    } else {
        return NO;
    }
                
}

@end
