//
//  RecordHUD.h
//  牛逼的语音提示控件
//
//  Created by 三 on 16/10/21.
//  Copyright © 2016年 三. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordHUD : UIView

@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong,readonly) UIWindow *overlayWindow;

+ (void)show;

+ (void)dismiss;

+ (void)setTitle:(NSString *)title;

+ (void)setTimeTitle:(NSString *)time;

+ (void)setImage:(NSString *)imgName;

@end