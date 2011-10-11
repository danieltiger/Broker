//
//  BKEntityMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BKPropertyDescription.h"

@interface BKAttributeDescription : BKPropertyDescription

@property (nonatomic, assign) NSAttributeType attributeType;

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description;

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description
                                   andMapToNetworkAttributeName:(NSString *)networkAttributeName;

- (id)objectForValue:(id)value;

@end
