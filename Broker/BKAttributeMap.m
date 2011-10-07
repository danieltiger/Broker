//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKAttributeMap.h"

@implementation BKAttributeMap

@synthesize entityName, 
            localAttributeName, 
            networkAttributeName, 
            attributeType;

- (void)dealloc {
    [entityName release], self.entityName = nil;
    [localAttributeName release], self.localAttributeName = nil;
    [networkAttributeName release], self.networkAttributeName = nil;
    
    [super dealloc];
}

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description {
    
    BKAttributeMap *map = [[[BKAttributeMap alloc] init] autorelease];
    
    map.entityName = description.entity.name;
    map.localAttributeName = description.name;
    map.attributeType = description.attributeType;
    
    return map;
}

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description
                  registerNetworkAttributeNames:(NSArray *)networkNames
                         forLocalAttributeNames:(NSArray *)localNames {
    return nil;
}

- (id)objectForValue:(id)value {
    
    NSAttributeType type = [self attributeType];
    
    switch (type) {
        case NSUndefinedAttributeType:
            return nil;
            break;
        case NSInteger16AttributeType ... NSInteger64AttributeType:
            return [NSNumber numberWithInt:[value intValue]];
            break;
        case NSDecimalAttributeType:
            return [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
            break;
        case NSDoubleAttributeType:
            return [NSNumber numberWithDouble:[value doubleValue]];
            break;
        case NSFloatAttributeType:
            return [NSNumber numberWithFloat:[value floatValue]];
        case NSStringAttributeType:
            return [NSString stringWithString:value];
            break;
        case NSBooleanAttributeType:
            return [NSNumber numberWithBool:[value boolValue]];
        case NSDateAttributeType:
            return nil;
        case NSBinaryDataAttributeType:
            return nil;
        case NSTransformableAttributeType:
            return nil;
        case NSObjectIDAttributeType:
            return nil;
            break;
        default:
            return nil;
            break;
    }
}

@end
