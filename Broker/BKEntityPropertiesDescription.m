//
//  BKEntityPropertiesMap.m
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKEntityPropertiesDescription.h"
#import <CoreData/CoreData.h>


@implementation BKEntityPropertiesDescription

@synthesize entityName, propertiesDescriptions;

- (void)dealloc {
    [entityName release], self.entityName = nil;
    [propertiesDescriptions release], self.propertiesDescriptions = nil;
    
    [super dealloc];
}

+ (BKEntityPropertiesDescription *)descriptionForEntityName:(NSString *)entityName 
                       withPropertiesByName:(NSDictionary *)properties
                    andMapNetworkAttributes:(NSArray *)networkAttributes
                          toLocalAttributes:(NSArray *)localAttributes {
    
    BKEntityPropertiesDescription *description = [[[BKEntityPropertiesDescription alloc] init] autorelease];
    description.entityName = entityName;
    
    NSMutableDictionary *tempPropertiesDescriptions = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *property in properties) {
        
        // Either an NSAttributeDescription or an NSRelationshipDescription
        id description = [properties objectForKey:property];
        
        if ([description isKindOfClass:[NSAttributeDescription class]]) {
            BKAttributeDescription *attrDescription = [BKAttributeDescription descriptionWithAttributeDescription:(NSAttributeDescription *)description];
            [tempPropertiesDescriptions setObject:attrDescription forKey:property];
        }
        
        if ([description isKindOfClass:[NSRelationshipDescription class]]) {
            BKRelationshipDescription *relationshipDescription = [BKRelationshipDescription descriptionWithRelationshipDescription:(NSRelationshipDescription *)description];
            [tempPropertiesDescriptions setObject:relationshipDescription forKey:property];
        }
    }
    
    // Done!
    description.propertiesDescriptions = tempPropertiesDescriptions;
    
    return description;
}

- (BKAttributeDescription *)attributeDescriptionForLocalProperty:(NSString *)property {
   
    id description = [self.propertiesDescriptions objectForKey:property];
    
    if (description && [description isKindOfClass:[BKAttributeDescription class]]) {
        return (BKAttributeDescription *)description;
    } else {
        return nil;
    }
    
}

- (BKAttributeDescription *)attributeDescriptionForNetworkProperty:(NSString *)property {
    // TODO: Support network/local property name mismatch
    return [self attributeDescriptionForLocalProperty:property];
}

- (BKRelationshipDescription *)relationshipMapForProperty:(NSString *)property {
    
    id description = [self.propertiesDescriptions objectForKey:property];
    
    if (description && [description isKindOfClass:[BKRelationshipDescription class]]) {
        return (BKRelationshipDescription *)description;
    } else {
        return nil;
    }
    
}

- (BOOL)isPropertyRelationship:(NSString *)property {
    
    id description = [self.propertiesDescriptions objectForKey:property];
    
    if (description && [description isKindOfClass:[BKRelationshipDescription class]]) {
        return YES;
    } else {
        return NO;
    }
                
}

@end