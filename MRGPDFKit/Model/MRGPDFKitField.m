//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitField.h"
#import "MRGPDFKitDictionary.h"
#import "MRGPDFKitForm.h"
#import "MRGPDFKitPage.h"
#import "MRGPDFKitStream.h"
#import "MRGPDFKitDocument.h"
#import "MRGPDFKitWidget.h"
#import "MRGPDFKitFieldSignature.h"
#import "NSString+MRGPDFKit.h"

@implementation MRGPDFKitField
{
    NSUInteger _flags;
    NSUInteger _annotFlags;
    NSString *_fontName;
    CGFloat _fontSize;
    NSInteger _fontColor;
    NSUInteger _maxLen;
}

- (id)initWithFieldDictionary:(MRGPDFKitDictionary *)leaf page:(MRGPDFKitPage *)page parent:(MRGPDFKitForm *)parent
{
    self = [super init];
    if(self != nil) {
        self.dictionary = leaf;
        _value = [self getAttributeFromLeaf:leaf Name:@"V" Inheritable:YES];
        self.name = [self getFieldNameFromLeaf:leaf];
        NSString *fieldTypeString = [self getAttributeFromLeaf:leaf Name:@"FT"  Inheritable:YES];
        self.defaultValue = [self getAttributeFromLeaf:leaf Name:@"DV"  Inheritable:YES];
        self.uname = [self getAttributeFromLeaf:leaf Name:@"TU"  Inheritable:YES];
        _flags = [[self getAttributeFromLeaf:leaf Name:@"Ff"  Inheritable:YES] unsignedIntegerValue];
        NSNumber *fieldTextAlignment = [self getAttributeFromLeaf:leaf Name:@"Q" Inheritable:YES];
        self.exportValue = [self getExportValueFrom:leaf];
        self.setAppearanceStream = [self getSetAppearanceStreamFromLeaf:leaf];
        NSString *fontInfo = [self getAttributeFromLeaf:leaf Name:@"DA" Inheritable:YES];
        [self extractDefaultAppearance:fontInfo];
        _maxLen = [[self getAttributeFromLeaf:leaf Name:@"MaxLen" Inheritable:YES] unsignedIntegerValue];

        NSArray *arr = [[self getAttributeFromLeaf:leaf Name:@"Opt" Inheritable:YES] nsa];

        NSMutableArray *temp = [NSMutableArray array];

        for(id obj in arr) {
            if([obj isKindOfClass:[MRGPDFKitArray class]]) {
                [temp addObject:[obj objectAtIndex:0]];
            } else {
                [temp addObject:obj];
            }
        }

        self.options = [NSArray arrayWithArray:temp];

        if([fieldTypeString isEqualToString:@"Btn"]) {
            self.fieldType = MRGPDFKitFieldTypeButton;
        } else if([fieldTypeString isEqualToString:@"Tx"]) {
            self.fieldType = MRGPDFKitFieldTypeText;
        } else if([fieldTypeString isEqualToString:@"Ch"]) {
            self.fieldType = MRGPDFKitFieldTypeChoice;
        } else if([fieldTypeString isEqualToString:@"Sig"]) {
            self.fieldType = MRGPDFKitFieldTypeSignature;
            self.widget = [MRGPDFKitFieldSignature new];
        }

        self.rawRect = [[leaf objectForKey:@"Rect"] nsa];
        self.frame = [[leaf objectForKey:@"Rect"] rect];

        self.page = page.pageNumber;
        self.mediaBox = page.mediaBox;
        self.cropBox =  page.cropBox;

        if([leaf objectForKey:@"F"]) {
            _annotFlags = [[leaf objectForKey:@"F"] unsignedIntegerValue];
        }

        [[self.actions allValues] makeObjectsPerformSelector:@selector(setParent:) withObject:self];

        if(fieldTextAlignment) {
            self.textAlignment = [fieldTextAlignment unsignedIntegerValue];
        }

        [self updateFlagsString];
        self.parent = parent;
        BOOL noRotate = [_flagsString rangeOfString:@"NoRotate"].location!=NSNotFound;

        NSUInteger rotation = [(MRGPDFKitPage *)[self.parent.document.pages objectAtIndex:_page-1] rotationAngle];
        if(noRotate) {
            rotation = 0;
        }
        CGFloat a = self.frame.size.width;
        CGFloat b = self.frame.size.height;

        CGFloat fx = self.frame.origin.x;
        CGFloat fy = self.frame.origin.y;
        CGFloat tw = self.cropBox.size.width;
        CGFloat th = self.cropBox.size.height;

        switch(rotation % 360) {
            case 0:
                break;
            case 90:
                self.frame = CGRectMake(fy, th-fx-a, b, a);
                break;
            case 180:
                self.frame = CGRectMake(tw-fx-a, th-fy-b, a, b);
                break;
            case 270:
                self.frame = CGRectMake(tw-fy-b, fx, b, a);
            default:
                break;
        }
    }

    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getter & Setter
//------------------------------------------------------------------------------

- (void)setOptions:(NSArray *)opt
{
    if([opt isKindOfClass:[NSNull class]]) {
        _options = nil;
    } else {
        _options = opt;
    }
}

 -(void)setValue:(NSString *)val
{
    if([val isKindOfClass:[NSNull class]] == YES) {
        [self setValue:nil];
    } else {
        if([val isEqualToString:self.value] == NO && (val || _value)) {
            self.modified = YES;
        }

        if(_value != val) {
            _value = val;
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect
{
    @synchronized ([NSString class]) {
        if (self.fieldType == MRGPDFKitFieldTypeText || self.fieldType == MRGPDFKitFieldTypeChoice) {
            NSString *text = self.value;
            UIFont *font = nil;
            if (_fontSize == 0) {
                font = [self fontCalculatedWithText:text inRect:rect fontName:_fontName];
            } else {
                font = [self secureFontWithName:_fontName size:_fontSize];
            }

            UIGraphicsPushContext(ctx);
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

            if (_maxLen > 0 && text.length <= _maxLen) {
                CGFloat subRectWidth = CGRectGetWidth(rect) / _maxLen;
                paragraphStyle.alignment = NSTextAlignmentCenter;
                for (NSUInteger i = 0; i < text.length; i++) {
                    NSString *character = [text substringWithRange:NSMakeRange(i, 1)];
                    const CGRect subRect = CGRectMake(subRectWidth * i, 0, subRectWidth, CGRectGetHeight(rect));
                    [character drawInRect:subRect withAttributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle}];
                }
            } else {
                CGRect textRect = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect));
                paragraphStyle.alignment = self.textAlignment;
                textRect.origin.y = rect.size.height - font.pointSize;
                [text drawInRect:textRect withAttributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle}];
            }

            UIGraphicsPopContext();
        } else if (self.fieldType == MRGPDFKitFieldTypeButton) {
            CGFloat minDim = MIN(rect.size.width, rect.size.height) * 0.85;
            CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
            rect = CGRectMake(center.x - minDim / 2, center.y - minDim / 2, minDim, minDim);

            if ([self.value isEqualToString:self.exportValue]) {
                CGContextSaveGState(ctx);
                CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
                CGContextFillRect(ctx, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));
                CGContextRestoreGState(ctx);
            }
        } else if (self.fieldType == MRGPDFKitFieldTypeSignature) {
            MRGPDFKitFieldSignature *fieldSignature = (MRGPDFKitFieldSignature *)self.widget;
            UIImage *signature = fieldSignature.signature;

            if (signature != nil) {
                UIGraphicsPushContext(ctx);
                [signature drawInRect:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
                UIGraphicsPopContext();
            }
        }
    }
}

