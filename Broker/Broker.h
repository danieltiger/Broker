//
//  Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
 * Regsister object where network attribute names are the same as local 
 * attribute names.
 */
+ (void)registerEntityNamed:(NSString *)entityName;

+ (void)registerEntityNamed:(NSString *)entityName 
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty;

/**
 * Register object where some of the network attribute names are not the same as
 * local attribute names.  A common excpetion for "MyObject" might be mapping a 
 * network attribute 'id' to local attribute of 'myObjectID.'
 */
+ (void)registerEntityNamed:(NSString *)entityName 
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties;

////////////////////////////////////////////////////////////////////////////////
//                                 Processing                                 //
////////////////////////////////////////////////////////////////////////////////

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI;

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
      forRelationship:(NSString *)relationshipName;

+ (void)processJSONObject:(id)jsonObject 
             targetEntity:(NSURL *)entityURI 
       targetRelationship:(NSString *)relationshipName;

+ (void)whateverJSON:(id)jsonObject 
        targetEntity:(NSURL *)entityURI 
  targetRelationship:(NSString *)relationshipName;

+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
                 usingEntityPropertiesMap:(BKEntityPropertiesDescription *)entityMap;


+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI;

////////////////////////////////////////////////////////////////////////////////
//                                 Accessors                                  //
////////////////////////////////////////////////////////////////////////////////

+ (BKEntityPropertiesDescription *)entityPropertyMapForEntityName:(NSString *)entityName;

+ (BKAttributeDescription *)attributeDescriptionForProperty:(NSString *)attribute 
                                               onEntityName:(NSString *)entityName;

+ (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)relationship 
                                                         onEntityName:(NSString *)entityName;

@end
