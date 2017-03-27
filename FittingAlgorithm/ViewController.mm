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
using namespace std;

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
    NSTimer *ttt = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(doTest) userInfo:nil repeats:YES];
    [ttt fire];
    
    {
//        vector<Point2f> vec;
//        int x[]={50,100,150,200,250,300,350,400,450,500,550,600,650,700,750};
//        int y[]={428,454,480,506,532,458,384,210,636,662,688,778,504,430,456};
//        
//        for (int i=0;i<15;i++) {
//            vec.push_back(Point2f(x[i],y[i]));
//        }
//        
//        int level = 9;
//        float index[level];
////        fittingCurve(vec,index,level);
//        fittingCurve2(vec, level, index);
////        fittingCurve2(<#vector<Point> &vec#>, <#int times#>, <#float *p#>)
//        for (int i=0;i<level;++i) {
//            cout<<index[i]<<endl;
//        }
    }
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
        NSUInteger random = arc4random_uniform(15);
        NSUInteger y = 100 + ((arc4random_uniform(2)==1) ? random : -random);
        [arrayY addObject:@(y)];
        
        //        circle(img, cvPoint((int)x, (int)y), 3, cvScalar(0,255,0), FILLED);
    }
    
    int insertNum = 5 + arc4random_uniform(3);
    
    for (int i = 0; i < insertNum; i++) {
        // random pick a point
        int randomIndex = arc4random_uniform(arrayY.count - 15) + 13;
        int iRandomPick = [[arrayX objectAtIndex:randomIndex] integerValue];
        int iK = iRandomPick;
        NSUInteger random = arc4random_uniform(15) + 5;
        iRandomPick += ((arc4random_uniform(2)==1) ? random : -random);
        [arrayX replaceObjectAtIndex:randomIndex withObject:@(iRandomPick)];
        // f(y)' = -x' + x
        
//        NSUInteger iY = -iRandomPick + 2 * iK;
        NSUInteger random2 = arc4random_uniform(45) + 23;
        NSUInteger iY = [[arrayY objectAtIndex:randomIndex] integerValue] + ((arc4random_uniform(2)==1)? random2 : -random2);
        [arrayY replaceObjectAtIndex:randomIndex withObject:@(iY)];
        
        circle(originImg, cvPoint((int)iRandomPick, (int)iY), 3, cvScalar(255,0,0), FILLED);
    }
    
    
    
    // Original
    [self drawLineInImage:originImg withXArray:arrayX yArray:arrayY];
    putText(originImg, "Simulator data", cvPoint(100,25), FONT_HERSHEY_SIMPLEX, 1, Scalar(0,255,0));
    
    // Result
    [self drawLineInImage:resultImg withXArray:arrayX yArray:arrayY];
    putText(resultImg, "Result", cvPoint(100,25), FONT_HERSHEY_SIMPLEX, 1, Scalar(0,255,0));
    
    
    /*===============================================================
     线性拟合
     ===============================================================*/
    if(NO)// For test
    {
        // 直线
        Mat opt = [self genCommonImage];
        
        std::vector<Point2f> points;
        
        for (int i = 0; i < arrayX.count; i++) {
            points.push_back(Point2f([arrayX[i] floatValue], [arrayY[i] floatValue]));
        }
        
        Vec4f line;
        
        fitLine(Mat(points), line, CV_DIST_L1, 0, 0.01, 0.01);
    
        
        std::cout << "line: (" << line[0] << "," << line[1] << ")(" << line[2] << "," << line[3] << ")\n";

        // vx, vy, x0, y0
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
    else
    {
        // 曲线
//        Mat opt = [self genCommonImage];
        
        std::vector<Point2f> points;
        
        for (int i = 0; i < arrayX.count; i++) {
            points.push_back(Point2f([arrayX[i] floatValue], [arrayY[i] floatValue]));
        }
        
        for (int i = 0; i < arrayX.count; i++) {
            points.push_back(Point2f([arrayX[i] floatValue], [arrayY[i] floatValue]));
        }
        
        int level = 6;// 运算阶级
        float index[level];
        
        fittingCurve2(points, level, index);
        for (int i=0;i<level;++i) {
            cout<<index[i]<<endl;
        }
        for (int i = 0; i < 600; i++) {
            
            Mat_<Vec3b> m2 = resultImg;
            
            double y = 0;
            
            for (int j=0;j<level;++j) {
                y += index[j]*pow(i, j);
            }
            
            m2(y,i) = Vec3b(255,0,0);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _originImgView.image = [UIImage imageWithCVMat:originImg];
        _resultImgView.image = [UIImage imageWithCVMat:resultImg];
    });
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

void fittingCurve(vector<CvPoint2D64f> vec,double *index,int len)
{
    double *px=new double [vec.size()];
    double *py=new double [len*vec.size()];
    int i=0;
    for(vector<CvPoint2D64f>::iterator itr=vec.begin();itr!=vec.end();++itr)
    {
        px[i]=(*itr).x;
        int j=0;
        while (j<len)
        {
            py[len*i+j]=pow((*itr).y,double(j));
            j++;
        }
        i++;
    }
    
    CvMat xMat=cvMat((int)vec.size(),1,CV_64FC1,px);
    CvMat yMat=cvMat((int)vec.size(),len,CV_64FC1,py);
    CvMat *yTransposedMat=cvCreateMat(yMat.cols,yMat.rows,CV_64FC1);
    cvTranspose(&yMat,yTransposedMat);//求yMat的转置
    
    double *a=new double [len*len];
    for(int i=0;i<len*len;++i)
    {
        a[i]=0;
    }
    CvMat invMat1=cvMat(len,len,CV_64FC1,a);
    cvGEMM(yTransposedMat,&yMat,1,NULL,0,&invMat1,0);//yMat的转置与yMat矩阵相乘
    cvInvert(&invMat1,&invMat1,0);//求invMat的逆矩阵
    
    double *b=new double [len];
    for(int i=0;i<len;++i)
    {
        b[i]=0;
    }
    CvMat invMat2=cvMat(len,1,CV_64FC1,b);
    cvGEMM(yTransposedMat,&xMat,1,NULL,0,&invMat2,0);//求yMat的转置矩阵与xMat矩阵相乘
    
    
    cvGEMM(yTransposedMat,&xMat,1,NULL,0,&invMat2,0);//求yTransposedMat矩阵与xMat 矩阵的乘积
    CvMat indexMat=cvMat(len,1,CV_64FC1,index);
    cvGEMM(&invMat1,&invMat2,1,NULL,0,&indexMat,0);
    
    
    cvReleaseMat(&yTransposedMat);
    delete [] a;
    delete [] b;
    delete [] px;
    delete [] py;
}

bool fittingCurve2(vector<Point2f> &vec,int times,float *p) //输入点，次数，输出曲线参数
{
    float *py = new float[vec.size()];
    float *px = new float[times*vec.size()];
    int i = 0;
    Point2f *P = &vec[0];
    for(vector<Point2f>::iterator itr = vec.begin();itr!=vec.end();++itr)
    {
        py[i] = (*itr).y;
        int j=0;
        while (j<times)
        {
            px[times*i+j] = pow(((*itr).x),float(j));
            j++;
        }
        i++;
    }
    Mat X = Mat(vec.size(),times,CV_32FC1,px);
    float* Xp = &(X.at<float>(0));
    Mat X_T;
    transpose(X,X_T);
    Mat Y = Mat(vec.size(),1,CV_32FC1,py);
    Mat para = ((X_T*X).inv())*X_T*Y;
    for (int s = 0; s<times;s++)
    {
        p[s] = para.at<float>(s);
    }
    delete[] px;
    delete[] py;
    return true;
}

bool LeastSquare(const std::vector<double>& x_value, const std::vector<double>& y_value, int M, std::vector<double>& a_value)
{
//    assert(x_value.size() == y_value.size());
//    assert(a_value.size() == M);
//    
//    double *matrix = new double[M * M];
//    double *b= new double[M];
//    
//    std::vector<double> x_m(x_value.size(), 1.0);
//    std::vector<double> y_i(y_value.size(), 0.0);
//    for(int i = 0; i < M; i++)
//    {
//        matrix[ARR_INDEX(0, i, M)] = std::accumulate(x_m.begin(), x_m.end(), 0.0);
//        for(int j = 0; j < static_cast<int>(y_value.size()); j++)
//        {
//            y_i[j] = x_m[j] * y_value[j];
//        }
//        b[i] = std::accumulate(y_i.begin(), y_i.end(), 0.0);
//        for(int k = 0; k < static_cast<int>(x_m.size()); k++)
//        {
//            x_m[k] *= x_value[k];
//        }
//    }
//    for(int row = 1; row < M; row++)
//    {
//        for(int i = 0; i < M - 1; i++)
//        {
//            matrix[ARR_INDEX(row, i, M)] = matrix[ARR_INDEX(row - 1, i + 1, M)];
//        }
//        matrix[ARR_INDEX(row, M - 1, M)] = std::accumulate(x_m.begin(), x_m.end(), 0.0);
//        for(int k = 0; k < static_cast<int>(x_m.size()); k++)
//        {
//            x_m[k] *= x_value[k];
//        }
//    }
//    
//    GuassEquation equation(M, matrix, b);
//    delete[] matrix;
//    delete[] b;
//    
//    return equation.Resolve(a_value);
    return 0;
 }

@end
