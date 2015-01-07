//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRGPDFKitPage.h"
#import "MRGPDFKitDictionary.h"

@implementation MRGPDFKitPage
{
    CGPDFPageRef _page;
    MRGPDFKitDictionary *_dictionary;
    MRGPDFKitDictionary *_resources;
}

- (id)initWithPage:(CGPDFPageRef)pg
{
    self = [super init];
    if(self != nil) {
        _page = pg;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getter
//------------------------------------------------------------------------------

- (MRGPDFKitDictionary *)dictionary
{
    if(_dictionary == nil) {
        _dictionary = [[MRGPDFKitDictionary alloc] initWithDictionary: CGPDFPageGetDictionary(_page)];
    }
    return _dictionary;
}

- (MRGPDFKitDictionary *)resources
{
    if(_resources == nil) {
        MRGPDFKitDictionary *iter = self.dictionary;
        MRGPDFKitDictionary *res = nil;
        while((res = [iter objectForKey:@"Resources"]) == nil) {
            iter = [iter objectForKey:@"Parent"];
            if(iter == nil)break;
        }
        _resources = res;
    }
    return _resources;
}

- (UIImage *)thumbNailImage
{
    NSData *dat = [[self.dictionary objectForKey:@"Thumb"] data];
    if(dat) {
        return [UIImage imageWithData:dat];
    }
    return nil;
}

- (NSUInteger)pageNumber
{
    return CGPDFPageGetPageNumber(_page);
}

- (NSInteger)rotationAngle
{
    return CGPDFPageGetRotationAngle(_page);
}

- (CGRect)mediaBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFMediaBox)];
}

- (CGRect)cropBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFCropBox)];
}

- (CGRect)bleedBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFBleedBox)];
}

- (CGRect)trimBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFTrimBox)];
}

- (CGRect)artBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFArtBox)];
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

-(CGRect)rotateBox:(CGRect)box
{
    CGRect ret= box;
    switch([self rotationAngle]%360) {
        case 0:
            break;
        case 90:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
            break;
        case 180:
            break;
        case 270:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
        default:
            break;
    }
    return ret;
}

@end