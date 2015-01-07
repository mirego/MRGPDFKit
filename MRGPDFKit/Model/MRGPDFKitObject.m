//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitObject.h"
#import "MRGPDFKitArray.h"
#import "MRGPDFKitDictionary.h"
#import "MRGPDFKitUtility.h"

@implementation MRGPDFKitObject
{
    NSString *_representation;
}

+ (MRGPDFKitObject *)createWithPDFRepresentation:(NSString *)rep
{
    NSString *test = [rep stringByTrimmingCharactersInSet:[MRGPDFKitUtility whiteSpaceCharacterSet]];
    if(test.length>=2)
    {
        if([test characterAtIndex:0] == '<' && [test characterAtIndex:1] == '<')
            return [[MRGPDFKitDictionary alloc] initWithPDFRepresentation:rep ];
        if([test characterAtIndex:0] == '[')
            return [[MRGPDFKitArray alloc] initWithPDFRepresentation:rep ];
    }

    return [[MRGPDFKitObject alloc] initWithPDFRepresentation:rep];
}


- (id)initWithPDFRepresentation:(NSString *)rep
{
    self = [super init];
    if(self != nil) {
        NSString* temp = [rep stringByTrimmingCharactersInSet:[MRGPDFKitUtility whiteSpaceCharacterSet]];
        _representation = temp;

    }

    return self;
}


- (id)initWithPDFObject:(CGPDFObjectRef)obj
{
    self = [super init];
    if(self != nil) {
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (NSString *)pdfFileRepresentation
{
    return _representation;
}

@end