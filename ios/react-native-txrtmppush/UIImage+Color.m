//
//  UIImage+Color.m
//  TXLVffmpeg
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 dragontrail. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    //VIDEO_RESOLUTION_TYPE_360_640
    CGRect rect = CGRectMake(0, 0, 360, 640);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
