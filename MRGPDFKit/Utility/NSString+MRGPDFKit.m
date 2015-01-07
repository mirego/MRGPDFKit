//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "NSString+MRGPDFKit.h"


@implementation NSString (MRGPDFKit)

-(BOOL)isName
{
    return [objc_getAssociatedObject(self, @selector(isName)) isKindOfClass:[NSNull class]];
}

-(void)setAsName:(BOOL)isName
{
    if(isName) {
        objc_setAssociatedObject(self, @selector(isName), [NSNull null], OBJC_ASSOCIATION_ASSIGN);
    } else {
        objc_setAssociatedObject(self, @selector(isName), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (CGSize)sizeWithFont:(UIFont *)font thatFitsMaxSize:(CGSize)maxSize
{
    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName: font}
                              context:nil].size;
}

@end