//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/9/5.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MotionBlurFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nullable) NSNumber *inputRadius;
@property (nonatomic, strong, nullable) NSNumber *inputAngle;
@property (nonatomic, strong, nullable) NSNumber *numSamples;

@end

NS_ASSUME_NONNULL_END
