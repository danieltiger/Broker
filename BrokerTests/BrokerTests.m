//
//  BrokerTests.m
//  BrokerTests
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrokerTests.h"

#import "Broker.h"
#import "BrokerTestsHelpers.h"

#import "BKAttributeDescription.h"
#import "BKRelationshipDescription.h"

// Department
static NSString *kDepartment = @"Department";
static NSString *kEmployeesRelationship = @"employees";

// Employee
static NSString *kEmployee = @"Employee";
static NSString *kDepartmentRelationship = @"department";

@implementation BrokerTests

- (void)setUp {
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[BrokerTests class]] pathForResource:@"BrokerTestModel" 
                                                                             ofType:@"momd"];
    
    NSURL *modelURL = [NSURL URLWithString:path];
    
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    STAssertNotNil(model, @"Managed Object Model should exist");
    
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    store = [coord addPersistentStoreWithType:NSInMemoryStoreType
                                configuration:nil
                                          URL:nil
                                      options:nil 
                                        error:NULL];
    
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coord];

    [Broker setupWithContext:context];
    
    decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
}

- (void)tearDown {
    [context release], context = nil;
    
    NSError *error = nil;
    STAssertTrue([coord removePersistentStore: store error: &error], 
                 @"couldn't remove persistent store: %@", error);
    
    store = nil;
    
    [coord release], coord = nil;
    
    [model release], model = nil;    
    [super tearDown];
}

#pragma mark - Registration

- (void)testRegisterDepartmentRelationshipMapExists {
    
    [Broker registerEntityName:kDepartment];
    [Broker registerEntityName:kDepartment];

    BKRelationshipDescription *map = [Broker relationshipMapForRelationship:kEmployeesRelationship 
                                                       onEntityName:kDepartment];
    
    STAssertNotNil(map, @"Broker should have an employee relationship map for Department after registration!");

}

- (void)testRegisterDepartmentRelationshipMap {
    
    [Broker registerEntityName:kDepartment];
    
    BKRelationshipDescription *map = [Broker relationshipMapForRelationship:kEmployeesRelationship 
                                                       onEntityName:kDepartment];
    
    STAssertEqualObjects(map.relationshipName, kEmployeesRelationship, @"Relationship map should be named correctly");    
    STAssertEqualObjects(map.destinationEntityName, kEmployee, @"Relationship map should have correct destination entity name");
    STAssertEqualObjects(map.entityName, kDepartment, @"Relationship map should have correct entity name");
    STAssertTrue(map.isToMany, @"Relationship map should be isToMany");
}

- (void)testTransformEmployeeJSONDictionary {
    
    [Broker registerEntityName:kEmployee];
    
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
    
    [Broker registerEntityName:kEmployee];
    
    NSManagedObject *employee = [NSEntityDescription insertNewObjectForEntityForName:kEmployee 
                                                              inManagedObjectContext:context];
    
    id jsonObject = [decoder objectWithData:jsonData]; 
    
    [Broker whateverJSON:jsonObject targetEntity:employee.objectID.URIRepresentation targetRelationship:nil];

    STAssertEqualObjects([employee valueForKey:@"firstname"], @"Andrew", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"lastname"], @"Smith", @"Attributes should be set correctly");
    STAssertEqualObjects([employee valueForKey:@"employeeID"], [NSNumber numberWithInt:5678], @"Attributes should be set correctly");
}

#pragma mark - Core Data

- (void)testObjectWithURI {
    
    NSManagedObject *department = [NSEntityDescription insertNewObjectForEntityForName:kDepartment 
                                                                inManagedObjectContext:context];
    
    NSManagedObject *fetchedDepartment = [Broker objectWithURI:department.objectID.URIRepresentation];
     
    STAssertEqualObjects(department, fetchedDepartment, @"Should get the same object");
}

@end
