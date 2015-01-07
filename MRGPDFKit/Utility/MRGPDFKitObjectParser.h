//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MRGPDFKitObjectParser : NSObject<NSFastEnumeration>

- (id)initWithString:(NSString *)string;
+ (MRGPDFKitObjectParser *)parserWithString:(NSString *)string;

@end