//
//  BKEntityPropertiesMap.h
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BKAttributeMap.h"
#import "BKRelationshipMap.h"

@interface BKEntityPropertiesMap : NSObject {
@private
    NSString *entityName;
    NSMutableDictionary *propertiesMap;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSMutableDictionary *propertiesMap;

+ (BKEntityPropertiesMap *)mapForEntityName:(NSString *)entityName 
                 withPropertiesByName:(NSDictionary *)properties;

- (BKAttributeMap *)attributeMapForLocalProperty:(NSString *)property;
- (BKAttributeMap *)attributeMapForNetworkProperty:(NSString *)property;

- (BKRelationshipMap *)relationshipMapForProperty:(NSString *)property;

- (BOOL)isPropertyRelationship:(NSString *)property;

@end
