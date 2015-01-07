//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRGPDFKitDocument;

@interface MRGPDFKitImageView : UIView

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame document:(MRGPDFKitDocument *)document;

- (void)displayPage:(NSInteger)page;

@end