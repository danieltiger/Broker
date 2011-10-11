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

@synthesize entityName,
            primaryKey,
            propertiesDescriptions,
            propertiesMap,
            entityDescription;

- (void)dealloc {
    [entityName release];
    [primaryKey release];
    [propertiesDescriptions release];
    [propertiesMap release];
    [entityDescription release];
    
    [super dealloc];
}

+ (BKEntityPropertiesDescription *)descriptionForEntity:(NSEntityDescription *)entity 
                                   withPropertiesByName:(NSDictionary *)properties
                                andMapNetworkProperties:(NSArray *)networkProperties
                                      toLocalProperties:(NSArray *)localProperties {
    
    BKEntityPropertiesDescription *description = [[[BKEntityPropertiesDescription alloc] init] autorelease];
    
    description.entityDescription = entity;
    description.entityName = entity.name;
    
    BKEntityPropertiesMap *map = [BKEntityPropertiesMap mapFromNetworkProperties:networkProperties
                                                               toLocalProperties:localProperties
                                                                   forEntityName:entity.name];
    
    NSMutableDictionary *tempPropertiesDescriptions = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *property in properties) {
        
        // Either an NSAttributeDescription or an NSRelationshipDescription
        id description = [properties objectForKey:property];
        
        if ([description isKindOfClass:[NSAttributeDescription class]]) {
            BKAttributeDescription *attrDescription = [BKAttributeDescription descriptionWithAttributeDescription:(NSAttributeDescription *)description
                                                                                     andMapToNetworkAttributeName:[map networkPropertyNameForLocalProperty:property]];
                        
            [tempPropertiesDescriptions setObject:attrDescription forKey:property];
        }
        
        if ([description isKindOfClass:[NSRelationshipDescription class]]) {
            BKRelationshipDescription *relationshipDescription = 
                    [BKRelationshipDescription descriptionWithRelationshipDescription:(NSRelationshipDescription *)description];            
            [tempPropertiesDescriptions setObject:relationshipDescription forKey:property];
        }
    }
    
    // Done!
    description.propertiesDescriptions = tempPropertiesDescriptions;
    
    return description;
}

- (BKPropertyDescription *)descriptionForLocalProperty:(NSString *)property {
    return (BKPropertyDescription *)[self.propertiesDescriptions objectForKey:property];
}

- (BKPropertyDescription *)descriptionForNetworkProperty:(NSString *)property {
    __block id result = nil;
    
    [self.propertiesDescriptions enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                                         usingBlock:^(id key, id obj, BOOL *stop) {
                                                             
                                                             BKPropertyDescription *description = [self descriptionForLocalProperty:key];
                                                             
                                                             if (description && [description.networkPropertyName isEqualToString:property]) {
                                                                 result = obj;
                                                                 *stop = YES;
                                                             }
                                                         }];
    
    if (!result) {
        WLog(@"%@ is not a known network property", property);
        return nil;
    }
    
    return (BKPropertyDescription *)result;
}

- (BKAttributeDescription *)attributeDescriptionForLocalProperty:(NSString *)property {
    id description = [self descriptionForLocalProperty:property];
    if (description && [description isKindOfClass:[BKAttributeDescription class]]) {
        return (BKAttributeDescription *)description;
    } else {
        return nil;
    }
}

- (BKAttributeDescription *)attributeDescriptionForNetworkProperty:(NSString *)property {
    id description = [self descriptionForNetworkProperty:property];
    if (description && [description isKindOfClass:[BKAttributeDescription class]]) {
        return (BKAttributeDescription *)description;
    } else {
        return nil;
    }
}

- (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)property {
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

- (NSString *)destinationEntityNameForRelationship:(NSString *)relationship {
    BKRelationshipDescription *desc = [self relationshipDescriptionForProperty:relationship];
    return desc.destinationEntityName;
}

@end
