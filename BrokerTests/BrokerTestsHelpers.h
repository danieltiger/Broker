//
//  BrokerTestsHelpers.h
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BrokerTestsHelpers : NSObject

+ (NSURL *)createNewEmployee:(NSManagedObjectContext *)context;
+ (NSURL *)createNewDepartment:(NSManagedObjectContext *)context;

NSString *PathForTestResource(NSString *resouce);
NSURL *URLForTestResource(NSString *resouce);

NSURL *DataModelURL(void);
NSURL *DataStoreURL(void);

NSString *UTF8StringFromFile(NSString *fileName);

NSData *DataFromFile(NSString *fileName);

void DeleteDataStore(void);


@end
