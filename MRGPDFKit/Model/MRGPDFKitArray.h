//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MRGPDFKitObject.h"


@interface MRGPDFKitArray : MRGPDFKitObject <NSFastEnumeration>

@property (nonatomic, readonly) NSArray *nsa;
@property (nonatomic, readonly) CGPDFArrayRef array;

- (id)initWithArray:(CGPDFArrayRef)array;
- (CGRect)rect;
- (id)objectAtIndex:(NSUInteger)index;
- (id)firstObject;
- (id)lastObject;
- (NSUInteger)count;
- (BOOL)isEqualToArray:(MRGPDFKitArray *)otherArray;

@end