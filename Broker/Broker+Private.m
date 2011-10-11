//
//  Broker+Private.m
//  Broker
//
//  Created by Andrew Smith on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker+Private.h"

@implementation Broker (Private)

static dispatch_queue_t jsonProcessingQueue = nil;

+ (void)asyncProcessJSONObject:(id)jsonObject 
                  targetEntity:(NSURL *)entityURI 
            targetRelationship:(NSString *)relationshipName
                     inContext:(NSManagedObjectContext *)aContext
           withCompletionBlock:(void (^)())CompletionBlock {
    
    if (!jsonProcessingQueue) {
        jsonProcessingQueue = dispatch_queue_create("com.Broker.jsonProcessingQueue", NULL);
    }
    
    dispatch_async(jsonProcessingQueue, ^{
        [self syncProcessJSONObject:jsonObject
                       targetEntity:entityURI
                 targetRelationship:relationshipName
                          inContext:aContext
                withCompletionBlock:CompletionBlock];
    });
    
    dispatch_release(jsonProcessingQueue);
}

+ (void)syncProcessJSONObject:(id)jsonObject 
                 targetEntity:(NSURL *)entityURI 
           targetRelationship:(NSString *)relationshipName
                    inContext:(NSManagedObjectContext *)aContext 
          withCompletionBlock:(void (^)())CompletionBlock {
    
    NSManagedObject *object = [self objectWithURI:entityURI inContext:aContext];
    
    BKEntityPropertiesDescription *description = [self entityPropertyMapForEntityName:object.entity.name];
    
    NSMutableSet *bucket = [[NSMutableSet alloc] init];
    
    // Flat
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {

        // Transform
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)jsonObject 
                                             usingEntityPropertiesMap:description];
        
        for (NSString *property in transformedDict) {
            
            if ([description isPropertyRelationship:property]) {
                // Relationship!
            } else {
                [object setValue:[transformedDict valueForKey:property]
                          forKey:property];        
            }
        }
        
    }
    
    // Collection
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        
        NSString *entityName = nil;
        
        if (relationshipName) {
            entityName = [description destinationEntityNameForRelationship:relationshipName];
        } else {
            entityName = description.entityName;
        }
        
        [self processCollection:(NSArray *)jsonObject
                ofEntitiesNamed:entityName
                withDescription:description
                   objectBucket:bucket];
        
    }
    
    // Save context
    if (aContext.hasChanges) {
        NSError *error = nil;
        [aContext save:&error];
    }
    
    // Execute completion block
    if (CompletionBlock) {
        CompletionBlock();
    }
}

+ (void)processCollection:(NSArray *)collection
          ofEntitiesNamed:entityName
          withDescription:(BKEntityPropertiesDescription *)description2
             objectBucket:(NSMutableSet *)bucket {
    
    // Destination entity description
    BKEntityPropertiesDescription *description = [self entityPropertyMapForEntityName:entityName];
    
    for (id object in collection) {
     
        NSAssert([object isKindOfClass:[NSDictionary class]], @"Collection object must be a dictionary");
        if (![object isKindOfClass:[NSDictionary class]]) continue;
        
        // Transform
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)object 
                                             usingEntityPropertiesMap:description];

        for (NSString *property in transformedDict) {
            
            if ([description isPropertyRelationship:property]) {
                // Relationship!
            } else {
                [object setValue:[transformedDict valueForKey:property]
                          forKey:property];        
            }
        }

    }
}

+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
                 usingEntityPropertiesMap:(BKEntityPropertiesDescription *)entityMap {
    
    NSMutableDictionary *transformedDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *networkProperty in jsonDictionary) {
        
        // Test to see if networkProperty is relationship or attribute
        if ([entityMap isPropertyRelationship:networkProperty]) {
            // It's a relationship
            
        } else {
            // It's an attribute
            
            // grab the map
            BKAttributeDescription *attrMap = [entityMap attributeDescriptionForNetworkProperty:networkProperty];
            
            // get the original value
            id value = [jsonDictionary valueForKey:networkProperty];
            
            // transform it using the attribute map
            id valueAsObject = [attrMap objectForValue:value];
            
            // Add it to the transformed dictionary
            if (valueAsObject) {
                [transformedDict setObject:valueAsObject
                                    forKey:attrMap.localAttributeName];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:transformedDict];
}

#pragma mark - CoreData

+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)aContext {
    NSManagedObjectID *objectID = [[aContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    
    if (!objectID) return nil;
    
    NSManagedObject *objectForID = [aContext objectWithID:objectID];
    
    if (![objectForID isFault]) return objectForID;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[objectID entity]];
    
    // Predicate for fetching self.  Code is faster than string predicate equivalent of 
    // [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject] 
                                                                rightExpression:[NSExpression expressionForConstantValue:objectForID]
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    
    [request setPredicate:predicate];
    
    NSArray *results = [aContext executeFetchRequest:request error:nil];
    if ([results count] > 0 ) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}


@end
