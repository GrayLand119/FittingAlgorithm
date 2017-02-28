//
//  UIImage+CVTransform.h
//  FittingAlgorithm
//
//  Created by GrayLand on 17/2/28.
//  Copyright © 2017年 GrayLand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CVTransform)

+ (UIImage *)imageWithCVMat:(cv::Mat)cvMat;

- (cv::Mat)toMat;

@end
