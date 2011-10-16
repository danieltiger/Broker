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
static NSString *kEmployeeStartDateFormat = @"yyyy/MM/dd HH:mm:ss zzzz";


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

- (void)testRegisterRelationshipDescription {
    
    [Broker registerEntityNamed:kDepartment withPrimaryKey:nil];
    
    BKRelationshipDescription *desc = [Broker relationshipDescriptionForProperty:kEmployeesRelationship 
                                                                onEntityName:kDepartment];
    
    STAssertNotNil(desc, @"Should have an relationship description for property on registered entity");
    STAssertEqualObjects(desc.localPropertyName, kEmployeesRelationship, @"Relationship map should be named correctly");    
    STAssertEqualObjects(desc.destinationEntityName, kEmployee, @"Relationship map should have correct destination entity name");
    STAssertEqualObjects(desc.entityName, kDepartment, @"Relationship map should have correct entity name");
    STAssertTrue(desc.isToMany, @"Relationship map should be isToMany");
}

- (void)testRegisterAttributeDescription {
    
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    
    BKAttributeDescription *desc = [Broker attributeDescriptionForProperty:@"firstname"
                                                              onEntityName:kEmployee];
    
    STAssertNotNil(desc, @"Should have an attribute description for property on registered entity");
    STAssertEqualObjects(desc.entityName, kEmployee, @"Attribute description entity name should be set correctly");
    STAssertEqualObjects(desc.localPropertyName, kEmployeeFirstname, @"Attribute description local attribute name should be set correctly");
    STAssertNil(desc.networkPropertyName, @"Attribute description shouldn't have a network attribute name");
}

- (void)testRegisterAttributeDescriptionWithPropertyMap {
    
    [Broker registerEntityNamed:kEmployee 
                 withPrimaryKey:nil 
          andMapNetworkProperty:@"first-name"
                toLocalProperty:@"firstname"];
    
    BKAttributeDescription *desc = [Broker attributeDescriptionForProperty:@"firstname"
                                                              onEntityName:kEmployee];
    
    STAssertEqualObjects(desc.entityName, kEmployee, @"Attribute description entity name should be set correctly");
    STAssertEqualObjects(desc.localPropertyName, kEmployeeFirstname, @"Attribute description local attribute name should be set correctly");
    STAssertEqualObjects(desc.networkPropertyName, @"first-name", @"Attribute description network attribute name should be set correctly");
}

#pragma mark - Entity Properties Description

- (void)testDescriptionForLocalProperty {
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
    BKPropertyDescription *localPropDesc = [desc descriptionForLocalProperty:@"employeeID"];
    
    STAssertNotNil(localPropDesc, @"Should have an attribute description for a property on a registered entity");
}

- (void)testDescriptionForLocalPropertyThatDoesntExist {
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
    BKPropertyDescription *localPropDesc = [desc descriptionForLocalProperty:@"blah"];
    
    STAssertNil(localPropDesc, @"Should not have an attribute description for a fake property on a registered entity");
}

- (void)testDescriptionForNetworkPropertyThatDoesntExist {
    [Broker registerEntityNamed:kEmployee 
                 withPrimaryKey:@"employeeID" 
          andMapNetworkProperty:@"first-name" 
                toLocalProperty:@"firstname"];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
    BKPropertyDescription *networkPropDesc = [desc descriptionForNetworkProperty:@"blah"];
    
    STAssertNil(networkPropDesc, @"Should not have an attribute description for a fake network property on a registered entity");
}

#pragma mark - Attribute Description

- (void)testDescriptionWithAttributeDescription {
    STFail(@"TODO!");
}

- (void)testDescriptionWithAttributeDescriptionAndMapToNetworkAttributeName {
    STFail(@"TODO!");
}

- (void)testObjectForValue {
    STFail(@"TODO!");
}

#pragma mark - Accessors

- (void)testEntityPropertyDescriptionForEntityName {
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
    
    STAssertNotNil(desc, @"Should have entity property description for registered entity");
}

