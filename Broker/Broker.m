//
//  Broker.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker.h"

#import "NSManagedObject+Broker.h"
#import "JSONKit.h"

@interface Broker (Private)

@end

@implementation Broker

#pragma mark - Class Instances

static NSManagedObjectContext *context = nil;
static NSMutableDictionary *propertiesMaps = nil;

static JSONDecoder *decoder = nil;

static dispatch_queue_t jsonParsingQueue = nil;
static dispatch_queue_t jsonProcessingQueue = nil;

#pragma mark - Setup

+ (void)setupWithContext:(NSManagedObjectContext *)aContext {
    context = aContext;
    
    propertiesMaps = [[NSMutableDictionary alloc] init];
    
    // takes JSON payload, returns JSON object
    decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
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
    
    NSAssert(context, @"Broker must be setup with setupWithContext!");
    
    if ([self entityPropertyMapForEntityName:entityName]) {
        WLog(@"Entity named %@ already registered with Broker", entityName);
        return;
    }
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                            inManagedObjectContext:context];
    
    BKEntityPropertiesDescription *map = [BKEntityPropertiesDescription descriptionForEntityName:entityName 
                                                    withPropertiesByName:object.entity.propertiesByName
                                                 andMapNetworkAttributes:networkAttributes
                                                       toLocalAttributes:localAttributes];
    
    [propertiesMaps setObject:map forKey:entityName];
}

+ (void)registerEntityName:(NSString *)entityName withNetworkToLocalAttributeTranslation:(NSDictionary *)networkAttributes {
    
}


#pragma mark - JSON

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI {
    
    [self parseJSONPayload:jsonPayload
              targetEntity:entityURI
        forRelationship:nil];

}

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
      forRelationship:(NSString *)relationshipName {

    if (!jsonParsingQueue) {
        jsonParsingQueue = dispatch_queue_create("com.Broker.jsonParsingQueue", NULL);
    }

    // dispatch parsing on separate thread
    dispatch_async(jsonParsingQueue, ^{ 
        
        // JSONKit decoder
        id jsonObject = [decoder objectWithData:jsonPayload]; 
        
        // process the parsed json
        [Broker processJSONObject:jsonObject 
                     targetEntity:entityURI
               targetRelationship:relationshipName];

    });

    dispatch_release(jsonParsingQueue);
}

+ (void)processJSONObject:(id)jsonObject 
             targetEntity:(NSURL *)entityURI 
       targetRelationship:(NSString *)relationshipName {
    
    if (!jsonProcessingQueue) {
        jsonProcessingQueue = dispatch_queue_create("com.Broker.jsonProcessingQueue", NULL);
    }
 
    dispatch_async(jsonProcessingQueue, ^{
        [self whateverJSON:jsonObject
              targetEntity:entityURI
        targetRelationship:relationshipName];
    });
    
    dispatch_release(jsonProcessingQueue);
}

+ (void)whateverJSON:(id)jsonObject targetEntity:(NSURL *)entityURI targetRelationship:(NSString *)relationshipName {
    
    NSManagedObject *object = [self objectWithURI:entityURI];
    
    BKEntityPropertiesDescription *map = [self entityPropertyMapForEntityName:object.entity.name];
    
    // Flat
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *transformedDict = [self transformJSONDictionary:(NSDictionary *)jsonObject 
                                             usingEntityPropertiesMap:map];
                
        [object setValuesForKeysWithDictionary:transformedDict];
    }
    
    // Collection
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        // array
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

+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI {
    NSManagedObjectID *objectID = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    
    if (!objectID) return nil;
    
    NSManagedObject *objectForID = [context objectWithID:objectID];
    
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
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    if ([results count] > 0 ) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark - Accessors

+ (BKEntityPropertiesDescription *)entityPropertyMapForEntityName:(NSString *)entityName {
    return (BKEntityPropertiesDescription *)[propertiesMaps objectForKey:entityName];
}

+ (BKRelationshipDescription *)relationshipMapForRelationship:(NSString *)relationship 
                                         onEntityName:(NSString *)entityName {
    
    BKEntityPropertiesDescription *map = [propertiesMaps objectForKey:entityName];
        
    if (map) {
        return [map relationshipMapForProperty:relationship];
    }
    
    return nil;
}

@end
