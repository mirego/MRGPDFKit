//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MRGPDFKitDictionary;


@interface MRGPDFKitStream : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) CGPDFDataFormat dataFormat;
@property (nonatomic, readonly) MRGPDFKitDictionary *dictionary;

- (id)initWithStream:(CGPDFStreamRef)stream;

@end