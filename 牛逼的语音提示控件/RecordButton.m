//
//  RecordButton.m
//  牛逼的语音提示控件
//
//  Created by 三 on 16/11/1.
//  Copyright © 2016年 三. All rights reserved.
//

#import "RecordButton.h"
#import "RecordHUD.h"
#import "RecordMp3.h"
#define Title @"离开按钮取消录音"

@interface RecordButton ()<RecordMp3Delegate>

@end

@implementation RecordButton

- (void)initRecord:(id<RecordButtonDelegate>)delegate andMaxTime:(int)maxTime andTitle:(NSString *)title{
    self.delegate = delegate;
    _maxTime = maxTime;
    _title = title;
    
    _mp3 = [[RecordMp3 alloc] initWithDelegate:self];
    
    //按下
    [self addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
    //指鼠标在控件范围内抬起，前提先得按下（正常停止录音）
    [self addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    //如果你的抬起范围在控件之外
    [self addTarget:self action:@selector(cancelRecord) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    //指拖动动作中，从控件范围内到外时产生的事件
    [self addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    //指拖动动作中，从控件范围外到内时产生的事件
    [self addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
}

#pragma mark - 开始录音
- (void)startRecord{
    [_mp3 startRecord];
    [RecordHUD show];
    [self setHUDTitle];
}

#pragma mark - 正常停止录音，开始转化数据
- (void)stopRecord{
    [RecordHUD dismiss];
    [_mp3 stopRecord];
}

#pragma mark - 取消录音
- (void)cancelRecord{
    [_mp3 cancelRecord];
    [RecordHUD dismiss];
    [RecordHUD setTitle:@"已取消录音"];
}

#pragma mark - 离开控件范围
- (void)RemindDragExit:(UIButton *)sender{
    [RecordHUD setTitle:@"松开取消录音"];
    if ([_delegate respondsToSelector:@selector(dragExit)]) {
        [_delegate dragExit];
    }
}

#pragma mark - 进入控件范围
- (void)RemindDragEnter:(UIButton *)sender{
    if (_title != nil) {
        [RecordHUD setTitle:_title];
    }else{
        [RecordHUD setTitle:@"离开按钮取消录音"];
    }
}

- (void)setHUDTitle{
    [RecordHUD setTitle:_title = _title == nil ? Title : _title];
}

#pragma mark - 代理
- (void)endConvertWithData:(NSData *)voiceData{
    NSLog(@"%@",voiceData);
    [RecordHUD setTitle:@"录音成功"];
    NSLog(@"录音成功");
    if ([_delegate respondsToSelector:@selector(endRecord:)]) {
        [_delegate endRecord:voiceData];
    }
}

#pragma mark - 代理
- (void)recording:(float)recordTime volume:(float)volume{
    if (recordTime >= _maxTime) {
        [self stopRecord];
    }
    [RecordHUD setImage:[NSString stringWithFormat:@"mic_%.0f.png",volume*10 > 5 ? 5 : volume*10]];
    [RecordHUD setTimeTitle:[NSString stringWithFormat:@"录音: %.0f\"",recordTime]];
}

@end