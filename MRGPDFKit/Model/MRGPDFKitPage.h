//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIImage;
@class MRGPDFKitDictionary;


@interface MRGPDFKitPage : NSObject

-(id)initWithPage:(CGPDFPageRef)pg;
-(UIImage *)thumbNailImage;

@property (nonatomic, readonly) MRGPDFKitDictionary *dictionary;
@property (nonatomic, readonly) NSUInteger pageNumber;
@property (nonatomic, readonly) NSInteger rotationAngle;
@property (nonatomic, readonly) CGRect mediaBox;
@property (nonatomic, readonly) CGRect cropBox;
@property (nonatomic, readonly) CGRect bleedBox;
@property (nonatomic, readonly) CGRect trimBox;
@property (nonatomic, readonly) CGRect artBox;
@property (nonatomic, readonly) CGPDFPageRef page;
@property (nonatomic, readonly) MRGPDFKitDictionary *resources;

@end