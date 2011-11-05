//
//  Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Conductor.h"

#import "BKEntityPropertiesDescription.h"

#import "BKAttributeDescription.h"
#import "BKRelationshipDescription.h"


@interface Broker : Conductor {
@private
    NSManagedObjectContext *mainContext;
    NSMutableDictionary *entityDescriptions;
}

/** @name Properties */

/**
 The NSManagedObjectContext in which the Broker instance performs its operations
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext *mainContext;

/**
 The dictionary containing all BKEntityPropertiesDescriptions registered with 
 the Broker instance.
 */
@property (nonatomic, readonly) NSMutableDictionary *entityDescriptions;

/** @name Setup */

/**
 This should be part of the larger summary
 
 This is the longer description
 
 @return A new Broker instance setup with the provided NSManagedObjectContext
 
 @param context Typically this is apps main NSManagedObjectContext.
 */
+ (id)brokerWithContext:(NSManagedObjectContext *)context;

/**
 Performs basic setup operations with the provided NSManagedObjectContext
 @param context Typically this is the main app context.
 */
- (void)setupWithContext:(NSManagedObjectContext *)context;

/**
 Resets Broker instance by clearing the context and entityDescriptions.
 */
- (void)reset;

/** @name Registration */

/**
 Regsister entity where network attribute names are the same as local 
 attribute names.
 
 @see [Broker registerEntityNamed:withPrimaryKey:andMapNetworkProperties:toLocalProperties]
 */
- (void)registerEntityNamed:(NSString *)entityName 
             withPrimaryKey:(NSString *)primaryKey;

/**
 Regsister entity and map a single network property to a local property.
 
 @see [Broker registerEntityNamed:withPrimaryKey:andMapNetworkProperties:toLocalProperties]
 */
- (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty;

/**
 Register object where some of the network attribute names are not the same as
 local attribute names.

 A common excpetion for "MyObject" might be mapping a 
 network attribute 'id' to local attribute of 'myObjectID.'
 
 @param entityName The entity name of the NSManagedObject.
 @param primaryKey The designated primary key of the entity
 @param networkProperties An array of 
 @param localProperties An array of local property names that match with the
 networkProperties

 @see [BKEntityPropertiesDescription primaryKey]
 */
- (void)registerEntityNamed:(NSString *)entityName 
             withPrimaryKey:(NSString *)primaryKey
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties;

/**
 After registering an object you can set the expected date format to be used
 when transforming JSON date strings to NSDate objects
 
 @param dateFormat String representation of the date format
 @param property The name of the property for the given entity that is an NSDate
 @param entity The name of the entity, previously registered with Broker,
 to set the date format on
 */
- (void)setDateFormat:(NSString *)dateFormat 
          forProperty:(NSString *)property 
             onEntity:(NSString *)entity;

/**
 Set the root key path for a given entity previously registered

 The root key path is useful when the returned resources are nested. For a
 resource named "User," the JSON might look like the following.

    { 
        'response' : { 
            'user' : {
                      <DATA>
                     }
        }
    }

 In this case, the rootKeyPath would be @"response.user".
 
 @param rootKeyPath The root key path of the entity resource.
 @param entity The name of the entity, previously registered with Broker
 */
- (void)setRootKeyPath:(NSString *)rootKeyPath 
             forEntity:(NSString *)entity;

//- (void)setRootKeyPath:(NSString *)rootKeyPath 
//           forProperty:(NSString *)property
//              onEntity:(NSString *)entity;


/** @name Processing */

/**

 */
- (void)processJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
     withCompletionBlock:(void (^)())CompletionBlock;

/**

 */
- (void)processJSONPayload:(id)jsonPayload 
              targetEntity:(NSURL *)entityURI
           forRelationship:(NSString *)relationshipName
       withCompletionBlock:(void (^)())CompletionBlock;

/** @name Core Data */

/**
 Returns a new instance of the NSManagedObjectContext sharing the main 
 persistent store.  Suitible for use with background qeueus.
 */
- (NSManagedObjectContext *)newMainStoreManagedObjectContext;

/** @name Accessors */

- (BKEntityPropertiesDescription *)entityPropertyDescriptionForEntityName:(NSString *)entityName;

- (BKAttributeDescription *)attributeDescriptionForProperty:(NSString *)attribute 
                                               onEntityName:(NSString *)entityName;

- (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)relationship 
                                                     onEntityName:(NSString *)entityName;

- (BKEntityPropertiesDescription *)destinationEntityPropertiesDescriptionForRelationship:(NSString *)relationship
                                                                           onEntityNamed:(NSString *)entityName;

/** @name Private */

- (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
         usingEntityPropertiesDescription:(BKEntityPropertiesDescription *)entityMap;

- (NSManagedObject *)objectForURI:(NSURL *)objectURI 
                        inContext:(NSManagedObjectContext *)aContext;

- (NSManagedObject *)findOrCreateObjectForEntityDescribedBy:(BKEntityPropertiesDescription *)description 
                                        withPrimaryKeyValue:(id)value
                                                  inContext:(NSManagedObjectContext *)aContext
                                               shouldCreate:(BOOL)create;

@end
