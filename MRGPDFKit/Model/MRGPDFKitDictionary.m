//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitDictionary.h"
#import "MRGPDFKitObjectParser.h"
#import "MRGPDFKitStream.h"
#import "MRGPDFKitUtility.h"
#import "NSString+MRGPDFKit.h"

@implementation MRGPDFKitDictionary
{
    NSDictionary *_nsd;
}

- (id)initWithDictionary:(CGPDFDictionaryRef)dictionary
{
    self = [super init];
    if(self != nil) {
        _dictionary = dictionary;
    }

    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getter
//------------------------------------------------------------------------------

- (MRGPDFKitDictionary *)parent
{
    if(_parent == nil) {
        _parent = [self.nsd objectForKey:@"Parent"];
    }
    return _parent;
}

- (NSDictionary *)nsd
{
    if(_nsd == nil) {
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableDictionary *nsdFiller = nil;
        if(_dictionary != NULL) {
            CGPDFDictionaryApplyFunction(_dictionary, checkKeys, (__bridge void *)(keys));
        } else {
            nsdFiller = [NSMutableDictionary dictionary];
            NSMutableArray *keysAndValues = [[NSMutableArray alloc] init];

            MRGPDFKitObjectParser *parser = [MRGPDFKitObjectParser parserWithString:[self pdfFileRepresentation]];

            for(id pdfObject in parser){
                [keysAndValues addObject:pdfObject];
            }

            if([keysAndValues count]&1) {
                return nil;
            }

            for(NSUInteger c = 0 ; c < [keysAndValues count]/2; c++) {
                NSString *key = [keysAndValues objectAtIndex:2*c];
                [keys addObject:key];
                [nsdFiller setObject:[keysAndValues objectAtIndex:2*c+1] forKey:key];
            }
        }

        NSMutableDictionary *temp = [NSMutableDictionary dictionary];

        for(NSString *key in keys) {
            id set = (_dictionary!=NULL?[self pdfObjectFromKey:key]:[nsdFiller objectForKey:key]);
            if(set != nil) {

                if([set isKindOfClass:[MRGPDFKitDictionary class]]) {
                    [set setParent:self];
                }

                [temp setObject:set forKey:key];
            }
        }
        _nsd = [NSDictionary  dictionaryWithDictionary:temp];
    }
    return _nsd;
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

void checkKeys(const char *key, CGPDFObjectRef value, void *info)
{
    NSString *add = [[NSString alloc] initWithUTF8String:key];
    [(__bridge NSMutableArray *)info addObject:add];

}

- (CGPDFObjectType)typeForKey:(NSString*)aKey
{
    if(_dictionary != NULL) {
        CGPDFObjectRef obj = NULL;
        if(CGPDFDictionaryGetObject(_dictionary, [aKey UTF8String], &obj)) {
            return CGPDFObjectGetType(obj);
        }
        return kCGPDFObjectTypeName;
    }
    return kCGPDFObjectTypeNull;
}

- (id)pdfObjectFromKey:(NSString*)key
{
    CGPDFObjectRef obj = NULL;
    if(CGPDFDictionaryGetObject(_dictionary, [key UTF8String], &obj)) {
        CGPDFObjectType type =  CGPDFObjectGetType(obj);
        switch (type) {
            case kCGPDFObjectTypeDictionary:
                return [self dictionaryFromKey:key];
            case kCGPDFObjectTypeArray:
                return [self arrayFromKey:key];
            case kCGPDFObjectTypeString:
                return [self stringFromKey:key];
            case kCGPDFObjectTypeName:
                return [self nameFromKey:key];
            case kCGPDFObjectTypeInteger:
                return [self integerFromKey:key];
            case kCGPDFObjectTypeReal:
                return [self realFromKey:key];
            case kCGPDFObjectTypeBoolean:
                return [self booleanFromKey:key];
            case kCGPDFObjectTypeStream:
                return [self streamFromKey:key];
            case kCGPDFObjectTypeNull:
            default:
                return nil;
        }
    }

    return nil;
}

- (MRGPDFKitDictionary *)dictionaryFromKey:(NSString *)key
{
    CGPDFDictionaryRef dr = NULL;
    if(CGPDFDictionaryGetDictionary(_dictionary, [key UTF8String], &dr)) {
        return [[MRGPDFKitDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (MRGPDFKitArray *)arrayFromKey:(NSString *)key
{
    CGPDFArrayRef ar = NULL;
    if(CGPDFDictionaryGetArray(_dictionary, [key UTF8String], &ar)) {
        return [[MRGPDFKitArray alloc] initWithArray:ar];
    }
    return nil;
}

- (NSString *)stringFromKey:(NSString*)key
{
    CGPDFStringRef str = NULL;
    if(CGPDFDictionaryGetString(_dictionary, [key UTF8String], &str)) {
        NSString *ret = (__bridge_transfer NSString*)CGPDFStringCopyTextString(str);
        [ret setAsName:NO];
        return ret;
    }
    return nil;
}

- (NSString *)nameFromKey:(NSString*)key
{
    const char* targ = NULL;
    if(CGPDFDictionaryGetName(_dictionary, [key UTF8String], &targ)) {
        NSString* ret = [NSString stringWithUTF8String:targ];
        [ret setAsName:YES];
        return ret;
    }
    return nil;
}

- (NSNumber *)integerFromKey:(NSString*)key
{
    CGPDFInteger targ;
    if(CGPDFDictionaryGetInteger(_dictionary, [key UTF8String], &targ)) {
        return [NSNumber numberWithUnsignedInteger:(NSUInteger)targ];
    }
    return nil;
}
- (NSNumber *)realFromKey:(NSString*)key
{
    CGPDFReal targ;
    if(CGPDFDictionaryGetNumber(_dictionary, [key UTF8String], &targ)) {
        return [NSNumber numberWithFloat:(float)targ];
    }
    return nil;
}


- (NSNumber *)booleanFromKey:(NSString*)key
{
    CGPDFBoolean targ;
    if(CGPDFDictionaryGetBoolean(_dictionary, [key UTF8String], &targ)) {
        return [NSNumber numberWithBool:(BOOL)targ];
    }
    return nil;
}


- (MRGPDFKitStream *)streamFromKey:(NSString*)key
{
    CGPDFStreamRef targ = NULL;
    if(CGPDFDictionaryGetStream(_dictionary, [key UTF8String], &targ)) {
        return [[MRGPDFKitStream alloc] initWithStream:targ];
    }
    return nil;
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (id)objectForKey:(NSString*)key
{
    return [self.nsd objectForKey:key];
}

- (NSArray *)allKeys
{
    return [self.nsd allKeys];
}

- (NSArray *)allValues
{
    return [self.nsd allValues];
}

- (NSUInteger)count
{
    return [self.nsd count];
}

- (BOOL)isEqualToDictionary:(MRGPDFKitDictionary *)otherDictionary
{
    return [self.nsd isEqualToDictionary:otherDictionary.nsd];
}

- (NSString *)updatedRepresentation:(NSDictionary *)update
{

    NSArray *keys = [[[NSSet setWithArray:[self allKeys]] setByAddingObjectsFromArray:[update allKeys]] allObjects];

    NSMutableString *ret = [NSMutableString stringWithString:@"<<\n"];
    for(NSUInteger i = 0  ; i < [keys count];i++) {
        NSString *key = [keys objectAtIndex:i];
        if(![[update objectForKey:key] isKindOfClass:[NSNull class]]) {
            id obj = [self objectForKey:key];

            if([update objectForKey:key]) {
                obj = [update objectForKey:key];
            }

            NSString *objRepresentation = [MRGPDFKitUtility pdfObjectRepresentationFrom:obj];
            [ret appendString:[NSString stringWithFormat:@"/%@ %@\n",[MRGPDFKitUtility pdfEncodedString:key],objRepresentation]];
        }
    }

    [ret appendString:@">>"];

    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"\\((\\d+),(\\d+),ioref\\)" options:0 error:NULL];
    ret = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:ret options:0 range:NSMakeRange(0, ret.length) withTemplate:@" $1 $2 R "]];

    return [NSString stringWithString:ret];
}

//------------------------------------------------------------------------------
#pragma mark - NSFastEnumeration
//------------------------------------------------------------------------------

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.nsd countByEnumeratingWithState:state objects:buffer count:len];
}

@end