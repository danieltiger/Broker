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

//static dispatch_queue_t jsonParsingQueue = nil;

#pragma mark - Setup

+ (void)setupWithContext:(NSManagedObjectContext *)aContext {
    context = aContext;
    
    // All entity descriptions
    entityDescriptions = [[NSMutableDictionary alloc] init];
    
    // JSONKit Decoder
    decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
}

#pragma mark - Registration

+ (void)registerEntityNamed:(NSString *)entityName withPrimaryKey:(NSString *)primaryKey {
    [self registerEntityNamed:entityName
               withPrimaryKey:primaryKey
      andMapNetworkProperties:nil 
            toLocalProperties:nil];
}

+ (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty {
    
    [self registerEntityNamed:entityName
               withPrimaryKey:primaryKey
      andMapNetworkProperties:[NSArray arrayWithObject:networkProperty] 
            toLocalProperties:[NSArray arrayWithObject:localProperty]];
    
}

+ (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties {
    
    NSAssert(context, @"Broker must be setup with setupWithContext!");
    
    if ([self entityPropertyDescriptionForEntityName:entityName]) {
        WLog(@"Entity named %@ already registered with Broker", entityName);
        return;
    }
    
    // create new object
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                            inManagedObjectContext:context];
    
    // Build description of entity properties
    BKEntityPropertiesDescription *desc = [BKEntityPropertiesDescription descriptionForEntity:object.entity 
                                                                         withPropertiesByName:object.entity.propertiesByName
                                                                      andMapNetworkProperties:networkProperties
                                                                            toLocalProperties:localProperties];
    
    // Set primary key
    desc.primaryKey = primaryKey;
    
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

    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("com.Broker.jsonParsingQueue", NULL);

    // dispatch parsing on separate thread
    dispatch_async(jsonParsingQueue, ^{ 
        
        // JSONKit decoder
        id jsonObject = [decoder objectWithData:jsonPayload]; 
        
        // process the parsed json in new context
        [Broker asyncProcessJSONObject:jsonObject 
                          targetEntity:entityURI
                    targetRelationship:relationshipName
                             inContext:[self newMainStoreManagedObjectContext]
                   withCompletionBlock:CompletionBlock];

    });

    dispatch_release(jsonParsingQueue);
}

#pragma mark - CoreData

+ (void)contextDidSave:(NSNotification *)notification {
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);

    NSManagedObjectContext *threadContext = (NSManagedObjectContext *)notification.object;
    
    [context performSelectorOnMainThread:selector withObject:notification waitUntilDone:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextDidSaveNotification 
                                                  object:threadContext];
}

+ (NSManagedObjectContext *)newMainStoreManagedObjectContext {
    
    // Grab the main coordinator
    NSPersistentStoreCoordinator *coord = [context persistentStoreCoordinator];

    // Create new context with default concurrency type
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [newContext setPersistentStoreCoordinator:coord];
    
    // Optimization
    [newContext setUndoManager:nil];
    
    // Observer saves from this context
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:newContext];
    
    return [newContext autorelease];
}

#pragma mark - Accessors

+ (BKEntityPropertiesDescription *)entityPropertyDescriptionForEntityName:(NSString *)entityName {
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
