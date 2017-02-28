//
//  ViewController.m
//  FittingAlgorithm
//
//  Created by GrayLand on 17/2/28.
//  Copyright © 2017年 GrayLand. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+CVTransform.h"


using namespace cv;

@interface ViewController ()

@property (nonatomic, strong) UIImageView *originImgView;
@property (nonatomic, strong) UIImageView *resultImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UIImage *image = [UIImage imageNamed:@"lena.jpg"];
    
    CGFloat viewHeight = (SCREEN_HEIGHT - 20) / 2;
    
    _originImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, viewHeight, viewHeight)];
    [self.view addSubview:_originImgView];
    
    _resultImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20 + viewHeight, viewHeight, viewHeight)];
//    _resultImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_resultImgView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    Mat originImg = [self genCommonImage];
    Mat resultImg = [self genCommonImage];
    
    /*===============================================================
     线性拟合测试
     ===============================================================*/
    // 产生随机点
    NSMutableArray *arrayX = [NSMutableArray array];
    NSMutableArray *arrayY = [NSMutableArray array];
    for( NSUInteger x = 10; x < 600; x += 10 ) {
        // f(y) = x + random(k)
        [arrayX addObject:@(x)];
        NSUInteger random = arc4random_uniform(10);
        NSUInteger y = x + ((arc4random_uniform(1)==1) ? random : -random);
        [arrayY addObject:@(y)];
        
//        circle(img, cvPoint((int)x, (int)y), 3, cvScalar(0,255,0), FILLED);
    }
    
    int insertNum = 3;
    
    for (int i = 0; i < insertNum; i++) {
        // random pick a point
        int randomIndex = arc4random_uniform(arrayY.count - 15) + 13;
        int iRandomPick = [[arrayX objectAtIndex:randomIndex] integerValue];
        int iK = iRandomPick;
        NSUInteger random = arc4random_uniform(50) + 15;
        iRandomPick += ((arc4random_uniform(1)==1) ? random : -random);
        [arrayX replaceObjectAtIndex:randomIndex withObject:@(iRandomPick)];
        // f(y)' = -x' + x
        
        NSUInteger iY = -iRandomPick + 2 * iK;
        [arrayY replaceObjectAtIndex:randomIndex withObject:@(iY)];
        
        circle(originImg, cvPoint((int)iRandomPick, (int)iY), 3, cvScalar(255,0,0), FILLED);
    }
    
    
    // Original
    [self drawLineInImage:originImg withXArray:arrayX yArray:arrayY];
    
    putText(originImg, "Simulator data", cvPoint(100,25), FONT_HERSHEY_SIMPLEX, 1, Scalar(0,255,0));

    _originImgView.image = [UIImage imageWithCVMat:originImg];
    
    [self drawLineInImage:resultImg withXArray:arrayX yArray:arrayY];
    
    // Result
    putText(resultImg, "Result", cvPoint(100,25), FONT_HERSHEY_SIMPLEX, 1, Scalar(0,255,0));
    
    _resultImgView.image = [UIImage imageWithCVMat:resultImg];
    
    if(YES)// fit line test
    {
        
    }
}

- (void)drawLineInImage:(Mat)image withXArray:(NSArray *)xArray yArray:(NSArray *)yArray {
    
    for (int i = 0; i < xArray.count - 1; i++) {
        line(image,
             cvPoint([xArray[i] intValue], [yArray[i] intValue]),
             cvPoint([xArray[i + 1] intValue], [yArray[i + 1] intValue]),
             cvScalar(0,255,0),
             1);
    }
}

- (Mat)genCommonImage {
    
    Mat mat;
    mat.create(600, 600, CV_8UC3);
    mat = Scalar::all(0);
    
    return mat;
}

- (void)testCannyWithImage:(UIImage *)image {
    
    Mat cvImg = [image toMat];
    Mat cvImgResult;
    
    cvtColor(cvImg, cvImgResult, CV_BGR2GRAY);
    
    blur( cvImgResult, cvImg, cvSize(3,3));
    
    Canny(cvImg, cvImgResult, 60, 180);
    
    image = [UIImage imageWithCVMat:cvImgResult];
    
    _resultImgView.image = image;
}


@end
