//
//  BrokerTests.m
//  BrokerTests
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrokerTests.h"

#import "Broker.h"
#import "Broker+Private.h"

#import "BrokerTestsHelpers.h"

#import "BKAttributeDescription.h"
#import "BKRelationshipDescription.h"

// Department
static NSString *kDepartment = @"Department";
static NSString *kEmployeesRelationship = @"employees";

// Employee
static NSString *kEmployee = @"Employee";
static NSString *kEmployeeFirstname = @"firstname";
static NSString *kDepartmentRelationship = @"department";


@implementation BrokerTests

- (void)setUp {
    [super setUp];
    
    // Build Model
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:DataModelURL()];
    
    STAssertNotNil(model, @"Managed Object Model should exist");
    
    // Build persistent store coordinator
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // Build Store
    NSError *error = nil;
    store = [coord addPersistentStoreWithType:NSSQLiteStoreType
                                configuration:nil
                                          URL:DataStoreURL()
                                      options:nil 
                                        error:&error];

    // Build context
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coord];

    // Setup Broker
    [Broker setupWithContext:context];
    
    // Setup JSONKit
    decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
}

- (void)tearDown {
    
    [context release], context = nil;
    
    NSError *error = nil;
    STAssertTrue([coord removePersistentStore:store error:&error], 
                 @"couldn't remove persistent store: %@", error);
    
    store = nil;
    [coord release], coord = nil;
    [model release], model = nil;  
    
    DeleteDataStore();
    
    [super tearDown];
}

#pragma mark - Registration

- (void)testRegisterRelationshipDescriptionExists {
    
    [Broker registerEntityNamed:kDepartment];

    BKRelationshipDescription *map = [Broker relationshipDescriptionForProperty:kEmployeesRelationship 
                                                       onEntityName:kDepartment];
    
    STAssertNotNil(map, @"Broker should have an employee relationship map for Department after registration!");

}

- (void)testRegisterRelationshipDescription {
    
    [Broker registerEntityNamed:kDepartment];
    
    BKRelationshipDescription *desc = [Broker relationshipDescriptionForProperty:kEmployeesRelationship 
                                                                onEntityName:kDepartment];
    
    STAssertEqualObjects(desc.localRelationshipName, kEmployeesRelationship, @"Relationship map should be named correctly");    
    STAssertEqualObjects(desc.destinationEntityName, kEmployee, @"Relationship map should have correct destination entity name");
    STAssertEqualObjects(desc.entityName, kDepartment, @"Relationship map should have correct entity name");
    STAssertTrue(desc.isToMany, @"Relationship map should be isToMany");
}

- (void)testRegisterAttributeDescription {
    
    [Broker registerEntityNamed:kEmployee];
    
    BKAttributeDescription *desc = [Broker attributeDescriptionForProperty:@"firstname"
                                                              onEntityName:kEmployee];
    
    STAssertEqualObjects(desc.entityName, kEmployee, @"Attribute description entity name should be set correctly");
    STAssertEqualObjects(desc.localAttributeName, kEmployeeFirstname, @"Attribute description local attribute name should be set correctly");
    STAssertNil(desc.networkAttributeName, @"Attribute description shouldn't have a network attribute name");
}

- (void)testRegisterAttributeDescriptionWithPropertyMap {
    
    [Broker registerEntityNamed:kEmployee andMapNetworkProperties:[NSArray arrayWithObject:@"first-name"]
                                               toLocalProperties:[NSArray arrayWithObject:@"firstname"]];
    
    BKAttributeDescription *desc = [Broker attributeDescriptionForProperty:@"firstname"
                                                              onEntityName:kEmployee];
    
    STAssertEqualObjects(desc.entityName, kEmployee, @"Attribute description entity name should be set correctly");
    STAssertEqualObjects(desc.localAttributeName, kEmployeeFirstname, @"Attribute description local attribute name should be set correctly");
    STAssertEqualObjects(desc.networkAttributeName, @"first-name", @"Attribute description network attribute name should be set correctly");
}

