//
//  BKEntityPropertiesMap.h
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BKAttributeDescription.h"
#import "BKRelationshipDescription.h"
#import "BKEntityPropertiesMap.h"

@interface BKEntityPropertiesDescription : NSObject {
@private
    NSString *entityName;
    NSMutableDictionary *propertiesDescriptions;
    BKEntityPropertiesMap *propertiesMap;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSMutableDictionary *propertiesDescriptions;
@property (nonatomic, retain) BKEntityPropertiesMap *propertiesMap;

/**
 * Creates a new BKEntityPropertiesDescription where the entityName is the name 
 * of the entity, the properties is the
 */
+ (BKEntityPropertiesDescription *)descriptionForEntityName:(NSString *)entityName 
                                       withPropertiesByName:(NSDictionary *)properties
                                    andMapNetworkProperties:(NSArray *)networkProperties
                                          toLocalProperties:(NSArray *)localProperties;

/**
 * Returns the attribute description for the local property name on the enity
 */
- (BKAttributeDescription *)attributeDescriptionForLocalProperty:(NSString *)property;

/**
 * Returns the attribute description for the network property name on the entity.
 * Returns nil if property not in model, or if property is not a attribute.
 */
- (BKAttributeDescription *)attributeDescriptionForNetworkProperty:(NSString *)property;

/**
 * Returns the relationship description for the local property relationship name
 * on the entity.  Returns nil if property is not in the model, or if property is
 * not a relationship.
 */
- (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)property;

/**
 * Returns true if the property is a relationship
 */
- (BOOL)isPropertyRelationship:(NSString *)property;

- (NSString *)destinationEntityNameForRelationship:(NSString *)relationship;

@end
