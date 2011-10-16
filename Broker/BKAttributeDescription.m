//
//  BKEntityMap.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import "BKAttributeDescription.h"

@implementation BKAttributeDescription

@synthesize dateFormat,
            attributeType;

- (void)dealloc {
    [dateFormat release];
    [dateFormatter release];
    
    [super dealloc];
}

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
            
            NSAssert(self.dateFormat, @"NSDate attribute on entity %@ requires " 
                     @"date format to be set.  Use [Broker setDateFormat:forProperty:onEntity:]", self.entityName);
            if (!self.dateFormat) return nil;
            
            return [self.dateFormatter dateFromString:value];
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

#pragma mark - Accessors

- (NSDateFormatter *)dateFormatter {
    if (dateFormatter) return [[dateFormatter retain] autorelease];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:self.dateFormat];
    
    return [[dateFormatter retain] autorelease];
}

@end
