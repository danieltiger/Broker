//
//  NSManagedObject+Broker.h
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Broker)

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary;

@end
