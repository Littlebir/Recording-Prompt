//
//  RecordButton.h
//  牛逼的语音提示控件
//
//  Created by 三 on 16/11/1.
//  Copyright © 2016年 三. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecordMp3;
@protocol RecordButtonDelegate;

@interface RecordButton : UIButton
@property (nonatomic,assign) int maxTime;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) RecordMp3 *mp3;
@property (nonatomic,weak) id<RecordButtonDelegate> delegate;
/**
 *  初始化
 *
 *  @param delegate 代理
 *  @param maxTime  录音的最长时间
 *  @param title    提示语
 */
- (void)initRecord:(id<RecordButtonDelegate>)delegate andMaxTime:(int)maxTime andTitle:(NSString *)title;
/**
 *  开始录音
 */
- (void)startRecord;
/**
 *  停止录音
 */
- (void)stopRecord;
/**
 *  取消录音
 */
- (void)cancelRecord;
@end

@protocol RecordButtonDelegate <NSObject>
- (void)endRecord:(NSData *)mp3Data;
@optional
- (void)recording:(float)recordTime;
- (void)dragExit;
- (void)dragEnter;

@end