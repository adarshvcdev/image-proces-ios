//
//  UIImage+Color.h
//  App4Fest
//
//  Created by Dominik Vesely on 10/24/12.
//  Copyright (c) 2012 Ackee. All rights reserved.
//

#import <UIKit/UIKit.h>
#define COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define COLOR_PART_BLUE(color)   ( (color)        & 0xff)

@interface UIImage (Color)

- (UIImage *)cropImageTo:(CGRect)rect;
- (UIImage *)detectFaceAndCrop:(UIImage *)originalImage;
+ (UIImage *)changeWhiteColorTransparent:(UIImage *)image;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
+ (UIImage *)combineBigImage:(UIImage *)bigImage withSmallImage:(UIImage *)smallImage;

@end
