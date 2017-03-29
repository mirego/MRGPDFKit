//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitArray.h"
#import "MRGPDFKitObjectParser.h"
#import "MRGPDFKitDictionary.h"
#import "MRGPDFKitUtility.h"
#import "MRGPDFKitStream.h"
#import "NSString+MRGPDFKit.h"

@implementation MRGPDFKitArray
{
    NSArray* _nsa;
}

- (id)initWithArray:(CGPDFArrayRef)array
{
    self = [super init];
    if(self != nil) {
        _array = array;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getter
//------------------------------------------------------------------------------

- (NSArray *)nsa
{
    if(_nsa == nil)
    {
        NSMutableArray *temp = [NSMutableArray array];

        NSUInteger count = 0;
        NSMutableArray *nsaFiller = nil;

        if(_array == NULL) {
            nsaFiller = [NSMutableArray array];

            MRGPDFKitObjectParser *parser = [MRGPDFKitObjectParser parserWithString:[self pdfFileRepresentation]];

            for(id pdfObject in parser) {
                [nsaFiller addObject:pdfObject];
            }
            count = [nsaFiller count];
        } else {
            count = CGPDFArrayGetCount(_array);
        }

        for(NSUInteger c = 0 ; c < count; c++) {
            id add = (_array != NULL ? [self pdfObjectAtIndex:c] : [nsaFiller objectAtIndex:c]);
            if(add != nil) {
                [temp addObject:add];
            }
        }
        _nsa = [NSArray arrayWithArray:temp];
        [temp removeAllObjects];
    }
    return _nsa;
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (CGRect)rect
{
    if([self.nsa count] < 4) {
        return CGRectZero;
    }
    CGFloat x0,y0,x1,y1;
    x0 = [[self.nsa objectAtIndex:0] floatValue];
    y0 = [[self.nsa objectAtIndex:1] floatValue];
    x1 = [[self.nsa objectAtIndex:2] floatValue];
    y1 = [[self.nsa objectAtIndex:3] floatValue];
    return CGRectMake(MIN(x0,x1),MIN(y0,y1),fabsf((float)(x1-x0)),fabsf((float)(y1-y0)));
}

- (id)objectAtIndex:(NSUInteger)index
{
    if(index < [self.nsa count]) {
        return [self.nsa objectAtIndex:index];
    }
    return nil;
}

- (id)firstObject
{
    return [self.nsa firstObject];
}

- (id)lastObject
{
    return [self.nsa lastObject];
}

- (NSUInteger)count
{
    return [self.nsa count];
}

- (BOOL)isEqualToArray:(MRGPDFKitArray *)otherArray
{
    return [self.nsa isEqualToArray:otherArray.nsa];
}

- (NSString *)pdfFileRepresentation
{
    if([super pdfFileRepresentation])return [super pdfFileRepresentation];

    NSMutableString *ret = [NSMutableString stringWithString:@"["];
    for(NSUInteger i = 0  ; i < [self count];i++) {
        [ret appendFormat:@" %@",[MRGPDFKitUtility pdfObjectRepresentationFrom:[self objectAtIndex:i]]];
    }

    [ret appendString:@"]"];
    return [NSString stringWithString:ret];
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

- (CGPDFObjectType)typeAtIndex:(NSUInteger)index
{
    if(_array != NULL) {
        CGPDFObjectRef obj = NULL;
        if(CGPDFArrayGetObject(_array, index, &obj)) {
            return CGPDFObjectGetType(obj);
        }
        return kCGPDFObjectTypeNull;
    }
    return kCGPDFObjectTypeNull;
}

- (id)pdfObjectAtIndex:(NSUInteger)index
{
    if(_array == NULL) {
        return nil;
    }

    CGPDFObjectRef obj = NULL;
    if(CGPDFArrayGetObject(_array, index, &obj))
    {
        CGPDFObjectType type =  CGPDFObjectGetType(obj);
        switch (type) {
            case kCGPDFObjectTypeDictionary:
                return [self dictionaryAtIndex:index];
            case kCGPDFObjectTypeArray:
                return [self arrayAtIndex:index];
            case kCGPDFObjectTypeString:
                return [self stringAtIndex:index];
            case kCGPDFObjectTypeName:
                return [self nameAtIndex:index];
            case kCGPDFObjectTypeInteger:
                return [self integerAtIndex:index];
            case kCGPDFObjectTypeReal:
                return [self realAtIndex:index];
            case kCGPDFObjectTypeBoolean:
                return [self booleanAtIndex:index];
            case kCGPDFObjectTypeStream:
                return [self streamAtIndex:index];
            case kCGPDFObjectTypeNull:
            default:
                return nil;
        }
    }

    return nil;
}

- (MRGPDFKitDictionary *)dictionaryAtIndex:(NSUInteger)index
{
    CGPDFDictionaryRef dr = NULL;
    if(CGPDFArrayGetDictionary(_array, index, &dr)) {
        return [[MRGPDFKitDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (MRGPDFKitArray *)arrayAtIndex:(NSUInteger)index
{
    CGPDFArrayRef ar = NULL;
    if(CGPDFArrayGetArray(_array, index, &ar)) {
        return [[MRGPDFKitArray alloc] initWithArray:ar];
    }
    return nil;
}

- (NSString *)stringAtIndex:(NSUInteger)index
{
    CGPDFStringRef str = NULL;
    if(CGPDFArrayGetString(_array, index, &str)) {
        NSString *ret = (__bridge_transfer NSString*)CGPDFStringCopyTextString(str);
        [ret setAsName:NO];
        return ret;
    }
    return nil;
}

- (NSString *)nameAtIndex:(NSUInteger)index
{
    const char* targ = NULL;
    if(CGPDFArrayGetName(_array, index, &targ)) {
        NSString* ret = [NSString stringWithUTF8String:targ];
        [ret setAsName:YES];
        return ret;
    }
    return nil;
}

- (NSNumber *)integerAtIndex:(NSUInteger)index
{
    CGPDFInteger targ;
    if(CGPDFArrayGetInteger(_array, index, &targ)) {
        return [NSNumber numberWithUnsignedInteger:(NSUInteger)targ];
    }
    return nil;
}


- (NSNumber *)realAtIndex:(NSUInteger)index
{
    CGPDFReal targ;
    if(CGPDFArrayGetNumber(_array, index, &targ)) {
        return [NSNumber numberWithFloat:(float)targ];
    }
    return nil;
}


- (NSNumber *)booleanAtIndex:(NSUInteger)index
{
    CGPDFBoolean targ;
    if(CGPDFArrayGetBoolean(_array, index, &targ)) {
        return [NSNumber numberWithBool:(BOOL)targ];
    }
    return nil;
}


- (MRGPDFKitStream *)streamAtIndex:(NSUInteger)index
{
    CGPDFStreamRef targ = NULL;
    if(CGPDFArrayGetStream(_array, index, &targ)) {
        return [[MRGPDFKitStream alloc] initWithStream:targ];
    }
    return nil;
}

//------------------------------------------------------------------------------
#pragma mark - NSFastEnumeration
//------------------------------------------------------------------------------

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.nsa countByEnumeratingWithState:state objects:buffer count:len];
}

@end