- (void)testTransformEmployeeJSONDictionary {
    
    [Broker registerEntityNamed:kEmployee];
    
    NSDictionary *fakeJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Andrew", @"Smith", @"5678", nil]
                                                         forKeys:[NSArray arrayWithObjects:@"firstname", @"lastname", @"employeeID", nil]];
    
    NSDictionary *transformedDict = [Broker transformJSONDictionary:fakeJSON 
                                           usingEntityPropertiesMap:[Broker entityPropertyMapForEntityName:kEmployee]];
        
    STAssertTrue([[transformedDict objectForKey:@"firstname"] isKindOfClass:[NSString class]], @"Transform dictionary should properly set class type");
    STAssertTrue([[transformedDict objectForKey:@"lastname"] isKindOfClass:[NSString class]], @"Transform dictionary should properly set class type");
    STAssertTrue([[transformedDict objectForKey:@"employeeID"] isKindOfClass:[NSNumber class]], @"Transform dictionary should properly set class type");
}

- (void)testFlatEmployeeJSONProcessing {
    
    NSData *jsonData = DataFromFile(@"employee_flat.json");
    
    [Broker registerEntityNamed:kEmployee];
    
    // Add a new Employee to the store
    NSURL *employeeURI = [BrokerTestsHelpers createNewEmployee:context];
    
    // Use to hold main thread while bg tasks complete
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    void (^CompletionBlock)(void) = ^{dispatch_semaphore_signal(sema);}; 

    // Chunk dat
    [Broker processJSONPayload:jsonData
                  targetEntity:employeeURI
           withCompletionBlock:CompletionBlock];
    
    // Wait for async code to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    
    // Re-fetch
    NSManagedObject *employee = [Broker objectWithURI:employeeURI inContext:context];
    
    [context refreshObject:employee mergeChanges:YES];
        
    STAssertEqualObjects([employee valueForKey:@"firstname"], @"Andrew", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"lastname"], @"Smith", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"employeeID"], [NSNumber numberWithInt:5678], @"Attributes should be set correctly");
}

- (void)testNestedDepartmentJSONProcessing {
    
    NSData *jsonData = DataFromFile(@"department_nested.json");
    
    // Register Entities
    [Broker registerEntityNamed:kDepartment];
    [Broker registerEntityNamed:kEmployee];
    
    // Build Deparment
    NSURL *departmentURI = [BrokerTestsHelpers createNewDepartment:context];
    
    // Use to hold main thread while bg tasks complete
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    void (^CompletionBlock)(void) = ^{dispatch_semaphore_signal(sema);}; 
    
    // Chunk dat
    [Broker processJSONPayload:jsonData
                  targetEntity:departmentURI
           withCompletionBlock:CompletionBlock];
    
    // Wait for async code to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    
    // Re-fetch
    NSManagedObject *dept = [Broker objectWithURI:departmentURI inContext:context];
    
    [context refreshObject:dept mergeChanges:YES];
    
    STFail(@"Implement this test bitch!");
}

- (void)testDepartmentEmployeesJSON {
    
    NSData *jsonData = DataFromFile(@"department_employees.json");
    
    // Register Entities
    [Broker registerEntityNamed:kDepartment];
    [Broker registerEntityNamed:kEmployee];
    
    // Build Deparment
    NSURL *departmentURI = [BrokerTestsHelpers createNewDepartment:context];
    
    // Use to hold main thread while bg tasks complete
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    void (^CompletionBlock)(void) = ^{dispatch_semaphore_signal(sema);}; 
    
    // Chunk dat
    [Broker processJSONPayload:jsonData 
                  targetEntity:departmentURI 
               forRelationship:@"employees" 
           withCompletionBlock:CompletionBlock];
    
    // Wait for async code to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    
    // Re-fetch
    NSManagedObject *dept = [Broker objectWithURI:departmentURI inContext:context];
    
    [context refreshObject:dept mergeChanges:YES];
    
    STFail(@"Implement this test bitch!");
}

#pragma mark - Core Data

- (void)testObjectWithURI {
    
    NSManagedObject *department = [NSEntityDescription insertNewObjectForEntityForName:kDepartment 
                                                                inManagedObjectContext:context];
    
    NSManagedObject *fetchedDepartment = [Broker objectWithURI:department.objectID.URIRepresentation 
                                                     inContext:context];
     
    STAssertEqualObjects(department, fetchedDepartment, @"Should get the same object");
}

@end
