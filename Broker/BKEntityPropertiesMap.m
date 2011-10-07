//
//  BKEntityPropertiesMap.m
//  Broker
//
//  Created by Andrew Smith on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKEntityPropertiesMap.h"

@implementation BKEntityPropertiesMap

@synthesize entityName,
            networkToLocalMap,
            localToNetworkMap;

- (void)dealloc {
    [entityName release];
    [networkToLocalMap release];
    [localToNetworkMap release];
    
    [super dealloc];
}

+ (BKEntityPropertiesMap *)mapFromNetworkProperties:(NSArray *)networkProperties 
                                  toLocalProperties:(NSArray *)localProperties 
                                          forEntity:(NSString *)entityName {
    
    NSAssert((networkProperties.count == localProperties.count), @"Mapping network properties to local properties expects arrays of the same size");
    
    if (networkProperties.count != localProperties.count) return nil;
    
    BKEntityPropertiesMap *map = [[[BKEntityPropertiesMap alloc] init] autorelease];
    
    NSMutableDictionary *tempNetworkToLocalMap = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableDictionary *tempLocalToNetworkMap = [[[NSMutableDictionary alloc] init] autorelease];

    for (NSString *networkProperty in networkProperties) {
        
        NSString *localProperty = [localProperties objectAtIndex:[networkProperties indexOfObject:networkProperty]];
        
        [tempNetworkToLocalMap setValue:localProperty forKey:networkProperty];
        
        [tempLocalToNetworkMap setValue:networkProperty forKey:localProperty];
    }
    
    map.entityName = entityName;
    map.networkToLocalMap = tempNetworkToLocalMap;
    map.localToNetworkMap = tempLocalToNetworkMap;
    
    return map;
}

- (NSString *)networkPropertyNameForLocalProperty:(NSString *)localProperty {
    return [self.localToNetworkMap valueForKey:localProperty];
}

- (NSString *)localPropertyNameForNetworkProperty:(NSString *)networkProperty {
    return [self.networkToLocalMap valueForKey:networkProperty];
}

@end
