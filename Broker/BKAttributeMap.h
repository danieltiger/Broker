//
//  BKEntityMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKAttributeMap : NSObject {
@private
    NSString *entityName;
    NSMutableDictionary *map;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSMutableDictionary *map;


/**
 * Create a map from network attribute name to local attribute name
 */ 
+ (BKAttributeMap *)mapFromNetworkAttributes:(NSArray *)networkAttributes 
                           toLocalAttributes:(NSArray *)localAttributes
                               forEntityName:(NSString *)entityName;

/**
 * Query to see if network attribute has map
 */
- (BOOL)hasMapForNetworkAttribute:(NSString *)attributeName;

/**
 * Returns the local attribute name for the network attribute
 */
- (NSString *)localAttributeForNetworkAttribute:(NSString *)attributeName;

@end
