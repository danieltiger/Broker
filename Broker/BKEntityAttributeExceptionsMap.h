//
//  BKEntityMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKEntityAttributeExceptionsMap : NSObject {
@private
    NSString *entityType;
    NSMutableDictionary *map;
}

@property (nonatomic, copy) NSString *entityType;
@property (nonatomic, retain) NSMutableDictionary *map;

+ (BKEntityAttributeExceptionsMap *)mapFromNetworkAttributes:(NSArray *)networkAttributes toLocalAttributes:(NSArray *)localAttributes;

- (BOOL)hasExceptionForNetworkAttribute:(NSString *)attributeName;

- (NSString *)localAttributeForNetworkAttribute:(NSString *)attributeName;

@end
