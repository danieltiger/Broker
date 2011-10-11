//
//  Broker+Private.m
//  Broker
//
//  Created by Andrew Smith on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker+Private.h"

@implementation Broker (Private)

+ (void)asyncProcessJSONObject:(id)jsonObject 
                  targetEntity:(NSURL *)entityURI 
            targetRelationship:(NSString *)relationshipName
                     inContext:(NSManagedObjectContext *)aContext
           withCompletionBlock:(void (^)())CompletionBlock {
    
    dispatch_queue_t jsonProcessingQueue = dispatch_queue_create("com.Broker.jsonProcessingQueue", NULL);
    
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
                          forObject:object
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
                    forObject:(NSManagedObject *)object
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

    NSMutableSet *relationshipObjects = [object mutableSetValueForKey:relationship];
    
    for (id dictionary in collection) {
        
        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"Collection object must be a dictionary");
        if (![dictionary isKindOfClass:[NSDictionary class]]) continue;
        
        // Transform
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)dictionary 
                                     usingEntityPropertiesDescription:destinationEntityDesc];
        
        // Get the primary key value
        id value = [transformedDict objectForKey:destinationEntityDesc.primaryKey];
        
        NSManagedObject *collectionObject = [Broker findOrCreateObjectForEntityDescribedBy:destinationEntityDesc 
                                                                       withPrimaryKeyValue:value
                                                                                 inContext:aContext
                                                                              shouldCreate:YES];
        
        [self processSubJSONObject:transformedDict
                         forObject:collectionObject
                   withDescription:destinationEntityDesc
                         inContext:aContext];
        
        if (collectionObject) {
            [relationshipObjects addObject:collectionObject];
        }
    }
}

+ (void)processSubJSONObject:(NSDictionary *)subDictionary 
                   forObject:(NSManagedObject *)object 
             withDescription:(BKEntityPropertiesDescription *)description 
                   inContext:(NSManagedObjectContext *)aContext {
    
    for (NSString *property in subDictionary) {
        if ([description isPropertyRelationship:property]) {
            
            id value = [subDictionary valueForKey:property];            
            
            BKEntityPropertiesDescription *destinationEntityDesc = [self destinationEntityPropertiesDescriptionForRelationship:property
                                                                                                                 onEntityNamed:object.entity.name];
            
            // Flat
            if ([value isKindOfClass:[NSDictionary class]]) {
                                
                NSDictionary *transformedDict = [self transformJSONDictionary:value 
                                             usingEntityPropertiesDescription:destinationEntityDesc];
                
                // Get the primary key value
                id primaryKeyValue = [transformedDict objectForKey:destinationEntityDesc.primaryKey];
                
                NSManagedObject *relationshipObject = [Broker findOrCreateObjectForEntityDescribedBy:destinationEntityDesc 
                                                                                 withPrimaryKeyValue:primaryKeyValue
                                                                                           inContext:aContext
                                                                                        shouldCreate:YES];                
                [self processSubJSONObject:transformedDict
                                 forObject:relationshipObject
                           withDescription:destinationEntityDesc
                                 inContext:aContext];
                
                // Set the destination object
                [object setValue:relationshipObject forKey:property];
            }
            
            // Collection
            if ([value isKindOfClass:[NSArray class]]) {
                [self processJSONCollection:value
                                  forObject:object
                      withEntityDescription:description
                            forRelationship:property 
                                  inContext:aContext];
            }
            
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

        // Get the property description
        BKPropertyDescription *description = [propertiesDescription descriptionForLocalProperty:property];
        if (!description) {
            // if no description, it could be a network property
            description = [propertiesDescription descriptionForNetworkProperty:property];
            if (!description) DLog(@"No description for property %@ found on entity %@!", property, propertiesDescription.entityName); continue;
        }

        // get the original value
        id value = [jsonDictionary valueForKey:property];

        // Test to see if networkProperty is relationship or attribute
        if ([propertiesDescription isPropertyRelationship:property]) {
            [transformedDict setObject:value forKey:description.localPropertyName];
        } else {
            
            // transform it using the attribute desc
            id valueAsObject = [(BKAttributeDescription *)description objectForValue:value];
            
            // Add it to the transformed dictionary
            if (valueAsObject) {
                [transformedDict setObject:valueAsObject
                                    forKey:description.localPropertyName];
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

+ (NSManagedObject *)findOrCreateObjectForEntityDescribedBy:(BKEntityPropertiesDescription *)description 
                                        withPrimaryKeyValue:(id)value
                                                  inContext:(NSManagedObjectContext *)aContext
                                               shouldCreate:(BOOL)create {  
    
    NSAssert(description, @"Must have a description");
    if (!description) return nil;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:description.entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%@ = %@", description.primaryKey, value]];
    
    NSError *error;
    NSArray *array = [aContext executeFetchRequest:request error:&error];
    
    if (create && array.count == 0) {
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:description.entityName 
                                                                inManagedObjectContext:aContext];
        return object;
    }
    
    return nil;
}

@end
