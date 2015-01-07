//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MRGPDFKitArray.h"


@interface MRGPDFKitDictionary : MRGPDFKitObject <NSFastEnumeration>

@property (nonatomic, readonly) NSDictionary *nsd;
@property (nonatomic, readonly) CGPDFDictionaryRef dictionary;
@property (nonatomic, weak) MRGPDFKitDictionary *parent;

- (id)initWithDictionary:(CGPDFDictionaryRef)dictionary;
- (id)objectForKey:(NSString*)key;
- (NSArray*)allKeys;
- (NSArray*)allValues;
- (NSUInteger)count;
- (BOOL)isEqualToDictionary:(MRGPDFKitDictionary *)otherDictionary;
- (NSString*)updatedRepresentation:(NSDictionary*)update;

@end