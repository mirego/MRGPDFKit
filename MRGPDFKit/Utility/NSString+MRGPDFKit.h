//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (MRGPDFKit)

- (BOOL)isName;
- (void)setAsName:(BOOL)isName;
- (CGSize)sizeWithFont:(UIFont *)font thatFitsMaxSize:(CGSize)maxSize;

@end