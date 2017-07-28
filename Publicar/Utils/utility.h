//
//  utility.h
//  Leal
//
//  Created by KUBO on 1/7/16.
//  Copyright © 2016 KUBO. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface utility : NSObject

+ (NSString *) md5:(NSString *) input;

+(BOOL)consultarGpsActivo;

+(NSString *)decimalNumberFormatDoubleTotales:(double)decimalNumber;

+(NSString *)Base64ToString:(UIImage *)image;

+ (BOOL)validateEmailWithString:(NSString*)checkString;

+(BOOL)isPasswordStrong:(NSString *)password;

+(int)valueUpFrameLogin;

+(int)valueUpFrameRegistro;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height ;

+(BOOL)onlyNumbers:(NSString *)phone;

+ (UIImage *) scaleAndRotateImage: (UIImage *)image;

+(BOOL)verifyEmpty:(UIView *)viewSend;

+(UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

@end
