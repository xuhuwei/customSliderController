//
//  ViewController.m
//  customSlider
//
//  Created by 徐虎威 on 2018/3/24.
//  Copyright © 2018年 徐虎威. All rights reserved.
//

#define PINK [UIColor colorWithRed:1 green:71/255.0 blue:128/255.0 alpha:1]

#import "ViewController.h"

@interface ViewController () {
    UIView *targetView;
    UIView *touchView;
    BOOL isMove;
    CADisplayLink *displayLink;
    CGPoint touchPoint;
    CGPoint startPoint;
    CGPoint beginPoint;
    CGFloat speed;
    CAShapeLayer *shap;
    CGFloat percentage;
    UIView *downView;
    
    UILabel *down_textLable;
    UILabel *up_textLable;
    UILabel *down_title;
    UILabel *up_title;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *up_calibration = [self creatCalibration:PINK];
    [self.view addSubview:up_calibration];
    
    targetView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 10, self.view.center.y - 10, 20, 20)];
    targetView.center = self.view.center;
    targetView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:targetView];
    
    touchView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 5, self.view.center.y - 5, 10, 10)];
    touchView.center = self.view.center;
    touchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:touchView];
    
    [self creatLayer];
    
    downView = [[UIView alloc] initWithFrame:self.view.bounds];
    downView.backgroundColor = PINK;
    [self.view addSubview:downView];
    downView.layer.mask = shap;
    
    UIView *down_calibration = [self creatCalibration:[UIColor whiteColor]];
    [downView addSubview:down_calibration];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    

    [self calculatePercentage];
    
    [self creatText];
    [self changeTextPosition];
    
    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(25, 640, 44, 17)];
    more.text = @"MORE";
    more.textColor = [UIColor whiteColor];
    more.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [self.view addSubview:more];
    
    UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(305, 640, 56, 17)];
    stats.text = @"STATS";
    stats.textColor = [UIColor whiteColor];
    stats.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [self.view addSubview:stats];
    
    UILabel *setings = [[UILabel alloc] initWithFrame:CGRectMake(285, 20, 64, 16)];
    setings.text = @"SETINGS";
    setings.textColor = PINK;
    setings.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [self.view addSubview:setings];
    
    UIImage *img = [UIImage imageNamed:@"iCON.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 22, 15)];
    imgView.image = img;
    [self.view addSubview:imgView];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    

    startPoint = [[touches anyObject] locationInView:self.view];
    

    beginPoint = touchView.center;
    

    isMove = YES;

    if(displayLink){
        [touchView.layer removeAllAnimations];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    

    touchPoint = [[touches anyObject] locationInView:self.view];
    
    CGFloat distance_height = touchPoint.y - startPoint.y;
    touchView.center = CGPointMake(touchPoint.x, beginPoint.y + distance_height);
    
    if(isMove){
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    isMove = NO;
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:.21 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        touchView.center = CGPointMake(touchPoint.x, targetView.center.y);
        
    } completion:^(BOOL finished) {

        if(finished){
            [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            
        }
    }];
}


- (void)onDisplayLink:(CADisplayLink *)displayLink {
    
    CGFloat centerX = targetView.center.x;
    CGFloat centerY = targetView.center.y;
    CGFloat y_min   = 136;
    CGFloat y_max   = [UIScreen mainScreen].bounds.size.height - 136;
    
    if(targetView.center.x != touchPoint.x) {
        centerX -= (targetView.center.x - touchView.layer.presentationLayer.position.x) / 50;
    }

    if (targetView.center.y != touchPoint.y) {
        if(targetView.center.y < y_min) {
            centerY = y_min;
        } else if (targetView.center.y > y_max) {
            centerY = y_max;
        } else {
            centerY -= (targetView.center.y - touchView.layer.presentationLayer.position.y) / 50;
        }
    }

    targetView.center = CGPointMake(centerX, centerY);

    [self creatLayer];
    
    [self calculatePercentage];
    
    [self changeTextPosition];
}

- (void)creatLayer {

    if(shap == nil) {
        shap = [CAShapeLayer layer];
        shap.fillColor = [UIColor blackColor].CGColor;
    }
    

    UIBezierPath *bezier = [UIBezierPath bezierPath];
    [bezier moveToPoint:CGPointMake(0, targetView.center.y)];
    if(touchView.layer.presentationLayer.position.x == 0 && touchView.layer.presentationLayer.position.y == 0) {
        [bezier addQuadCurveToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, targetView.center.y) controlPoint:self.view.center];
    } else {
        [bezier addQuadCurveToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, targetView.center.y) controlPoint:touchView.layer.presentationLayer.position];
    }
    [bezier addLineToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [bezier addLineToPoint:CGPointMake(0, [UIScreen mainScreen].bounds.size.height)];
    [bezier addLineToPoint:CGPointMake(0, targetView.center.y)];
    [bezier closePath];
    

    shap.path = bezier.CGPath;
    
    
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)calculatePercentage {
    percentage = (targetView.center.y - 136) / (self.view.bounds.size.height - 136 * 2);
}

