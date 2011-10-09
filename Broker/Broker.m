//
//  Broker.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Broker.h"
#import "Broker+Private.h"
#import "JSONKit.h"

@implementation Broker

#pragma mark - Class Instances

static NSManagedObjectContext *context = nil;
static NSMutableDictionary *entityDescriptions = nil;

static JSONDecoder *decoder = nil;

static dispatch_queue_t jsonParsingQueue = nil;

#pragma mark - Setup

+ (void)setupWithContext:(NSManagedObjectContext *)aContext {
    context = aContext;
    
    entityDescriptions = [[NSMutableDictionary alloc] init];
    
    // takes JSON payload, returns JSON object
    decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
}

#pragma mark - Registration

+ (void)registerEntityNamed:(NSString *)entityName {
    [self registerEntityNamed:entityName 
      andMapNetworkProperties:nil 
            toLocalProperties:nil];
}

+ (void)registerEntityNamed:(NSString *)entityName 
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty {
    
    [self registerEntityNamed:entityName 
      andMapNetworkProperties:[NSArray arrayWithObject:networkProperty] 
            toLocalProperties:[NSArray arrayWithObject:localProperty]];
    
}

+ (void)registerEntityNamed:(NSString *)entityName 
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties {
    
    NSAssert(context, @"Broker must be setup with setupWithContext!");
    
    if ([self entityPropertyMapForEntityName:entityName]) {
        WLog(@"Entity named %@ already registered with Broker", entityName);
        return;
    }
    
    // create new object
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                            inManagedObjectContext:context];
    
    
    BKEntityPropertiesDescription *desc = [BKEntityPropertiesDescription descriptionForEntityName:entityName 
                                                                             withPropertiesByName:object.entity.propertiesByName
                                                                          andMapNetworkProperties:networkProperties
                                                                                toLocalProperties:localProperties];
    
    // Add to descriptions
    [entityDescriptions setObject:desc forKey:entityName];
    
    // cleanup
    [context deleteObject:object];
}

#pragma mark - JSON

+ (void)processJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
     withCompletionBlock:(void (^)())CompletionBlock{
    
    [self processJSONPayload:jsonPayload
              targetEntity:entityURI
           forRelationship:nil
       withCompletionBlock:CompletionBlock];

}

+ (void)processJSONPayload:(id)jsonPayload 
              targetEntity:(NSURL *)entityURI
           forRelationship:(NSString *)relationshipName
       withCompletionBlock:(void (^)())CompletionBlock{

    if (!jsonParsingQueue) {
        jsonParsingQueue = dispatch_queue_create("com.Broker.jsonParsingQueue", NULL);
    }

    // dispatch parsing on separate thread
    dispatch_async(jsonParsingQueue, ^{ 
        
        // JSONKit decoder
        id jsonObject = [decoder objectWithData:jsonPayload]; 
        
        // process the parsed json
        [Broker asyncProcessJSONObject:jsonObject 
                          targetEntity:entityURI
                    targetRelationship:relationshipName
                             inContext:context
                   withCompletionBlock:CompletionBlock];

    });

    dispatch_release(jsonParsingQueue);
}

#pragma mark - Accessors

+ (BKEntityPropertiesDescription *)entityPropertyMapForEntityName:(NSString *)entityName {
    return (BKEntityPropertiesDescription *)[entityDescriptions objectForKey:entityName];
}

+ (BKAttributeDescription *)attributeDescriptionForProperty:(NSString *)property 
                                               onEntityName:(NSString *)entityName {

    BKEntityPropertiesDescription *desc = [entityDescriptions objectForKey:entityName];
    
    if (desc) {
        return [desc attributeDescriptionForLocalProperty:property];
    }
    
    return nil;
}


+ (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)property 
                                                     onEntityName:(NSString *)entityName {
    
    BKEntityPropertiesDescription *desc = [entityDescriptions objectForKey:entityName];
        
    if (desc) {
        return [desc relationshipDescriptionForProperty:property];
    }
    
    return nil;
}

@end
