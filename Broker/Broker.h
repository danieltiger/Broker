//
//  Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BKEntityPropertiesMap.h"

#import "BKAttributeMap.h"
#import "BKRelationshipMap.h"


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
+ (void)registerEntityName:(NSString *)entityName;

/**
 * Register object where some of the network attribute names are not the same as
 * local attribute names.  A common excpetion for "MyObject" might be mapping a 
 * network attribute 'id' to local attribute of 'myObjectID.'
 */
+ (void)registerEntityName:(NSString *)entityName 
   andMapNetworkAttributes:(NSArray *)networkAttributes 
         toLocalAttributes:(NSArray *)localAttributes;

////////////////////////////////////////////////////////////////////////////////
//                                 Processing                                 //
////////////////////////////////////////////////////////////////////////////////

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI;

+ (void)parseJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
      targetRelationship:(NSString *)relationshipName;

+ (void)processJSONObject:(id)jsonObject 
             targetEntity:(NSURL *)entityURI 
       targetRelationship:(NSString *)relationshipName;

+ (void)whateverJSON:(id)jsonObject 
        targetEntity:(NSURL *)entityURI 
  targetRelationship:(NSString *)relationshipName;

+ (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
                 usingEntityPropertiesMap:(BKEntityPropertiesMap *)entityMap;


+ (NSManagedObject *)objectWithURI:(NSURL *)objectURI;

////////////////////////////////////////////////////////////////////////////////
//                                 Accessors                                  //
////////////////////////////////////////////////////////////////////////////////

+ (BKEntityPropertiesMap *)entityPropertyMapForEntityName:(NSString *)entityName;

+ (BKAttributeMap *)attributeMapForEntityName:(NSString *)entityName;

+ (BKRelationshipMap *)relationshipMapForRelationship:(NSString *)relationship 
                                         onEntityName:(NSString *)entityName;

@end
