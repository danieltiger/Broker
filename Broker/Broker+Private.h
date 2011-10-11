//
//  Broker+Private.h
//  Broker
//
//  Created by Andrew Smith on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker.h"

@interface Broker (Private)

+ (void)asyncProcessJSONObject:(id)jsonObject 
             targetEntity:(NSURL *)entityURI 
       targetRelationship:(NSString *)relationshipName
                inContext:(NSManagedObjectContext *)aContext
      withCompletionBlock:(void (^)())CompletionBlock;

+ (void)syncProcessJSONObject:(id)jsonObject 
                 targetEntity:(NSURL *)entityURI 
           targetRelationship:(NSString *)relationshipName
                    inContext:(NSManagedObjectContext *)aContext
          withCompletionBlock:(void (^)())CompletionBlock;

+ (void)processCollection:(NSArray *)collection
          ofEntitiesNamed:(NSString *)entityName
          withDescription:(BKEntityPropertiesDescription *)description
             objectBucket:(NSMutableSet *)bucket;





+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
                 usingEntityPropertiesMap:(BKEntityPropertiesDescription *)entityMap;

+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)aContext;

@end
