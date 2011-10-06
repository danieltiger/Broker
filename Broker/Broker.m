//
//  Broker.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker.h"
#import "BKAttributeMap.h"

@interface Broker (Private)

@end

@implementation Broker

#pragma mark - Class Instances

static NSManagedObjectContext *context        = nil;
static NSMutableDictionary    *attributeMaps  = nil;

#pragma mark - Setup

+ (void)setupWithContext:(NSManagedObjectContext *)aContext {
    context = aContext;
    attributeMaps = [[NSMutableDictionary alloc] init];
}

#pragma mark - Registration

+ (void)registerEntityName:(NSString *)entityName {
    [self registerEntityName:entityName 
     andMapNetworkAttributes:nil 
           toLocalAttributes:nil];
}

+ (void)registerEntityName:(NSString *)entityName 
   andMapNetworkAttributes:(NSArray *)networkAttributes 
         toLocalAttributes:(NSArray *)localAttributes {
    
    // Attributes
    if (networkAttributes && localAttributes) {
        BKAttributeMap *map = [BKAttributeMap mapFromNetworkAttributes:networkAttributes 
                                                     toLocalAttributes:localAttributes
                                                         forEntityType:entityName];
        [attributeMaps setObject:map forKey:entityName];
    }
    
    // Relationships
    [self registerRelationshipsForEntityName:entityName];
}

+ (void)registerRelationshipsForEntityName:(NSString *)entityName {
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                            inManagedObjectContext:context];
    
    NSDictionary *relationships = [object.entity relationshipsByName];
    
    for (NSString *relationship in relationships) {
        
        
    }
    
}



@end
