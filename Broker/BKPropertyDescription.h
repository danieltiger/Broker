//
//  BKPropertyDescription.h
//  Broker
//
//  Created by Andrew Smith on 10/10/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPropertyDescription : NSObject {
@private
    NSString *entityName;
    NSString *localPropertyName;
    NSString *networkPropertyName;
}

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *localPropertyName;
@property (nonatomic, copy) NSString *networkPropertyName;

@end
