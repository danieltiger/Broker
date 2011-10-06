//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKAttributeMap.h"

@implementation BKAttributeMap

@synthesize entityName, map;

- (void)dealloc {
    [entityName release], self.entityName = nil;
    [map release], self.map = nil;
    
    [super dealloc];
}

+ (BKAttributeMap *)mapFromNetworkAttributes:(NSArray *)networkAttributes 
                           toLocalAttributes:(NSArray *)localAttributes
                               forEntityName:(NSString *)entityName {
    return nil;
}

#pragma mark - Accessors

- (BOOL)hasMapForNetworkAttribute:(NSString *)attributeName {
    return NO;
}

- (NSString *)localAttributeForNetworkAttribute:(NSString *)attributeName {
    
    return nil;
}

@end
