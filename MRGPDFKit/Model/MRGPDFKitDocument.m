//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitDocument.h"
#import "MRGPDFKitDictionary.h"
#import "MRGPDFKitForm.h"
#import "MRGPDFKitUtility.h"
#import "MRGPDFKitPage.h"

#define isWS(c) ((c) == 0 || (c) == 9 || (c) == 10 || (c) == 12 || (c) == 13 || (c) == 32)

@implementation MRGPDFKitDocument
{
    MRGPDFKitDictionary *_catalog;
    MRGPDFKitDictionary *_info;
    MRGPDFKitForm *_form;
    NSArray *_pages;
}

- (instancetype)initWithFileName:(NSString *)filename
{
    self = [super init];
    if (self) {
        _filename = filename;
    }
    return self;
}

// -----------------------------------------------------------------------------
#pragma mark - Getter
// -----------------------------------------------------------------------------

-(MRGPDFKitForm *)form
{
    if(_form == nil) {
        _form = [[MRGPDFKitForm alloc] initWithParentDocument:self];
    }
    return _form;
}

-(NSMutableData*)documentData
{
    if(_documentData == nil) {
        _documentData = [[NSMutableData alloc] initWithContentsOfFile:self.filename options:NSDataReadingMappedAlways error:NULL];
    }
    return _documentData;
}

-(MRGPDFKitDictionary *)catalog
{
    if(_catalog == nil) {
        _catalog = [[MRGPDFKitDictionary alloc] initWithDictionary:CGPDFDocumentGetCatalog(_document)];

    }
    return _catalog;
}

-(MRGPDFKitDictionary *)info
{
    if(_info == nil) {
        _info = [[MRGPDFKitDictionary alloc] initWithDictionary:CGPDFDocumentGetInfo(_document)];
    }
    return _info;
}

-(NSArray*)pages
{
    if(_pages == nil) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];

        for(NSUInteger i = 0 ; i < CGPDFDocumentGetNumberOfPages(_document); i++) {
            MRGPDFKitPage *add = [[MRGPDFKitPage alloc] initWithPage:CGPDFDocumentGetPage(_document,i+1)];
            [temp addObject:add];
        }
        _pages = [[NSArray alloc] initWithArray:temp];
    }
    return _pages;
}

-(NSUInteger)getPageCount
{
    return CGPDFDocumentGetNumberOfPages(_document);
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (BOOL)openDocument
{
    [self closeDocument];
    _document = [MRGPDFKitUtility newPDFDocumentRefFromPath:self.filename];
    return YES;
}

- (void)closeDocument
{
    if (_document) {
        CGPDFDocumentRelease(_document);
        _document = nil;
    }
}

- (NSData *)flattenedDataForRenderType:(MRGPDFKitDocumentRenderType)renderType
{
    NSUInteger numberOfPages = [self getPageCount];
    NSMutableData *pageData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pageData, CGRectZero , nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    for(NSUInteger page = 1; page <= numberOfPages;page++) {
        CGRect mediaRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFMediaBox);
        CGRect cropRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFCropBox);
        CGRect artRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFArtBox);
        CGRect bleedRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFBleedBox);

        UIGraphicsBeginPDFPageWithInfo(mediaRect, @{(NSString*)kCGPDFContextCropBox:[NSValue valueWithCGRect:cropRect],(NSString*)kCGPDFContextArtBox:[NSValue valueWithCGRect:artRect],(NSString*)kCGPDFContextBleedBox:[NSValue valueWithCGRect:bleedRect]});

        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx,1,-1);
        CGContextTranslateCTM(ctx, 0, -mediaRect.size.height);
        CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(_document,page));
        CGContextRestoreGState(ctx);

        for(MRGPDFKitField *form in self.form) {

            BOOL renderForm = (!form.isFieldNoView && renderType == MRGPDFKitDocumentRenderTypeView) || (!form.isFieldPrintable && renderType == MRGPDFKitDocumentRenderTypePrint) || renderType == MRGPDFKitDocumentRenderTypeFile;
            if(form.page == page && renderForm) {
                CGContextSaveGState(ctx);
                CGRect frame = form.frame;
                CGRect correctedFrame = CGRectMake(frame.origin.x-mediaRect.origin.x, mediaRect.size.height-frame.origin.y-frame.size.height-mediaRect.origin.y, frame.size.width, frame.size.height);
                CGContextTranslateCTM(ctx, correctedFrame.origin.x, correctedFrame.origin.y);
                [form vectorRenderInPDFContext:ctx forRect:correctedFrame];
                CGContextRestoreGState(ctx);
            }
        }
    }

    UIGraphicsEndPDFContext();
    return pageData;
}

- (UIImage *)imageFromPage:(NSUInteger)page width:(NSUInteger)width renderType:(MRGPDFKitDocumentRenderType)renderType
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)[self flattenedDataForRenderType:renderType]);
    CGPDFDocumentRef doc = CGPDFDocumentCreateWithProvider(dataProvider);
    CGDataProviderRelease(dataProvider);

    CGPDFPageRef pageref = CGPDFDocumentGetPage(doc, page);
    CGRect pageRect = CGPDFPageGetBoxRect(pageref, kCGPDFMediaBox);
    const CGFloat deviceScale = [UIScreen mainScreen].scale;
    CGFloat pdfScale = width/pageRect.size.width * deviceScale;
    pageRect.size = CGSizeMake(pageRect.size.width * pdfScale, pageRect.size.height * pdfScale);
    pageRect.origin = CGPointZero;

    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, pageRect);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(pageRect));
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextScaleCTM(context, pdfScale, pdfScale);
    CGContextDrawPDFPage(context, pageref);
    CGContextRestoreGState(context);
    UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGPDFDocumentRelease(doc);
    return thm;
}

- (NSArray *)fieldsWithType:(MRGPDFKitFieldType)type
{
    NSArray *fields = [self.form fieldsWithType:type];
    return fields;
}

- (NSArray *)fieldsWithName:(NSString *)name
{
    NSArray *fields = [self.form fieldsWithName: name];
    return fields;
}

- (BOOL)setFieldValue:(NSString *)value forKey:(NSString *)key
{
    if (self.form) {
        [self.form setValue:value fieldName:key];
    }
    return YES;
}

- (BOOL)setFieldChecked:(BOOL)checked forKey:(NSString *)key
{
    NSString *value = checked ? @"On" : @"";
    return [self setFieldValue:value forKey:key];
}

- (CGFloat)pdfScaleAtPage:(NSUInteger)page pageWidth:(CGFloat)width
{
    NSUInteger i = 0;
    CGFloat pdfScale = 0.0;
    while(i < self.pages.count && pdfScale == 0.0) {
        MRGPDFKitPage *pdfPage = self.pages[i];
        if (pdfPage.pageNumber == page) {
            CGRect pageRect = [pdfPage mediaBox];
            pdfScale = width / CGRectGetWidth(pageRect);
        }
        i++;
    }
    return pdfScale;
}

@end