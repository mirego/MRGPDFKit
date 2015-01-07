//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitWidget.h"

@implementation MRGPDFKitWidget

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil) {
        _baseFrame = frame;
    }
    return self;
}


- (void)updateWithZoom:(CGFloat)zoom
{
    self.frame = CGRectMake(_baseFrame.origin.x*zoom,_baseFrame.origin.y*zoom,_baseFrame.size.width*zoom,_baseFrame.size.height*zoom);
}


- (void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect
{
}

//------------------------------------------------------------------------------
#pragma mark - Getter & Setter
//------------------------------------------------------------------------------

- (void)setValue:(NSString *)value
{
}

- (NSString*)value
{
    return nil;
}

- (void)setOptions:(NSArray *)options
{
}

- (NSArray *)options
{
    return nil;
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (void)refresh
{
    [self setNeedsLayout];
}

@end