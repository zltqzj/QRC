//
//  UIBezierPath+QrcodeScanFocusBoxPath.m
//  XFQrcodeScanDemo
//
//  Created by orangeskiller on 14-9-3.
//  Copyright (c) 2014年 orangeskiller. All rights reserved.
//

#import "UIBezierPath+QrcodeScanFocusBoxPath.h"

@implementation UIBezierPath (QrcodeScanFocusBoxPath)

+ (UIBezierPath *)createPathFromPoints:(NSArray *)points
{
    
    UIBezierPath *path = [UIBezierPath new];
    
    [path moveToPoint:[[points firstObject] CGPointValue]];
    [path addLineToPoint:[[points lastObject] CGPointValue]];
    [path addLineToPoint:[points[2] CGPointValue]];
    [path addLineToPoint:[points[1] CGPointValue]];
    [path addLineToPoint:[[points firstObject] CGPointValue]];
    
    return path;
}

@end
