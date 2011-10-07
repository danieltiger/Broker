//
//  BKRelationshipMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BKRelationshipDescription : NSObject {
@private
    NSString *localRelationshipName;
    NSString *networkRelationshipName;
    NSString *destinationEntityName;
    NSString *entityName;
    BOOL isToMany;
}

@property (nonatomic, copy) NSString *localRelationshipName;
@property (nonatomic, copy) NSString *destinationEntityName;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, assign) BOOL isToMany;

+ (BKRelationshipDescription *)descriptionWithRelationshipDescription:(NSRelationshipDescription *)description;

@end
