//
//  BrokerTestsHelpers.h
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrokerTestsHelpers : NSObject

NSString *PathForTestResource(NSString *resouce);

NSString *UTF8StringFromFile(NSString *fileName);

NSData *DataFromFile(NSString *fileName);


@end
