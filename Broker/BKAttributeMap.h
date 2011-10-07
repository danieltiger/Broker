//
//  BKEntityMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BKAttributeMap : NSObject {
@private
    NSString *entityName;
    NSString *localAttributeName;
    NSString *networkAttributeName;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *localAttributeName;
@property (nonatomic, copy) NSString *networkAttributeName;
@property (nonatomic, assign) NSAttributeType attributeType;

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description;

+ (BKAttributeMap *)mapWithAttributeDescription:(NSAttributeDescription *)description
                  registerNetworkAttributeNames:(NSArray *)networkNames
                         forLocalAttributeNames:(NSArray *)localNames;

@end
