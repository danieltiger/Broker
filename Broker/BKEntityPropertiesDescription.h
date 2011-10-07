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

@interface BKEntityPropertiesDescription : NSObject {
@private
    NSString *entityName;
    NSMutableDictionary *propertiesDescriptions;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSMutableDictionary *propertiesDescriptions;

+ (BKEntityPropertiesDescription *)descriptionForEntityName:(NSString *)entityName 
                                       withPropertiesByName:(NSDictionary *)properties
                                    andMapNetworkAttributes:(NSArray *)networkAttributes
                                          toLocalAttributes:(NSArray *)localAttributes;

- (BKAttributeDescription *)attributeDescriptionForLocalProperty:(NSString *)property;
- (BKAttributeDescription *)attributeDescriptionForNetworkProperty:(NSString *)property;

- (BKRelationshipDescription *)relationshipMapForProperty:(NSString *)property;

- (BOOL)isPropertyRelationship:(NSString *)property;

@end
