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

    
    // repeat test
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(doTest) userInfo:nil repeats:YES];

}

- (void)doTest {
    
    static Mat originImg = [self genCommonImage];
    static Mat resultImg = [self genCommonImage];
    
    originImg = Scalar::all(0);
    resultImg = Scalar::all(0);
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
    
    int insertNum = 2 + arc4random_uniform(3);
    
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
    
    // Result
    [self drawLineInImage:resultImg withXArray:arrayX yArray:arrayY];
    putText(resultImg, "Result", cvPoint(100,25), FONT_HERSHEY_SIMPLEX, 1, Scalar(0,255,0));
    
    if(YES)// fit line test
    {
        Mat opt = [self genCommonImage];
        
        std::vector<Point2f> points;
        
        for (int i = 0; i < arrayX.count; i++) {
            points.push_back(Point2f([arrayX[i] floatValue], [arrayY[i] floatValue]));
        }
        //        Mat dest = Mat(points, <#int _type#>);
        Vec4f line;
        
        fitLine(Mat(points), line, CV_DIST_L1, 0, 0.01, 0.01);
        
        std::cout << "line: (" << line[0] << "," << line[1] << ")(" << line[2] << "," << line[3] << ")\n";
        
        //        vx, vy, x0, y0
        float vx = line[0];
        float vy = line[1];
        float X0 = line[2];
        float Y0 = line[3];
        // y = kx + b
        double k = vy / vx;
        double b = Y0 - k * X0;
        
        // Y0 = vy/vx * X0 + b
        // Y1 = vy/vx * X1 + b
        // Y1 - Y0 = vy/vx * (X1 - X0)
        // Y1 - Y0 = k * (X1 - X0)
        // dy = vy/vx * dx
        
        
        CvPoint p1 = cvPoint(10, 10 * k + b);
        CvPoint p2 = cvPoint(590, 590 * k + b);
        
        cv::line(resultImg, p1, p2, Scalar(255,0,0));
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _originImgView.image = [UIImage imageWithCVMat:originImg];
        _resultImgView.image = [UIImage imageWithCVMat:resultImg];
    });
    
}
- (void)fitLineWithXArray:(NSArray *)xArray yArray:(NSArray *)yArray {
    
    //TODO: 用最小二乘法来实现拟合
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
//    mat = Scalar::all(0);
    
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