- (void)creatText {
    
    down_textLable = [[UILabel alloc] init];
    down_textLable.textColor = PINK;
    [self.view addSubview:down_textLable];
    
    down_title = [[UILabel alloc] init];
    down_title.numberOfLines = 0;
    down_title.textColor = PINK;
    down_title.text = @"POINTS\nYOU HAVE";
    down_title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    [self.view addSubview:down_title];
    
    up_textLable = [[UILabel alloc] init];
    up_textLable.textColor = [UIColor whiteColor];
    [self.view addSubview:up_textLable];
    
    
    up_title = [[UILabel alloc] init];
    up_title.numberOfLines = 0;
    up_title.textColor = [UIColor whiteColor];
    up_title.text = @"POINTS\nYOU NEED";
    up_title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    [self.view addSubview:up_title];
    
    [self changeTextPosition];
    
}

- (void)changeTextPosition {
    
    [self calculatePercentage];
    
    CGFloat fontSize = percentage * 50 + 50;
    int     fontContent = MIN(100, MAX(0, floorf(percentage * 100)));
    
    NSLog(@"fontSize: %f",fontSize);
    
    down_textLable.text = [NSString stringWithFormat:@"%d",fontContent];
    UIFont *down_fnt = [UIFont fontWithName:@"HelveticaNeue" size: fontSize];
    down_textLable.font = down_fnt;
    CGSize down_size = [down_textLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:down_fnt, NSFontAttributeName, nil]];
    down_textLable.frame = CGRectMake(0, 0, down_size.width, down_size.height);
    

    CGFloat down_text_y = MAX(60, MIN((self.view.bounds.size.height - 60 - down_textLable.frame.origin.y), (touchView.layer.presentationLayer.position.y + targetView.center.y) / 2 - 40 - down_textLable.bounds.size.height / 2));
    if(touchView.layer.presentationLayer.position.x == 0 && touchView.layer.presentationLayer.position.y == 0) {
        down_textLable.center = CGPointMake(25 + down_textLable.bounds.size.width / 2, self.view.center.y - 40 - down_textLable.bounds.size.height / 2);
    } else {
        down_textLable.center = CGPointMake(25 + down_textLable.bounds.size.width / 2, down_text_y);
    }
    
    
    CGPoint down_point = CGPointMake(down_textLable.frame.origin.x + down_textLable.frame.size.width + 12, down_textLable.frame.origin.y);
    down_title.frame = CGRectMake(down_point.x, down_point.y + 12, 74, 37);
    
    up_textLable.text = [NSString stringWithFormat:@"%d",(100 - fontContent)];
    UIFont *up_fnt = [UIFont fontWithName:@"HelveticaNeue" size: 150 - fontSize];
    up_textLable.font = up_fnt;
    CGSize up_size = [up_textLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:up_fnt, NSFontAttributeName, nil]];
    up_textLable.frame = CGRectMake(0, 0, up_size.width, up_size.height);
    

    CGFloat up_text_y = MAX(60, MIN((self.view.bounds.size.height - 60 - up_textLable.frame.origin.y), (touchView.layer.presentationLayer.position.y + targetView.center.y) / 2 + 40 + up_textLable.bounds.size.height / 2));
    if(touchView.layer.presentationLayer.position.x == 0 && touchView.layer.presentationLayer.position.y == 0) {
        up_textLable.center = CGPointMake(25 + up_textLable.bounds.size.width / 2, self.view.center.y + 40 + up_textLable.bounds.size.height / 2);
    } else {
        up_textLable.center = CGPointMake(25 + up_textLable.bounds.size.width / 2, up_text_y);
    }
    
    
    CGPoint up_point = CGPointMake(up_textLable.frame.origin.x + up_textLable.frame.size.width + 12, up_textLable.frame.origin.y);
    up_title.frame = CGRectMake(up_point.x, up_point.y + 12, 74, 37);
}


- (UIView *)creatCalibration: (UIColor*)color {
    UIView *creatCalibrationView = [[UIView alloc] initWithFrame:CGRectMake(315, 100, 35, 467)];
    
    for (int i = 0; i < 14; i++) {
        if(i == 0 || i == 13) {
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(0, 0, 35, 1);
            layer.backgroundColor = color.CGColor;
            layer.position = CGPointMake(35 / 2, 467 / 13 * i);
            [creatCalibrationView.layer addSublayer:layer];
        } else {
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(0, 0, 15, 1);
            layer.backgroundColor = color.CGColor;
            layer.position = CGPointMake(20 + 15 / 2, 467 / 13 * i);
            [creatCalibrationView.layer addSublayer:layer];
        }
    }
    return creatCalibrationView;
}

@end

