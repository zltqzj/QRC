//
//  UIBezierPath+QrcodeScanFocusBoxPath.h
//  XFQrcodeScanDemo
//
//  Created by orangeskiller on 14-9-3.
//  Copyright (c) 2014年 orangeskiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (QrcodeScanFocusBoxPath)

+ (UIBezierPath *)createPathFromPoints:(NSArray *)points;

@end
