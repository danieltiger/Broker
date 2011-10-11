//
//  BKPropertyDescription.m
//  Broker
//
//  Created by Andrew Smith on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKPropertyDescription.h"

@implementation BKPropertyDescription

@synthesize entityName, 
            localPropertyName, 
            networkPropertyName;

- (void)dealloc {
    [entityName release];
    [localPropertyName release];
    [networkPropertyName release];
    
    [super dealloc];
}

@end
