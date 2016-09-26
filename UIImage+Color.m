//
//  UIImage+Color.m
//  App4Fest
//
//  Created by Dominik Vesely on 10/24/12.
//  Copyright (c) 2012 Ackee. All rights reserved.
//

#import "UIImage+Color.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIImage (Color)


- (UIImage *)cropImageTo:(CGRect)rect
{
    double (^rad)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };
    
    CGAffineTransform rectTransform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}


- (UIImage *)detectFaceAndCrop:(UIImage *)originalImage {
    
    NSLog(@"originalImage height - %f, width - %f", originalImage.size.height, originalImage.size.width);

    UIImage *realImage =
    [UIImage imageWithCGImage:[originalImage CGImage]
                        scale:(originalImage.scale / originalImage.scale)
                  orientation:(originalImage.imageOrientation)];
    
    int exifOrientation;
    switch (realImage.imageOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }
    
    NSLog(@"exifOrientation is %d",exifOrientation);
    
    NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyLow};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    //NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:originalImage.CGImage]];
    //NSLog(@"realImage Cgi height %zu and width %zu", CGImageGetHeight(realImage.CGImage),CGImageGetWidth(realImage.CGImage));
    //NSLog(@"real image scale is %f",realImage.scale);
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:originalImage.CGImage]
                                              options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];
    
    NSLog(@"Face count is %lu",(unsigned long)features.count);
    
    for(CIFaceFeature* faceFeature in features) {
        
        CGRect rect = [self boundsForImage:realImage fromBounds:faceFeature.bounds];
        NSLog(@"Crop rect %@", NSStringFromCGRect(rect));
        CGImageRef imageRef = CGImageCreateWithImageInRect([realImage CGImage],rect);
    
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        
        NSLog(@"croppedImage height - %f, width - %f", croppedImage.size.height, originalImage.size.width);
        
        CGImageRelease(imageRef);
        
        return originalImage;
    }
    
    return originalImage;
}


- (CGRect) boundsForImage:(UIImage *) image fromBounds:(CGRect) originalBounds{
    
    CGPoint convertedOrigin = [self pointForImage:image fromPoint:originalBounds.origin];;
    CGSize convertedSize = [self sizeForImage:image fromSize:originalBounds.size];
    
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            convertedOrigin.y -= convertedSize.height;
            break;
        case UIImageOrientationDown:
            convertedOrigin.x -= convertedSize.width;
            break;
        case UIImageOrientationLeft:
            convertedOrigin.x -= convertedSize.width;
            convertedOrigin.y -= convertedSize.height;
        case UIImageOrientationRight:
            break;
        case UIImageOrientationUpMirrored:
            convertedOrigin.y -= convertedSize.height;
            convertedOrigin.x -= convertedSize.width;
            break;
        case UIImageOrientationDownMirrored:
            break;
        case UIImageOrientationLeftMirrored:
            convertedOrigin.x -= convertedSize.width;
            convertedOrigin.y += convertedSize.height;
        case UIImageOrientationRightMirrored:
            convertedOrigin.y -= convertedSize.height;
            break;
        default:
            break;
    }
    
    return CGRectMake(convertedOrigin.x, convertedOrigin.y,
                      convertedSize.width, convertedSize.height);
}

- (CGSize) sizeForImage:(UIImage *) image fromSize:(CGSize) originalSize{
    CGSize convertedSize;
    
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            convertedSize.width = originalSize.width;
            convertedSize.height = originalSize.height;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            convertedSize.width = originalSize.height;
            convertedSize.height = originalSize.width;
            break;
        default:
            break;
    }
    return convertedSize;
}

- (CGPoint) pointForImage:(UIImage*) image fromPoint:(CGPoint) originalPoint {
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGPoint convertedPoint;
    
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            
            
            break;
        case UIImageOrientationDown:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeft:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        case UIImageOrientationRight:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationUpMirrored:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            break;
        case UIImageOrientationDownMirrored:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeftMirrored:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationRightMirrored:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        default:
            break;
    }
    return convertedPoint;
}


+ (UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    //convert to uncompressed jpg to remove any alpha channels
    //this is a necessary first step when processing images that already have transparency
    image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    CGImageRef rawImageRef=image.CGImage;
    //RGB color range to mask (make transparent)  R-Low, R-High, G-Low, G-High, B-Low, B-High
    //const double colorMasking[6] = {245, 255, 245, 255, 245, 255};
    //const double colorMasking[6] = {4, 70, 35, 60, 200, 245};
    CGFloat colorMasking[6] =  {245, 255, 245, 255, 245, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    
    //iPhone translation
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}



+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)combineBigImage:(UIImage *)bigImage withSmallImage:(UIImage *)smallImage {
    
    CGSize finalSize = [bigImage size];
    //CGSize hatSize = [hatImage size];
    UIGraphicsBeginImageContext(finalSize);
    [bigImage drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
    [smallImage drawInRect:CGRectMake(150,51,92,123)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
                         
    return newImage;
}


@end
