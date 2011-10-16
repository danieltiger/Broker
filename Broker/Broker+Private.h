//
//  Broker+Private.h
//  Broker
//
//  Created by Andrew Smith on 10/8/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
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

+ (void)processJSONCollection:(NSArray *)collection
                    forObject:(NSManagedObject *)object
        withEntityDescription:(BKEntityPropertiesDescription *)description
              forRelationship:(NSString *)relationship
                    inContext:(NSManagedObjectContext *)aContext;

+ (void)processSubJSONObject:(NSDictionary *)subDictionary 
                   forObject:(NSManagedObject *)object 
             withDescription:(BKEntityPropertiesDescription *)description
                   inContext:(NSManagedObjectContext *)aContext;

+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
                 usingEntityPropertiesDescription:(BKEntityPropertiesDescription *)entityMap;

+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)aContext;

+ (NSManagedObject *)findOrCreateObjectForEntityDescribedBy:(BKEntityPropertiesDescription *)description 
                                        withPrimaryKeyValue:(id)value
                                                  inContext:(NSManagedObjectContext *)aContext
                                               shouldCreate:(BOOL)create;

@end
