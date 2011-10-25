//
//  BKJSONOperation.h
//  Broker
//
//  Created by Andrew Smith on 10/25/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "CDOperation.h"
#import "BKEntityPropertiesDescription.h"

@interface BKJSONOperation : CDOperation {
@private
    id jsonPayload;
    NSURL *entityURI;
    NSString *relationshipName;
    NSManagedObjectContext *context;
}

@property (nonatomic, retain) id jsonPayload;
@property (nonatomic, retain) NSURL *entityURI;
@property (nonatomic, copy) NSString *relationshipName;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)processJSONObject:(id)jsonObject;

- (void)processJSONCollection:(NSArray *)collection
                    forObject:(NSManagedObject *)object
        withEntityDescription:(BKEntityPropertiesDescription *)description
              forRelationship:(NSString *)relationship;

- (void)processJSONSubObject:(NSDictionary *)subDictionary 
                   forObject:(NSManagedObject *)object 
             withDescription:(BKEntityPropertiesDescription *)description;

@end