- (void)testAttributeDescriptionForPropertyOnEntityName {
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];

    BKAttributeDescription *desc = [Broker attributeDescriptionForProperty:@"employeeID" 
                                                              onEntityName:kEmployee];
    
    STAssertNotNil(desc, @"Should have an attribute description for a property on a registered entity");
}

- (void)testRelationshipDescriptionForPropertyOnEntityName {
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    
    BKRelationshipDescription *desc = [Broker relationshipDescriptionForProperty:@"department"
                                                                    onEntityName:@"Employee"];
    
    STAssertNotNil(desc, @"Should have a relationship description for a property on a registered entity");
}

#pragma mark - Transform

- (void)testTransformJSONDictionaryClassesAreCorrect {
        
    NSDictionary *fakeJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Andrew", @"Smith", @"5678", @"2011/10/06 00:51:10 -0700", nil]
                                                         forKeys:[NSArray arrayWithObjects:@"firstname", @"lastname", @"employeeID", @"startDate", nil]];
    
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
        
    NSDictionary *transformedDict = [Broker transformJSONDictionary:fakeJSON 
                                   usingEntityPropertiesDescription:desc];

    STAssertTrue([[transformedDict objectForKey:@"firstname"] isKindOfClass:[NSString class]], @"Transform dictionary should properly set class type");
    STAssertTrue([[transformedDict objectForKey:@"lastname"] isKindOfClass:[NSString class]], @"Transform dictionary should properly set class type");
    STAssertTrue([[transformedDict objectForKey:@"employeeID"] isKindOfClass:[NSNumber class]], @"Transform dictionary should properly set class type");
    STAssertTrue([[transformedDict objectForKey:@"startDate"] isKindOfClass:[NSDate class]], @"Transform dictionary should properly set class type");
}

- (void)testTransformJSONDictionaryValuesAreCorrect {
    
    NSDictionary *fakeJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Andrew", @"Smith", @"5678", @"2011/10/06 00:51:10 -0700", nil]
                                                         forKeys:[NSArray arrayWithObjects:@"firstname", @"lastname", @"employeeID", @"startDate", nil]];
    
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];
    
    BKEntityPropertiesDescription *desc = [Broker entityPropertyDescriptionForEntityName:kEmployee];
    
    NSDictionary *transformedDict = [Broker transformJSONDictionary:fakeJSON 
                                   usingEntityPropertiesDescription:desc];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kEmployeeStartDateFormat];
    NSDate *date = [formatter dateFromString:@"2011/10/06 00:51:10 -0700"];
    
    STAssertEqualObjects([transformedDict valueForKey:@"firstname"], @"Andrew", @"Attributes should be set correctly");
    STAssertEqualObjects([transformedDict valueForKey:@"lastname"], @"Smith", @"Attributes should be set correctly");
    STAssertEqualObjects([transformedDict valueForKey:@"employeeID"], [NSNumber numberWithInt:5678], @"Attributes should be set correctly");
    STAssertEqualObjects([transformedDict valueForKey:@"startDate"], date, @"Attributes should be set correctly");
}

#pragma mark - Processing

- (void)testFlatEmployeeJSONProcessing {
    
    NSData *jsonData = DataFromFile(@"employee_flat.json");
    
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];

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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kEmployeeStartDateFormat];
    NSDate *date = [formatter dateFromString:@"2011/10/06 00:51:10 -0700"];
    
    STAssertEqualObjects([employee valueForKey:@"firstname"], @"Andrew", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"lastname"], @"Smith", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"employeeID"], [NSNumber numberWithInt:5678], @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"startDate"], date, @"Attributes should be set correctly");
}

