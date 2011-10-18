//
//  Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BKEntityPropertiesDescription.h"

#import "BKAttributeDescription.h"
#import "BKRelationshipDescription.h"


@interface Broker : NSObject

////////////////////////////////////////////////////////////////////////////////
//                                  Setup                                     //
////////////////////////////////////////////////////////////////////////////////

+ (void)setupWithContext:(NSManagedObjectContext *)aContext;

////////////////////////////////////////////////////////////////////////////////
//                               Registration                                 //
////////////////////////////////////////////////////////////////////////////////

/**
 * Regsister entity where network attribute names are the same as local 
 * attribute names.
 */
+ (void)registerEntityNamed:(NSString *)entityName 
             withPrimaryKey:(NSString *)primaryKey;

/**
 * Regsister entity and map a single network property to a local property.  A 
 * common map for "MyObject" might be mapping a network property 'id' to 
 * local property of 'myObjectID.'
 */
+ (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty;

/**
 * Register object where some of the network attribute names are not the same as
 * local attribute names.  A common excpetion for "MyObject" might be mapping a 
 * network attribute 'id' to local attribute of 'myObjectID.'
 */
+ (void)registerEntityNamed:(NSString *)entityName 
             withPrimaryKey:(NSString *)primaryKey
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties;

/**
 * After registering an object you can set the expected date format to be used
 * when transforming JSON date strings to NSDates
 */
+ (void)setDateFormat:(NSString *)dateFormat 
          forProperty:(NSString *)property 
             onEntity:(NSString *)entity;

////////////////////////////////////////////////////////////////////////////////
//                                 Processing                                 //
////////////////////////////////////////////////////////////////////////////////
/**
 *
 */
+ (void)processJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
     withCompletionBlock:(void (^)())CompletionBlock;

/**
 *
 */
+ (void)processJSONPayload:(id)jsonPayload 
              targetEntity:(NSURL *)entityURI
           forRelationship:(NSString *)relationshipName
       withCompletionBlock:(void (^)())CompletionBlock;

////////////////////////////////////////////////////////////////////////////////
//                                 Core Data                                  //
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a new instance of the NSManagedObjectContext sharing the main 
 * persistent store.  Suitible for use with background qeueus.
 */
+ (NSManagedObjectContext *)newMainStoreManagedObjectContext;

////////////////////////////////////////////////////////////////////////////////
//                                 Accessors                                  //
////////////////////////////////////////////////////////////////////////////////

+ (BKEntityPropertiesDescription *)entityPropertyDescriptionForEntityName:(NSString *)entityName;

+ (BKAttributeDescription *)attributeDescriptionForProperty:(NSString *)attribute 
                                               onEntityName:(NSString *)entityName;

+ (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)relationship 
                                                     onEntityName:(NSString *)entityName;

+ (BKEntityPropertiesDescription *)destinationEntityPropertiesDescriptionForRelationship:(NSString *)relationship
                                                                           onEntityNamed:(NSString *)entityName;

@end
