//
//  XFQrcodeScanFocusBoxDynamicShapeLayer.h
//  XFQrcodeScanDemo
//
//  Created by orangeskiller on 14-9-3.
//  Copyright (c) 2014年 orangeskiller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface XFQrcodeScanFocusBoxDynamicShapeLayer : CAShapeLayer

- (instancetype)initWithView:(UIView *)view;
- (void)startBoxAnimation;
- (void)fucosToPath:(CGPathRef)path;

+ (NSArray *)translatePoints:(NSArray *)points fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer;

@end
