//
//  BrokerTests.h
//  BrokerTests
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>
#import "JSONKit.h"


@interface BrokerTests : SenTestCase {
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
    JSONDecoder *decoder;
}

@end
