//
//  XFViewController.m
//  XFQrcodeScanDemo
//
//  Created by zkr on 14-9-3.
//  Copyright (c) 2015年 zkr. All rights reserved.
//

#import "XFViewController.h"
#import "UIBezierPath+QrcodeScanFocusBoxPath.h"
#import "XFQrcodeScanFocusBoxDynamicShapeLayer.h"

@interface XFViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) XFQrcodeScanFocusBoxDynamicShapeLayer *shapeLayer;
@property (nonatomic, strong) NSString* content;
@end

@implementation XFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) { // 判断是否支持自动对焦
        // [captureDevice isFlashAvailable];// 判断是否支持闪光灯
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    if ( [captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        [captureMetadataOutput setMetadataObjectTypes: @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode39Mod43Code]];
        
        
    }
    else{
        NSLog(@"设备不支持识别");
        return;
    }

    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    
    captureMetadataOutput.rectOfInterest = self.view.layer.bounds;
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    _shapeLayer = [[XFQrcodeScanFocusBoxDynamicShapeLayer alloc] initWithView:self.view];
    _shapeLayer.strokeColor = [[[UIColor whiteColor] colorWithAlphaComponent:1.0] CGColor];
    _shapeLayer.lineWidth = 2.0;
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    CGMutablePathRef fillPath = CGPathCreateMutable();
    CGPathAddRect(fillPath, NULL, CGRectMake(32.5, 249, 252, 72));
    _shapeLayer.path = fillPath;
    [self.view.layer addSublayer:_shapeLayer];
    [_shapeLayer startBoxAnimation];
}



-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //  NSLog(@"%@", metadataObj.stringValue);
        NSString* codeType = [metadataObj type];
        _content =metadataObj.stringValue;
        
        
        if ([codeType isEqualToString:AVMetadataObjectTypeQRCode]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_captureSession stopRunning];
                
                AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObj];
                
                NSArray *translatedCorners = [XFQrcodeScanFocusBoxDynamicShapeLayer translatePoints:transformed.corners
                                                                                          fromLayer:_videoPreviewLayer toLayer:_shapeLayer ];
                CGPathRef path = [[UIBezierPath createPathFromPoints:translatedCorners] CGPath];
                [_shapeLayer fucosToPath:path];
                
                if ([[self judgeContent:_content] isEqualToString:@"1"]) {
                    // http
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"在浏览器中打开此链接"
                                                                    message:_content
                                                                   delegate:nil
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定", nil];
                    alert.delegate = self;
                    alert.tag=1;
                    [alert show];
                }
                else if ([[self judgeContent:_content] isEqualToString:@"2"]){
                    
                    
                    // ssid
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"是否将内容拷贝到剪贴板"
                                                                    message:_content
                                                                   delegate:nil
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定", nil];
                    
                    
                    alert.delegate = self;
                    alert.tag=2;
                    [alert show];
                    
                }
                else if ([[self judgeContent:_content] isEqualToString:@"2"]){
                    // wifi
                    NSArray* arr = [_content componentsSeparatedByString:@";"];
                    __block NSString* name = @"";
                    __block  NSString* password = @"";
                    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj hasPrefix:@"P:"]) {
                            password = [[obj componentsSeparatedByString:@":"] lastObject];
                            password = [password stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        }
                        if ([obj hasPrefix:@"S:"]) {
                            name  = [[obj componentsSeparatedByString:@":"] lastObject];
                        }
                    }];
                    
                    NSLog(@"%@",password);
                    _content = [NSString stringWithFormat:@"wifi名称:%@,密码:%@",name,password];
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"wifi"
                                                                    message:_content
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定", nil];
                    alert.tag =6;
                    [alert show];
                    
                }
                
            });
            
        }
        else if ([codeType isEqualToString:AVMetadataObjectTypeEAN13Code]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [_captureSession stopRunning];
                
                AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObj];
                
                NSArray *translatedCorners = [XFQrcodeScanFocusBoxDynamicShapeLayer translatePoints:transformed.corners
                                                                                          fromLayer:_videoPreviewLayer toLayer:_shapeLayer ];
                CGPathRef path = [[UIBezierPath createPathFromPoints:translatedCorners] CGPath];
                [_shapeLayer fucosToPath:path];
                
                NSLog(@"商品条形码");
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"商品条形码"
                                                                message:_content
                                                               delegate:nil
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
                alert.tag = 3;
                alert.delegate  = self;
                [alert show];
                
            });
            
            
        }
        else if ([codeType isEqualToString:AVMetadataObjectTypePDF417Code]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [_captureSession stopRunning];
                
                AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObj];
                
                NSArray *translatedCorners = [XFQrcodeScanFocusBoxDynamicShapeLayer translatePoints:transformed.corners
                                                                                          fromLayer:_videoPreviewLayer toLayer:_shapeLayer ];
                CGPathRef path = [[UIBezierPath createPathFromPoints:translatedCorners] CGPath];
                [_shapeLayer fucosToPath:path];
                
                NSLog(@"pdf417");
                NSLog(@"%@",_content);
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"pdf417码"
                                                                 message:_content
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"确定", nil];
                alert.tag = 4;
                //  PDF417 is a stacked linear barcode symbol format used in a variety of applications, primarily transport, identification cards, and inventory management.
                [alert show];
            });
            
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_captureSession stopRunning];
                
                AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObj];
                
                NSArray *translatedCorners = [XFQrcodeScanFocusBoxDynamicShapeLayer translatePoints:transformed.corners
                                                                                          fromLayer:_videoPreviewLayer toLayer:_shapeLayer ];
                CGPathRef path = [[UIBezierPath createPathFromPoints:translatedCorners] CGPath];
                [_shapeLayer fucosToPath:path];
                
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"内容"
                                                                message:_content
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
                alert.tag = 5;
                [alert show];
            });
            
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag ==1 && buttonIndex ==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_content]];
    }
    if (alertView.tag ==2 && buttonIndex ==1) {
        
    }
}

-(NSString*)judgeContent:(NSString*)str{
    
    //判断是否包含 头'http:'
    NSString *regex = @"http+:[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    
    //判断是否包含 头'ssid:'
    NSString *ssid = @"ssid+:[^\\s]*";;
    NSPredicate *ssidPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ssid];
    
    if ([predicate evaluateWithObject:str]) {
        return @"1";
    }
    else if ([ssidPre evaluateWithObject:str]){
        return @"2";
    }
    else if([str hasPrefix:@"WIFI"]){
        return @"3";
    }
    else{
        return str;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
