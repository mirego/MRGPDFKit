//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@class MRGPDFKitDictionary;
@class MRGPDFKitForm;
@class MRGPDFKitPage;
@class MRGPDFKitWidget;

#define BIT(n,i) (((i)>>(n))&1)

typedef NS_ENUM(NSUInteger, MRGPDFKitFieldType) {
    MRGPDFKitFieldTypeNone = 0,
    MRGPDFKitFieldTypeText,
    MRGPDFKitFieldTypeButton,
    MRGPDFKitFieldTypeChoice,
    MRGPDFKitFieldTypeSignature,
    MRGPDFKitFieldTypeNumberOfFormTypes
};

@interface MRGPDFKitField : NSObject

@property (nonatomic) NSString *value;
@property (nonatomic) NSUInteger page;
@property (nonatomic) CGRect frame;
@property (nonatomic) MRGPDFKitFieldType fieldType;
@property (nonatomic) CGRect cropBox;
@property (nonatomic) CGRect mediaBox;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *uname;
@property (nonatomic) NSString *defaultValue;
@property (nonatomic) NSString *flagsString;
@property (nonatomic) NSArray *options;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) CGRect uiBaseFrame;
@property (nonatomic) CGRect pageFrame;
@property (nonatomic, weak) MRGPDFKitForm *parent;
@property (nonatomic) NSMutableDictionary *actions;
@property (nonatomic) NSArray *rawRect;
@property (nonatomic) NSString *exportValue;
@property (nonatomic) BOOL modified;
@property (nonatomic) NSString *setAppearanceStream;
@property (nonatomic) MRGPDFKitDictionary *dictionary;
@property (nonatomic) MRGPDFKitWidget *widget;

- (id)initWithFieldDictionary:(MRGPDFKitDictionary *)leaf page:(MRGPDFKitPage *)page parent:(MRGPDFKitForm *)parent;
- (void)reset;
- (void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect;

@end