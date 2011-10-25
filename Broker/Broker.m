//
//  Broker.m
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import "Broker.h"

#import "BKJSONOperation.h"

@implementation Broker

@synthesize context;

- (void)dealloc {
    [context release], context = nil;
    [entityDescriptions release], entityDescriptions = nil;
    
    [super dealloc];
}

#pragma mark - Setup

+ (id)brokerWithContext:(NSManagedObjectContext *)context {    
    Broker *broker = [[[self alloc] init] autorelease];
    broker.context = context;
    return broker;
}

- (void)setupWithContext:(NSManagedObjectContext *)aContext {
    self.context = aContext;
}

- (void)reset {
    [context release], context = nil;
    [entityDescriptions release], entityDescriptions = nil;
}

#pragma mark - Registration

- (void)registerEntityNamed:(NSString *)entityName withPrimaryKey:(NSString *)primaryKey {
    [self registerEntityNamed:entityName
               withPrimaryKey:primaryKey
      andMapNetworkProperties:nil 
            toLocalProperties:nil];
}

- (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
      andMapNetworkProperty:(NSString *)networkProperty 
            toLocalProperty:(NSString *)localProperty {
    
    [self registerEntityNamed:entityName
               withPrimaryKey:primaryKey
      andMapNetworkProperties:[NSArray arrayWithObject:networkProperty] 
            toLocalProperties:[NSArray arrayWithObject:localProperty]];
    
}

- (void)registerEntityNamed:(NSString *)entityName
             withPrimaryKey:(NSString *)primaryKey
    andMapNetworkProperties:(NSArray *)networkProperties 
          toLocalProperties:(NSArray *)localProperties {
    
    NSAssert(self.context, @"Broker must be setup with setupWithContext!");
    
    if ([self entityPropertyDescriptionForEntityName:entityName]) {
        WLog(@"Entity named %@ already registered with Broker", entityName);
        return;
    }
    
    // create new object
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                            inManagedObjectContext:self.context];
    
    // Build description of entity properties
    BKEntityPropertiesDescription *desc = [BKEntityPropertiesDescription descriptionForEntity:object.entity 
                                                                         withPropertiesByName:object.entity.propertiesByName
                                                                      andMapNetworkProperties:networkProperties
                                                                            toLocalProperties:localProperties];
    
    // Set primary key
    desc.primaryKey = primaryKey;
    
    // Add to descriptions
    [self.entityDescriptions setObject:desc forKey:entityName];
    
    // cleanup
    [self.context deleteObject:object];
}

- (void)setDateFormat:(NSString *)dateFormat 
          forProperty:(NSString *)property 
             onEntity:(NSString *)entity {
    
    BKAttributeDescription *desc = [self attributeDescriptionForProperty:property onEntityName:entity];;
    desc.dateFormat = dateFormat;
    
}

#pragma mark - JSON

- (void)processJSONPayload:(id)jsonPayload 
            targetEntity:(NSURL *)entityURI
     withCompletionBlock:(void (^)())CompletionBlock{
    
    [self processJSONPayload:jsonPayload
              targetEntity:entityURI
           forRelationship:nil
       withCompletionBlock:CompletionBlock];

}

- (void)processJSONPayload:(id)jsonPayload 
              targetEntity:(NSURL *)entityURI
           forRelationship:(NSString *)relationshipName
       withCompletionBlock:(void (^)())CompletionBlock{

    BKJSONOperation *operation = [BKJSONOperation operation];
    
    operation.jsonPayload = jsonPayload;
    operation.entityURI = entityURI;
    operation.relationshipName = relationshipName;
    operation.context = [self newMainStoreManagedObjectContext];
    
    operation.completionBlock = CompletionBlock;
    
    [self addOperation:operation];
}

#pragma mark - CoreData

- (void)contextDidSave:(NSNotification *)notification {
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);

    NSManagedObjectContext *threadContext = (NSManagedObjectContext *)notification.object;
    
    [self.context performSelectorOnMainThread:selector withObject:notification waitUntilDone:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextDidSaveNotification 
                                                  object:threadContext];
}

- (NSManagedObjectContext *)newMainStoreManagedObjectContext {
    
    // Grab the main coordinator
    NSPersistentStoreCoordinator *coord = [self.context persistentStoreCoordinator];

    // Create new context with default concurrency type
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [newContext setPersistentStoreCoordinator:coord];
    
    // Optimization
    [newContext setUndoManager:nil];
    
    // Observer saves from this context
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:newContext];
    
    return [newContext autorelease];
}

