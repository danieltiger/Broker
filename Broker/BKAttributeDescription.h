//
//  BKEntityMap.h
//  Broker
//
//  Created by Andrew Smith on 10/5/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BKPropertyDescription.h"

@interface BKAttributeDescription : BKPropertyDescription {
@private
    NSString *dateFormat;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, copy) NSString *dateFormat;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) NSAttributeType attributeType;

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description;

+ (BKAttributeDescription *)descriptionWithAttributeDescription:(NSAttributeDescription *)description
                                   andMapToNetworkAttributeName:(NSString *)networkAttributeName;

/**
 * Returns the correct object type with the given value
 */
- (id)objectForValue:(id)value;

@end
