//
//  BKEntityPropertiesMap.h
//  Broker
//
//  Created by Andrew Smith on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKEntityPropertiesMap : NSObject{
@private
    NSString *entityName;
}

@property (nonatomic, copy) NSString *entityName;

@end
