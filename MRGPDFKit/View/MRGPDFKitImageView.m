//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitImageView.h"
#import "MRGPDFKitDocument.h"
#import "UIView+MCLayout.h"

@interface MRGPDFKitImageView ()

@property (nonatomic) UIImageView *pdfView;
@property (nonatomic) MRGPDFKitDocument *nativeDocument;

@end

@implementation MRGPDFKitImageView

- (instancetype)initWithFrame:(CGRect)frame document:(MRGPDFKitDocument *)document
{
    self = [super initWithFrame:frame];
    if (self) {
        _nativeDocument = (MRGPDFKitDocument *)document;
        _pdfView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview: _pdfView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.pdfView mc_setPosition:MCViewPositionFitHeight|MCViewPositionFitWidth];
}

- (void)displayPage:(NSInteger)page
{
    self.pdfView.image = [self.nativeDocument imageFromPage:page width:self.bounds.size.width];
}

@end