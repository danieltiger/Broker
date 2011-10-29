//
//  BKPropertyDescription.m
//  Broker
//
//  Created by Andrew Smith on 10/10/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import "BKPropertyDescription.h"

@implementation BKPropertyDescription

@synthesize entityName, 
            localPropertyName, 
            networkPropertyName;

- (void)dealloc {
    [entityName release], entityName = nil;
    [localPropertyName release], localPropertyName = nil;
    [networkPropertyName release], networkPropertyName = nil;
    
    [super dealloc];
}

@end
