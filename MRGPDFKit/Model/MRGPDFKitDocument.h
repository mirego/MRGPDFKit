//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MRGPDFKitField.h"

@class MRGPDFKitDictionary;
@class MRGPDFKitForm;

@interface MRGPDFKitDocument : NSObject

@property (nonatomic) NSString *filename;
@property (nonatomic) NSMutableData* documentData;
@property (nonatomic, readonly) MRGPDFKitForm *form;
@property (nonatomic, readonly) MRGPDFKitDictionary * catalog;
@property (nonatomic, readonly) NSArray* pages;
@property (nonatomic, readonly) CGPDFDocumentRef document;
@property (nonatomic, readonly) NSString *fontName;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFileName:(NSString *)filename andFontName:(NSString *)fontName;

- (BOOL)openDocument;
- (void)closeDocument;
- (UIImage *)imageFromPage:(NSUInteger)page width:(NSUInteger)width;
- (NSData *)flattenedData;
- (NSUInteger)getPageCount;

- (NSArray *)fieldsWithType:(MRGPDFKitFieldType)type;
- (NSArray *)fieldsWithName:(NSString *)name;
- (BOOL)setFieldValue:(NSString *)value forKey:(NSString *)key;
- (BOOL)setFieldChecked:(BOOL)checked forKey:(NSString *)key;

@end