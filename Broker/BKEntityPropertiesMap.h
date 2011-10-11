//
//  BKEntityPropertiesMap.h
//  Broker
//
//  Created by Andrew Smith on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKEntityPropertiesMap : NSObject{
@private
    NSString *entityName;
    NSMutableDictionary *networkToLocalMap;
    NSMutableDictionary *localToNetworkMap;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, retain) NSMutableDictionary *networkToLocalMap;
@property (nonatomic, retain) NSMutableDictionary *localToNetworkMap;

+ (BKEntityPropertiesMap *)mapFromNetworkProperties:(NSArray *)networkProperties 
                                  toLocalProperties:(NSArray *)localProperties 
                                          forEntityName:(NSString *)entityName;

- (NSString *)networkPropertyNameForLocalProperty:(NSString *)localProperty;
- (NSString *)localPropertyNameForNetworkProperty:(NSString *)networkProperty;

@end
