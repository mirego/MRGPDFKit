//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MRGPDFKitField.h"

@class MRGPDFKitDocument;


@interface MRGPDFKitForm : NSObject<NSFastEnumeration>

@property(nonatomic, weak) MRGPDFKitDocument *document;

- (id)initWithParentDocument:(MRGPDFKitDocument *)parent;
- (NSArray *)fieldsWithName:(NSString *)name;
- (NSArray *)fieldsWithType:(MRGPDFKitFieldType)type;
- (void)setValue:(NSString *)val fieldName:(NSString *)name;

@end