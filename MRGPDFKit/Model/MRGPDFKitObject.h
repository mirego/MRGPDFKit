//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MRGPDFKitObject : NSObject

- (id)initWithPDFRepresentation:(NSString *)rep;
+ (MRGPDFKitObject *)createWithPDFRepresentation:(NSString *)rep ;
- (id)initWithPDFObject:(CGPDFObjectRef)obj;
- (NSString*)pdfFileRepresentation;

@end