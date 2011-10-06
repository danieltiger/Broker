//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKAttributeMap.h"

@implementation BKAttributeMap

@synthesize entityType, map;

+ (BKAttributeMap *)mapFromNetworkAttributes:(NSArray *)networkAttributes toLocalAttributes:(NSArray *)localAttributes {
    
    return nil;
}

#pragma mark - Accessors

- (BOOL)hasExceptionForNetworkAttribute:(NSString *)attributeName {
    return NO;
}

- (NSString *)localAttributeForNetworkAttribute:(NSString *)attributeName {
    
    return nil;
}

@end