- (void)testNestedEmployeeJSONProcessing {
    
    NSData *jsonData = DataFromFile(@"employee_nested.json");
    
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    [Broker registerEntityNamed:@"ContactInfo" withPrimaryKey:nil];
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];

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
    
    STAssertNotNil([employee valueForKey:@"contactInfo"], @"Should have contactInfo object");
    
    id contactInfo = [employee valueForKey:@"contactInfo"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kEmployeeStartDateFormat];
    NSDate *date = [formatter dateFromString:@"2011/10/06 00:51:10 -0700"];

    
    STAssertEqualObjects([contactInfo valueForKey:@"email"], @"andrew@smith.com", @"Should set nested object attributes correctly");
    STAssertEqualObjects([contactInfo valueForKey:@"phone"], [NSNumber numberWithInt:4155556666], @"Should set nested object attributes correctly");
    
    STAssertEqualObjects([employee valueForKey:@"firstname"], @"Andrew", @"Should set attributes correctly");
    STAssertEqualObjects([employee valueForKey:@"lastname"], @"Smith", @"Should set nested object attributes correctly");
    STAssertEqualObjects([employee valueForKey:@"employeeID"], [NSNumber numberWithInt:5678], @"Should set nested object attributes correctly");
    STAssertEqualObjects([employee valueForKey:@"startDate"], date, @"Attributes should be set correctly");
}

- (void)testNestedDepartmentJSONProcessing {
    
    NSData *jsonData = DataFromFile(@"department_nested.json");
    
    // Register Entities
    [Broker registerEntityNamed:kDepartment withPrimaryKey:nil];
    [Broker registerEntityNamed:kEmployee withPrimaryKey:nil];
    [Broker setDateFormat:kEmployeeStartDateFormat
              forProperty:@"startDate" 
                 onEntity:kEmployee];

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
    
    STFail(@"TODO!");
}

- (void)testDepartmentEmployeesJSON {
    
    NSData *jsonData = DataFromFile(@"department_employees.json");
    
    // Register Entities
    [Broker registerEntityNamed:kDepartment withPrimaryKey:nil];
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];
    
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
    
    // Fetch
    NSManagedObject *dept = [Broker objectWithURI:departmentURI 
                                        inContext:context];
    
    // Refresh
    [context refreshObject:dept mergeChanges:YES];
    
    NSSet *employees = (NSSet *)[dept valueForKey:@"employees"];
    int num = [employees count];
    
    STAssertEquals(num, 6, @"Should have 7 employee objects");
}

- (void)testNestedDepartmentEmployeesJSON {
    
    NSData *jsonData = DataFromFile(@"department_nested.json");
    
    // Register Entities
    [Broker registerEntityNamed:kDepartment withPrimaryKey:@"departmentID"];
    [Broker registerEntityNamed:kEmployee withPrimaryKey:@"employeeID"];
    [Broker setDateFormat:kEmployeeStartDateFormat 
              forProperty:@"startDate" 
                 onEntity:kEmployee];

    // Build Deparment
    NSURL *departmentURI = [BrokerTestsHelpers createNewDepartment:context];
    
    // Use to hold main thread while bg tasks complete
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    void (^CompletionBlock)(void) = ^{dispatch_semaphore_signal(sema);}; 
    
    // Chunk dat
    [Broker processJSONPayload:jsonData 
                  targetEntity:departmentURI 
               forRelationship:nil 
           withCompletionBlock:CompletionBlock];
    
    // Wait for async code to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    
    // Fetch
    NSManagedObject *dept = [Broker objectWithURI:departmentURI 
                                        inContext:context];
    
    // Refresh
    [context refreshObject:dept mergeChanges:YES];
    
    NSSet *employees = (NSSet *)[dept valueForKey:@"employees"];
    int num = [employees count];
    
    STAssertEquals(num, 6, @"Should have 7 employee objects");
}

#pragma mark - Core Data

- (void)testObjectWithURI {
    
    NSManagedObject *department = [NSEntityDescription insertNewObjectForEntityForName:kDepartment 
                                                                inManagedObjectContext:context];
    
    NSManagedObject *fetchedDepartment = [Broker objectWithURI:department.objectID.URIRepresentation 
                                                     inContext:context];
     
    STAssertEqualObjects(department, fetchedDepartment, @"Should get the same object");
}

- (void)testFindEntityDescribedWithPrimaryKeyNameAndPrimaryKeyValueInContext {
    STFail(@"TODO!");
}

@end
