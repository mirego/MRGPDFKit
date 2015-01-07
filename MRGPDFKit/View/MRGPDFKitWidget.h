//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PDFView;


@interface MRGPDFKitWidget : UIView

@property (nonatomic) NSString *value;
@property (nonatomic) NSArray *options;
@property (nonatomic, readonly) CGRect baseFrame;
@property (nonatomic, weak) PDFView *parentView;

-(void)refresh;

@end