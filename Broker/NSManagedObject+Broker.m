//
//  NSManagedObject+Broker.m
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObject+Broker.h"

@implementation NSManagedObject (Broker)

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary) {
        [self setValue:[dictionary valueForKey:key]
                forKey:key];
    }
}

@end
