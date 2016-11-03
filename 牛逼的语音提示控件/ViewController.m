//
//  ViewController.m
//  牛逼的语音提示控件
//
//  Created by 三 on 16/10/21.
//  Copyright © 2016年 三. All rights reserved.
//

#import "ViewController.h"
#import "RecordHUD.h"
#import "RecordButton.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<RecordButtonDelegate>
@property (nonatomic,strong) AVAudioPlayer *play;
@property (nonatomic,strong) NSData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RecordButton *btn = [[RecordButton alloc] initWithFrame:CGRectMake(100, [UIScreen mainScreen].bounds.size.height - 100, 200, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn initRecord:self andMaxTime:10 andTitle:@"上滑取消录音"];
    [btn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSError *error;
    _play = [[AVAudioPlayer alloc] initWithData:_data error:&error];
    NSLog(@"%@",error);
    _play.volume = 1.0f;
    [_play play];
    NSLog(@"%f",_play.duration);
}

- (void)endRecord:(NSData *)mp3Data{
    
    _data = mp3Data;
}

@end