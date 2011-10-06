//
//  Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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
+ (void)registerEntityType:(NSString *)entityType;

/**
 * Register object where some of the network attribute names are not the same as
 * local attribute names.  A common excpetion for "MyObject" might be mapping a 
 * network attribute 'id' to local attribute of 'myObjectID.'
 */
+ (void)registerEntityType:(NSString *)entityType 
   andMapNetworkAttributes:(NSArray *)networkAttribute 
         toLocalAttributes:(NSArray *)localAttributes;

/**
 *
 */
+ (void)setDestinationEntityType:(NSString *)entityType 
                 forRelationship:(NSString *)relationship 
                    onEntityType:(NSString *)entityType 
                        isToMany:(BOOL)tooMany;

////////////////////////////////////////////////////////////////////////////////
//                                 Processing                                 //
////////////////////////////////////////////////////////////////////////////////

+ (void)parseJSONPayload:(id)payload forEntity:(NSString *)entityName;

@end
