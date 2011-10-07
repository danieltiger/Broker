//
//  BrokerTestsHelpers.m
//  Broker
//
//  Created by Andrew Smith on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrokerTestsHelpers.h"

@implementation BrokerTestsHelpers

NSString *PathForTestResource(NSString *resouce) {
    
    NSString *testBundlePath = [[NSBundle bundleForClass:[BrokerTestsHelpers class]] pathForResource:@"TestResources" 
                                                                                              ofType:@"bundle"];
    return [NSString stringWithFormat:@"%@/%@", testBundlePath, resouce];
}

NSString *UTF8StringFromFile(NSString *fileName) {
    NSString *path = PathForTestResource(fileName);
    
    NSError *error;
    NSString *string = [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    return string;
}

NSData *DataFromFile(NSString *fileName) {
    NSString *path = PathForTestResource(fileName);
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path 
                                          options:NSDataReadingUncached 
                                            error:&error];
    
    return data;
}


@end
