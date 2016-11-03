//
//  RecordHUD.m
//  牛逼的语音提示控件
//
//  Created by 三 on 16/10/21.
//  Copyright © 2016年 三. All rights reserved.
//

#import "RecordHUD.h"

#define TheScreen [[UIScreen mainScreen] bounds]
#define centerX [[UIScreen mainScreen] bounds].size.width / 2
#define centerY [[UIScreen mainScreen] bounds].size.height / 2

@implementation RecordHUD

@synthesize overlayWindow;

+ (RecordHUD *)shareView{
    static dispatch_once_t onceToken;
    static RecordHUD *sharedView;
    dispatch_once(&onceToken, ^{
        sharedView = [[RecordHUD alloc] initWithFrame:TheScreen];
        sharedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    });
    return sharedView;
}

+ (void)show{
    [[RecordHUD shareView] show];
}

- (void)show{
    //判断是否有了 没有在加
    if (!self.superview) {
        [self.overlayWindow addSubview:self];
    }else return;
    
    _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mic_0"]];
    _imgView.frame = CGRectMake(0, 0, 154, 180);
    _imgView.center = CGPointMake(centerX, centerY);
    _imgView.layer.cornerRadius = 10.0f;
    _imgView.layer.masksToBounds = YES;
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    _titleLabel.center = CGPointMake(_imgView.center.x, _imgView.center.y+65);
    _titleLabel.text = @"离开按钮取消录音";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.textColor = [UIColor whiteColor];
    
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    _timeLabel.center = CGPointMake(_imgView.center.x, _imgView.center.y-77);
    _timeLabel.text = @"录音: 0\"";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont boldSystemFontOfSize:14];
    _timeLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:_imgView];
    [self addSubview:_titleLabel];
    [self addSubview:_timeLabel];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    [self setNeedsDisplay];
}

+ (void)dismiss{
    [[RecordHUD shareView] dismiss];
}

- (void)dismiss{
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.alpha == 0) {
            [_imgView removeFromSuperview];
            _imgView = nil;
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
            [_timeLabel removeFromSuperview];
            _timeLabel = nil;
            
            NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
            [windows removeObject:overlayWindow];
            overlayWindow = nil;
            
            [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                    [window makeKeyWindow];
                    *stop = YES;
                }
            }];
        }
    }];
}

//赋值
+ (void)setTitle:(NSString *)title{
    [[RecordHUD shareView] setTitle:title];
}
- (void)setTitle:(NSString *)title{
    if (_titleLabel) {
        _titleLabel.text = title;
    }
}

+ (void)setTimeTitle:(NSString *)time{
    [[RecordHUD shareView] setTime:time];
}
- (void)setTime:(NSString *)time{
    if (_timeLabel) {
        _timeLabel.text = time;
    }
}

+ (void)setImage:(NSString *)imgName{
    [[RecordHUD shareView] setImage:imgName];
}
- (void)setImage:(NSString *)imageName{
    if (_imgView) {
        _imgView.image = [UIImage imageNamed:imageName];
    }
}

- (UIWindow *)overlayWindow{
    if (!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:TheScreen];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}

@end