//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


@interface MRGPDFKitUtility : NSObject

+ (CGPDFDocumentRef)newPDFDocumentRefFromData:(NSData *)data;
+ (CGPDFDocumentRef)newPDFDocumentRefFromResource:(NSString *)name;
+ (CGPDFDocumentRef)newPDFDocumentRefFromPath:(NSString *)pathToPdfDoc;
+ (NSString *)pdfEncodedString:(NSString *)stringToEncode;
+ (NSString *)pdfObjectRepresentationFrom:(id)obj;
+ (NSCharacterSet *)whiteSpaceCharacterSet;
+ (NSString *)stringReplacingWhiteSpaceWithSingleSpace:(NSString *)str;
+ (NSString *)urlEncodeString:(NSString *)str;
+ (NSString *)decodeURLEncodedString:(NSString *)str;
+ (NSString *)urlEncodeStringXML:(NSString *)str;

@end