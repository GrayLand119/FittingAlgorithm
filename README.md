# FittingAlgorithm

使用OpenCV 进行线性拟合测试

直线使用

```objc
fitLine( InputArray points, OutputArray line, int distType,
                           double param, double reps, double aeps );
```
曲线使用最小二乘法

OpenCV库太大没有传上来.. 想跑起Demo需要自己去官网下载Opencv2.framework, 然后添加到工程中

![Demo](https://github.com/GrayLand119/FittingAlgorithm/blob/master/FitLineTest.gif)
![Curve](https://github.com/GrayLand119/FittingAlgorithm/blob/master/FitLineTest2.gif)
