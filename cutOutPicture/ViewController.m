//
//  ViewController.m
//  cutOutPicture
//
//  Created by dengjy on 2017/5/30.
//  Copyright © 2017年 dengjy. All rights reserved.
//

#import "ViewController.h"

#define Screen_Width (self.view.frame.size.width)

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImageView *imagView;
@property (nonatomic,strong) UIImageView *coverImageView;
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,assign) BOOL isWidCouver;
@property (nonatomic,assign) BOOL isSmallImage;

@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;

@property (nonatomic,assign) CGFloat xScale;
@property (nonatomic,assign) CGFloat yScale;

@property (nonatomic,assign) CGFloat theHight;
@property (nonatomic,assign) CGFloat theWideth;
@property (nonatomic,assign) CGFloat offsetTheWideth;

@property (nonatomic,assign) CGFloat scaleMove;

@property (nonatomic,assign) CGFloat imageVinwWidth;
@property (nonatomic,assign) CGFloat imageVinwHeight;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _theHight = 200; //裁剪的高
    _theWideth = 200; //裁剪的宽
    
    
    _scaleMove = 1;//图片缩放比例，初始值为1，原图
    
    _offsetTheWideth = (self.view.frame.size.width- _theWideth)/2;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.center = self.view.center;
    self.scrollView = scrollView;
    //设置代理
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
    

    UIImage *image = [UIImage imageNamed:@"test.jpg"];

    
    self.image = image;
    
    
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    _width = width;
    _height = height;
    
    CGFloat xScale = width / self.view.frame.size.width;
    CGFloat yScale = height / _theHight;
    
    _xScale = xScale;
    _yScale = yScale;
    
    
    
    CGRect otherRect;
    
    if (xScale > yScale) {
        
        _isWidCouver = YES;
        
        CGFloat endW = width/yScale;
        CGFloat endH = height/yScale;
        CGFloat offsetY = 0;
        
        otherRect = CGRectMake(_offsetTheWideth,(self.view.frame.size.height-endH)/2+ offsetY, endW, endH);
        
        scrollView.contentSize = CGSizeMake(endW+_offsetTheWideth*2, scrollView.frame.size.height);
        
        scrollView.contentOffset = CGPointMake(_offsetTheWideth, 0);
        
        _imageVinwWidth = endW;
        _imageVinwHeight = endH;
        
        //设置放大缩小的倍数
        if (yScale > 1) {
            scrollView.maximumZoomScale = yScale;//最大的放大倍数
            scrollView.minimumZoomScale = 1;//最小可以缩小到几分之几
        }else{
            _isSmallImage = YES;
            scrollView.maximumZoomScale = 1;
            scrollView.minimumZoomScale = 1;
        }
        
    }else{
        
        CGFloat endW = width/xScale;
        CGFloat endH = height/xScale;
        CGFloat offsetY = (endH-_theHight)/2;
        
        
        otherRect = CGRectMake(_offsetTheWideth, (self.view.frame.size.height-endH)/2+offsetY, endW, endH);
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width+_offsetTheWideth*2, scrollView.frame.size.height+offsetY*2);
        
        scrollView.contentOffset = CGPointMake(_offsetTheWideth, 0);
        _imageVinwWidth = endW;
        _imageVinwHeight = endH;
        
        //设置放大缩小的倍数
        if (xScale > 1) {
            scrollView.maximumZoomScale = xScale;//最大的放大倍数
            scrollView.minimumZoomScale = 1;//最小可以缩小到几分之几
        }else{
            _isSmallImage = YES;
            scrollView.maximumZoomScale = 1;
            scrollView.minimumZoomScale = 1;
        }
        
        
    }
    
    //实例化一个UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:otherRect];
    imageView.image = image;
    self.imagView = imageView;
    
    [scrollView addSubview:imageView];


    [self setCropSize:CGSizeMake(_theWideth, _theHight)];

    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 20, 30, 30);
    [btn setTitle:@"切" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(coverTheImage) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    
    UIImageView *coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 20, _theWideth/2, _theHight/2)];
    
    coverImageView.layer.borderWidth = 1;
    coverImageView.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:coverImageView];
    self.coverImageView = coverImageView;
}
- (void)coverTheImage{
    
    CGRect coverRect ;
    
    if (_isWidCouver) {
        coverRect = CGRectMake(_scrollView.contentOffset.x*_yScale/_scaleMove, _scrollView.contentOffset.y*_yScale/_scaleMove, _theWideth*_yScale/_scaleMove, _height/_scaleMove);
    }else{
        coverRect = CGRectMake(_scrollView.contentOffset.x*_xScale/_scaleMove, _scrollView.contentOffset.y*_xScale/_scaleMove, _width*_theWideth/self.view.frame.size.width/_scaleMove, _theHight*_xScale/_scaleMove);
    }
    
    
    UIImage *covImage = [self coverImageWithRect:coverRect];
    self.coverImageView.image = covImage;
    
}
#pragma mark-UIScrollView方法缩小
//如果要实现放大缩小功能，必须实现这个2个方法
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    //返回需要放大缩小的UIView对象
    return _imagView;
    
}
//放大缩小完成之后会调用此代理方法
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    //scale放大或者缩小的系数
    
    if (_isWidCouver) {
        _scrollView.contentSize = CGSizeMake(_imageVinwWidth*scale+_offsetTheWideth*2, scrollView.frame.size.height+_theHight*scale-_theHight);
    }else{
        _scrollView.contentSize = CGSizeMake(_imageVinwWidth*scale+_offsetTheWideth*2, scrollView.frame.size.height+_imageVinwHeight*scale-_theHight);
    }

    _scaleMove = scale;
}
- (UIImage*)coverImageWithRect:(CGRect)rect{
    
    UIImage * imgeee = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([_image CGImage], rect)];
    
    return imgeee;

}
- (void)setCropSize:(CGSize)size{
    
    UIColor *backColor = [UIColor whiteColor];  //白色半透明覆盖层
    UIColor *lineColor = [UIColor orangeColor]; //裁剪线颜色
    CGFloat viewAlpha = 0.45;
    CGFloat lineWideth = 2; //裁剪框宽度
    
    CGFloat x = (CGRectGetWidth(self.view.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.view.bounds) - size.height) / 2;
    
    
    UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, y)];
    upView.backgroundColor = backColor;
    upView.alpha = viewAlpha;
    upView.userInteractionEnabled = NO;
    [self.view addSubview:upView];
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, y, x, size.height)];
    leftView.backgroundColor = backColor;
    leftView.alpha = viewAlpha;
    leftView.userInteractionEnabled = NO;
    [self.view addSubview:leftView];
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(x+size.width, y, x, size.height)];
    rightView.backgroundColor = backColor;
    rightView.alpha = viewAlpha;
    rightView.userInteractionEnabled = NO;
    [self.view addSubview:rightView];
    
    UIView *endView = [[UIView alloc]initWithFrame:CGRectMake(0, y+size.height, Screen_Width, self.view.frame.size.height-y-size.height)];
    endView.backgroundColor = backColor;
    endView.alpha = viewAlpha;
    endView.userInteractionEnabled = NO;
    [self.view addSubview:endView];
    
    
    
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(x, y, size.width, lineWideth)];
    upLine.backgroundColor = lineColor;
    upLine.userInteractionEnabled = NO;
    [self.view addSubview:upLine];
    
    UIView *leftLine = [[UIView alloc]initWithFrame:CGRectMake(x, y, lineWideth, size.height)];
    leftLine.backgroundColor = lineColor;
    leftLine.userInteractionEnabled = NO;
    [self.view addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(x+size.width-lineWideth, y, lineWideth, size.height)];
    rightLine.backgroundColor = lineColor;
    rightLine.userInteractionEnabled = NO;
    [self.view addSubview:rightLine];
    
    UIView *endLine = [[UIView alloc]initWithFrame:CGRectMake(x, y+size.height, size.width, lineWideth)];
    endLine.backgroundColor = lineColor;
    endLine.userInteractionEnabled = NO;
    [self.view addSubview:endLine];
    
}
@end
