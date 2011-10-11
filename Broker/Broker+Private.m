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
    
    //dispatch_release(jsonProcessingQueue);
}

+ (void)syncProcessJSONObject:(id)jsonObject 
                 targetEntity:(NSURL *)entityURI 
           targetRelationship:(NSString *)relationshipName
                    inContext:(NSManagedObjectContext *)aContext 
          withCompletionBlock:(void (^)())CompletionBlock {
    
    NSManagedObject *object = [self objectWithURI:entityURI inContext:aContext];
    
    BKEntityPropertiesDescription *description = [self entityPropertyDescriptionForEntityName:object.entity.name];
    
    //NSMutableSet *bucket = [[NSMutableSet alloc] init];
    
    // Flat
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {

        // Transform
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)jsonObject 
                                             usingEntityPropertiesDescription:description];
        
        [self processSubJSONObject:transformedDict
                         forObject:object
                   withDescription:description
                         inContext:aContext];        
    }
    
    // Collection
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        
        NSString *entityName = nil;
        
        if (relationshipName) {
            entityName = [description destinationEntityNameForRelationship:relationshipName];
        } else {
            entityName = description.entityName;
        }
        
        [self processJSONCollection:jsonObject
              withEntityDescription:description
                    forRelationship:relationshipName
                          inContext:aContext];
        
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

+ (void)processJSONCollection:(NSArray *)collection
        withEntityDescription:(BKEntityPropertiesDescription *)description
              forRelationship:(NSString *)relationship 
                    inContext:(NSManagedObjectContext *)aContext {
    
    NSString *destinationEntityName = nil;
    if (relationship) {
        destinationEntityName = [description destinationEntityNameForRelationship:relationship];
    } else {
        destinationEntityName = description.entityName;
    }
    
    BKEntityPropertiesDescription *destinationEntityDesc = [self entityPropertyDescriptionForEntityName:destinationEntityName];

    for (id dictionary in collection) {
        
        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"Collection object must be a dictionary");
        if (![dictionary isKindOfClass:[NSDictionary class]]) continue;
        
        // Transform
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)dictionary 
                                             usingEntityPropertiesDescription:description];
        
        // Get the primary key value
        id value = [transformedDict objectForKey:destinationEntityDesc.primaryKey];
        
        NSManagedObject *object = [Broker findEntityDescribedBy:destinationEntityDesc 
                                             withPrimaryKeyName:destinationEntityDesc.primaryKey 
                                             andPrimaryKeyValue:value
                                                      inContext:aContext];
        
        [self processSubJSONObject:transformedDict
                         forObject:object
                   withDescription:destinationEntityDesc
                         inContext:aContext];
        
    }
}

+ (void)processSubJSONObject:(NSDictionary *)subDictionary 
                   forObject:(NSManagedObject *)object 
             withDescription:(BKEntityPropertiesDescription *)description 
                   inContext:(NSManagedObjectContext *)aContext {
    
    for (NSString *property in subDictionary) {
        if ([description isPropertyRelationship:property]) {
            
        } else {
            [object setValue:[subDictionary valueForKey:property]
                      forKey:property];        
        }
    }
}

+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
         usingEntityPropertiesDescription:(BKEntityPropertiesDescription *)propertiesDescription {
        
    NSMutableDictionary *transformedDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *property in jsonDictionary) {
        
        // Test to see if networkProperty is relationship or attribute
        if ([propertiesDescription isPropertyRelationship:property]) {
            
            // It's a relationship
            WLog(@"Relationship");
            
        } else {
            // It's an attribute
            
            // grab the map, assume its a local propertyname first
            BKAttributeDescription *attrDescription = [propertiesDescription attributeDescriptionForLocalProperty:property];
            
            if (!attrDescription) {
                // its a local property name
                attrDescription = [propertiesDescription attributeDescriptionForNetworkProperty:property];
            }
            
            // get the original value
            id value = [jsonDictionary valueForKey:property];
            
            // transform it using the attribute map
            id valueAsObject = [attrDescription objectForValue:value];
            
            // Add it to the transformed dictionary
            if (valueAsObject) {
                [transformedDict setObject:valueAsObject
                                    forKey:attrDescription.localPropertyName];
            }
        }
    }
    
    if ([transformedDict count] == 0) {
        // empty
        return nil;
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

+ (NSManagedObject *)findEntityDescribedBy:(BKEntityPropertiesDescription *)description 
                        withPrimaryKeyName:(NSString *)primaryKeyName 
                        andPrimaryKeyValue:(id)value
                                 inContext:(NSManagedObjectContext *)aContext {    
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:description.entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%@ = %@",primaryKeyName, value]];
    
    NSError *error;
    NSArray *array = [aContext executeFetchRequest:request error:&error];
    
    return nil;
}

@end
