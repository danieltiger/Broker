//
//  BKEntityPropertiesMap.m
//  Broker
//
//  Created by Andrew Smith on 10/7/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "BKEntityPropertiesMap.h"

@implementation BKEntityPropertiesMap

@synthesize entityName,
            networkToLocalMap,
            localToNetworkMap;

- (void)dealloc {
    [entityName release];
    [networkToLocalMap release];
    [localToNetworkMap release];
    
    [super dealloc];
}

+ (BKEntityPropertiesMap *)mapFromNetworkProperties:(NSArray *)networkProperties 
                                  toLocalProperties:(NSArray *)localProperties 
                                          forEntityName:(NSString *)entityName {
    
    NSAssert((networkProperties.count == localProperties.count), @"Mapping network properties to local properties expects arrays of the same size");
    
    if (networkProperties.count != localProperties.count) return nil;
    
    BKEntityPropertiesMap *map = [[[BKEntityPropertiesMap alloc] init] autorelease];
    
    NSMutableDictionary *tempNetworkToLocalMap = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableDictionary *tempLocalToNetworkMap = [[[NSMutableDictionary alloc] init] autorelease];

    for (NSString *networkProperty in networkProperties) {
        
        NSString *localProperty = [localProperties objectAtIndex:[networkProperties indexOfObject:networkProperty]];
        
        [tempNetworkToLocalMap setValue:localProperty forKey:networkProperty];
        
        [tempLocalToNetworkMap setValue:networkProperty forKey:localProperty];
    }
    
    map.entityName = entityName;
    map.networkToLocalMap = tempNetworkToLocalMap;
    map.localToNetworkMap = tempLocalToNetworkMap;
    
    return map;
}

- (NSString *)networkPropertyNameForLocalProperty:(NSString *)localProperty {
    return [self.localToNetworkMap valueForKey:localProperty];
}

- (NSString *)localPropertyNameForNetworkProperty:(NSString *)networkProperty {
    return [self.networkToLocalMap valueForKey:networkProperty];
}

@end