#pragma mark - Accessors

- (BKEntityPropertiesDescription *)entityPropertyDescriptionForEntityName:(NSString *)entityName {
    return (BKEntityPropertiesDescription *)[self.entityDescriptions objectForKey:entityName];
}

- (BKAttributeDescription *)attributeDescriptionForProperty:(NSString *)property 
                                               onEntityName:(NSString *)entityName {
    
    BKEntityPropertiesDescription *desc = [self.entityDescriptions objectForKey:entityName];
    if (desc) {
        return [desc attributeDescriptionForLocalProperty:property];
    }
    return nil;
}


- (BKRelationshipDescription *)relationshipDescriptionForProperty:(NSString *)property 
                                                     onEntityName:(NSString *)entityName {
    
    BKEntityPropertiesDescription *desc = [self.entityDescriptions objectForKey:entityName];
    if (desc) {
        return [desc relationshipDescriptionForProperty:property];
    }
    return nil;
}

- (BKEntityPropertiesDescription *)destinationEntityPropertiesDescriptionForRelationship:(NSString *)relationship
                                                                           onEntityNamed:(NSString *)entityName {
    
    BKRelationshipDescription *desc = [self relationshipDescriptionForProperty:relationship onEntityName:entityName];
    return [self entityPropertyDescriptionForEntityName:desc.destinationEntityName];
}

- (NSMutableDictionary *)entityDescriptions {
    if (entityDescriptions) return [[entityDescriptions retain] autorelease];
    entityDescriptions = [[NSMutableDictionary alloc] init];
    return [[entityDescriptions retain] autorelease];
}

- (NSDictionary *)transformJSONDictionary:(NSDictionary *)jsonDictionary 
         usingEntityPropertiesDescription:(BKEntityPropertiesDescription *)propertiesDescription {
    
    NSMutableDictionary *transformedDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *property in jsonDictionary) {
        
        // Get the property description
        BKPropertyDescription *description = [propertiesDescription descriptionForLocalProperty:property];
        if (!description) {
            // if no description, it could be a network property
            description = [propertiesDescription descriptionForNetworkProperty:property];
            if (!description) DLog(@"No description for property %@ found on entity %@!", property, propertiesDescription.entityName); continue;
        }
        
        // get the original value
        id value = [jsonDictionary valueForKey:property];
        
        // Test to see if networkProperty is relationship or attribute
        if ([propertiesDescription isPropertyRelationship:property]) {
            [transformedDict setObject:value forKey:description.localPropertyName];
        } else {
            
            // transform it using the attribute desc
            id valueAsObject = [(BKAttributeDescription *)description objectForValue:value];
            
            // Add it to the transformed dictionary
            if (valueAsObject) {
                [transformedDict setObject:valueAsObject
                                    forKey:description.localPropertyName];
            }
        }
    }
    
    if ([transformedDict count] == 0) {
        // empty
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:transformedDict];
}

#pragma mark - CoreData

- (NSManagedObject *)objectForURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)aContext {
    NSManagedObjectID *objectID = [[aContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    
    if (!objectID) return nil;
    
    NSManagedObject *objectForID = [aContext objectWithID:objectID];
    
    if (![objectForID isFault]) return objectForID;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[objectID entity]];
    
    // Predicate for fetching self.  Code is faster than string predicate equivalent of 
    // [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject] 
                                                                rightExpression:[NSExpression expressionForConstantValue:objectForID]
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    
    [request setPredicate:predicate];
    
    NSArray *results = [aContext executeFetchRequest:request error:nil];
    if ([results count] > 0 ) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (NSManagedObject *)findOrCreateObjectForEntityDescribedBy:(BKEntityPropertiesDescription *)description 
                                        withPrimaryKeyValue:(id)value
                                                  inContext:(NSManagedObjectContext *)aContext
                                               shouldCreate:(BOOL)create {  
    
    NSAssert(description, @"Must have a description");
    if (!description) return nil;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:description.entityDescription];
    
    if (description.primaryKey) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"SELF.%@ == %@", description.primaryKey, value]];
    }
        
    NSError *error;
    NSArray *array = [aContext executeFetchRequest:request error:&error];
    
    if (create && array.count == 0) {
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:description.entityName 
                                                                inManagedObjectContext:aContext];
        return object;
    } else if (array.count == 1) {
        return (NSManagedObject *)[array objectAtIndex:0];
    }
    
    return nil;
}


@end
