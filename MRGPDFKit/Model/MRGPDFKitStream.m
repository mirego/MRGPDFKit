//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitStream.h"
#import "MRGPDFKitDictionary.h"


@implementation MRGPDFKitStream
{
    CGPDFStreamRef _strm;
    NSData *_data;
    MRGPDFKitDictionary *_dictionary;
    CGPDFDataFormat _dataFormat;
}

-(id)initWithStream:(CGPDFStreamRef)pstrm
{
    self = [super init];
    if(self != nil) {
        _strm = pstrm;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getter
//------------------------------------------------------------------------------

- (MRGPDFKitDictionary *)dictionary
{
    if(_dictionary == nil) {
        CGPDFDictionaryRef dict = CGPDFStreamGetDictionary(_strm);
        if(dict) {
            _dictionary = [[MRGPDFKitDictionary alloc] initWithDictionary:dict];
        }
    }
    return _dictionary;
}


- (CGPDFDataFormat)dataFormat
{
    if(_data == nil) {
        [self data];
    }
    return _dataFormat;
}

- (NSData *)data
{
    if(_data == nil) {
        CFDataRef dat = CGPDFStreamCopyData(_strm, &_dataFormat);
        _data = ((__bridge_transfer NSData*)dat);
    }
    return _data;
}

@end