//
//  XFQrcodeScanFocusBoxDynamicShapeLayer.m
//  XFQrcodeScanDemo
//
//  Created by orangeskiller on 14-9-3.
//  Copyright (c) 2014年 orangeskiller. All rights reserved.
//

#import "XFQrcodeScanFocusBoxDynamicShapeLayer.h"
// 屏幕高度
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
@implementation XFQrcodeScanFocusBoxDynamicShapeLayer

- (instancetype)initWithView:(UIView *)view
{
    if ([super init]) {
        self.frame = view.frame;
        
    }
    return self;
}

- (void)startBoxAnimation
{
    CGRect aRect = CGRectMake(30,SCREEN_HEIGHT/2-72/2, SCREEN_WIDTH-30*2, 72);
    CGRect bRect = CGRectMake(70, SCREEN_HEIGHT/2-(SCREEN_WIDTH-70*2)/2, SCREEN_WIDTH-70*2, SCREEN_WIDTH-70*2);
    
    CGMutablePathRef aPath = CGPathCreateMutable();
    CGPathAddRect(aPath, NULL, aRect);
    
    CGMutablePathRef bPath = CGPathCreateMutable();
    CGPathAddRect(bPath, NULL, bRect);
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 1.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = (__bridge_transfer id)aPath;
    animation.toValue = (__bridge_transfer id)bPath;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    
    [self addAnimation:animation forKey:@"path_animation"];
}

- (void)fucosToPath:(CGPathRef)path
{
    CGPathRef bPath = CGPathCreateCopy(path);
    [self removeAnimationForKey:@"path_animation"];
    
    CALayer* presentLayer = self.presentationLayer;
    id currentPath = [presentLayer valueForKeyPath:@"path"];
    self.path = (__bridge CGPathRef)(currentPath);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = currentPath;
    animation.toValue = (__bridge_transfer id)bPath;
    [self addAnimation:animation forKey:@"qrpath"];
    self.path = bPath;
    self.backgroundColor = [UIColor blackColor].CGColor;
    self.opacity = 0.6;
}

+ (NSArray *)translatePoints:(NSArray *)points fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer
{
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    for (NSDictionary *point in points) {
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        CGPoint translatedPoint = [fromLayer convertPoint:pointValue toLayer:toLayer];
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}

@end