- (void)reset
{
    self.value = self.defaultValue;
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

- (void)updateFlagsString
{
    NSString *temp = @"";

    if(BIT(0, _flags)) {
        temp = [temp stringByAppendingString:@"-ReadOnly"];
    }
    if(BIT(1, _flags)) {
        temp = [temp stringByAppendingString:@"-Required"];
    }
    if(BIT(2, _flags)) {
        temp = [temp stringByAppendingString:@"-NoExport"];
    }

    if(_fieldType == MRGPDFKitFieldTypeButton) {
        if(BIT(14, _flags)) {
            temp = [temp stringByAppendingString:@"-NoToggleToOff"];
        }
        if(BIT(15, _flags)) {
            temp = [temp stringByAppendingString:@"-Radio"];
        }
        if(BIT(16, _flags)) {
            temp = [temp stringByAppendingString:@"-Pushbutton"];
        }
    } else if(_fieldType == MRGPDFKitFieldTypeChoice) {
        if(BIT(17, _flags)) {
            temp = [temp stringByAppendingString:@"-Combo"];
        }
        if(BIT(18, _flags)) {
            temp = [temp stringByAppendingString:@"-Edit"];
        }
        if(BIT(19, _flags)) {
            temp = [temp stringByAppendingString:@"-Sort"];
        }
    }
    else if(_fieldType == MRGPDFKitFieldTypeText)
    {
        if(BIT(12, _flags)) {
            temp = [temp stringByAppendingString:@"-Multiline"];
        }
        if(BIT(13, _flags)) {
            temp = [temp stringByAppendingString:@"-Password"];
        }
    }

    if(BIT(0, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Invisible"];
    }
    if(BIT(1, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Hidden"];
    }
    if(BIT(2, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Print"];
    }
    if(BIT(3, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoZoom"];
    }
    if(BIT(4, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoRotate"];
    }
    if(BIT(5, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoView"];
    }
    self.flagsString = temp;
}

- (UIFont *)secureFontWithName:(NSString *)name size:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:name size:size];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

- (UIFont *)fontCalculatedWithText:(NSString *)text inRect:(CGRect)rect fontName:(NSString *)fontName
{
    CGFloat height = rect.size.height;
    CGSize size = CGSizeZero;
    UIFont *font = nil;

    do {
        font = [self secureFontWithName:fontName size:height];
        size = [text sizeWithFont:font thatFitsMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        height -= 1.0;
    } while (size.width >= CGRectGetWidth(rect) && height > 0);
    return font;
}

- (id)getAttributeFromLeaf:(MRGPDFKitDictionary *)leaf Name:(NSString *)nme  Inheritable:(BOOL)inheritable
{
    MRGPDFKitDictionary *iter = nil;
    MRGPDFKitDictionary *temp = nil;
    id object;

    temp = [leaf objectForKey:@"Parent"];

    iter = ((temp == nil) ? leaf.parent : leaf);

    if(iter == nil) {
        iter = leaf;
    }

    BOOL objectIsValid;

    while(!(objectIsValid = ((object = [iter objectForKey:nme])!=nil)) && (inheritable == YES)) {
        object = nil;
        if(!(temp = [iter objectForKey:@"Parent"])) {
            break;
        }
        iter = temp;
    }

    if((inheritable == NO && objectIsValid == NO) || object == NULL) {
        return nil;
    }
    return object;
}

- (NSString*)getFieldNameFromLeaf:(MRGPDFKitDictionary *)leaf
{
    MRGPDFKitDictionary *iter = nil;
    MRGPDFKitDictionary *temp = nil;

    temp = [leaf objectForKey:@"Parent"];
    iter = ((temp == nil)?leaf.parent:leaf);

    if(iter  == nil) {
        iter = leaf;
    }

    NSString *string = nil;
    NSString *ret = @"";

    do {
        BOOL objectIsValid = [(string = [iter objectForKey:@"T"]) isKindOfClass:[NSString class]];

        if(objectIsValid) {
            ret = [[NSString stringWithFormat:@"%@.",string] stringByAppendingString:ret];
        }
        temp = [iter objectForKey:@"Parent"];

        if(temp == nil) {
            break;
        }
        iter = temp;
    } while(YES);

    if([ret length]>0) {
        ret = [ret substringToIndex:[ret length]-1];
    }
    return ret;
}

- (NSString *)getSetAppearanceStreamFromLeaf:(MRGPDFKitDictionary *)leaf
{
    MRGPDFKitDictionary *ap = nil;

    if((ap = [leaf objectForKey:@"AP"])) {
        MRGPDFKitDictionary *n = nil;
        if([(n = [ap objectForKey:@"N"]) isKindOfClass:[MRGPDFKitDictionary class]]) {
            for(NSString *key in [n allKeys]) {
                if([key isEqualToString:@"Off"] == NO && [key isEqualToString:@"OFF"] == NO) {
                    MRGPDFKitStream *str = [n objectForKey:key];
                    if([str isKindOfClass:[MRGPDFKitStream class]]) {
                        NSData *dat = str.data;
                        if(str.dataFormat == CGPDFDataFormatRaw) {
                            return [[NSString alloc] initWithData:dat encoding:NSASCIIStringEncoding];
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (NSString *)getExportValueFrom:(MRGPDFKitDictionary *)leaf
{
    MRGPDFKitDictionary *ap = nil;

    if((ap = [leaf objectForKey:@"AP"])) {
        MRGPDFKitDictionary *n = nil;
        if([(n = [ap objectForKey:@"N"]) isKindOfClass:[MRGPDFKitDictionary class]]) {
            for(NSString *key in [n allKeys]) {
                if([key isEqualToString:@"Off"] == NO && [key isEqualToString:@"OFF"] == NO) {
                    return key;
                }
            }
        }
    }

    NSString *as = nil;
    if((as = [leaf objectForKey:@"AS"])) {
        return as;
    }
    return nil;
}

- (void)extractDefaultAppearance:(NSString *)defaultAppearance
{
    NSArray *components = [[[defaultAppearance componentsSeparatedByString:@" "] reverseObjectEnumerator] allObjects];

    if (components.count == 5) {
        _fontName = [components lastObject];

        for (NSUInteger i = 0; i < components.count; i++) {
            const NSString *value = components[i];
            if ([value isEqualToString:@"Tf"]) {
                _fontSize = [components[++i] floatValue];
            } else if ([value isEqualToString:@"g"]) {
                _fontColor = [components[++i] integerValue];
            } else if ([[value substringToIndex:1] isEqualToString:@"/"]) {
                _fontName = [value substringFromIndex:1];
            }
        }
    }
}

@end