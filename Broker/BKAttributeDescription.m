//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BKAttributeDescription.h"

@implementation BKAttributeDescription

@synthesize attributeType;

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description {
    return [self descriptionWithAttributeDescription:description
                     andMapToNetworkAttributeName:nil];
}

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description
                                   andMapToNetworkAttributeName:(NSString *)networkAttributeName {
    
    BKAttributeDescription *map = [[[BKAttributeDescription alloc] init] autorelease];
    
    map.entityName = description.entity.name;
    map.localPropertyName = description.name;
    map.networkPropertyName = networkAttributeName;
    map.attributeType = description.attributeType;
    
    return map;
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
