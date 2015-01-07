//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitFieldSignature.h"
#import "UIView+MCLayout.h"

@interface MRGPDFKitFieldSignature ()

@property (nonatomic) UIImageView *signatureView;

@end

@implementation MRGPDFKitFieldSignature

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self != nil) {
        _signatureView = [UIImageView new];
        _signatureView.backgroundColor = [UIColor redColor];
        [self addSubview:_signatureView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.signatureView mc_setPosition:MCViewPositionFitHeight | MCViewPositionFitWidth];
}

//------------------------------------------------------------------------------
#pragma mark Getter & Setter
//------------------------------------------------------------------------------

- (UIImage *)signature
{
    return self.signatureView.image;
}

- (void)setSignature:(UIImage *)signature
{
    self.signatureView.image = signature;
}


@end