//
//  RecordMp3.h
//  牛逼的语音提示控件
//
//  Created by 三 on 16/11/1.
//  Copyright © 2016年 三. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RecordMp3Delegate;

@interface RecordMp3 : NSObject
@property (nonatomic,assign) double lowPassResults;
@property (nonatomic,assign) float recordTime;
@property (nonatomic,strong) NSTimer *Timer;
@property (nonatomic,weak) id<RecordMp3Delegate> delegate;

- (id)initWithDelegate:(id<RecordMp3Delegate>)delegate;
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

@protocol RecordMp3Delegate <NSObject>

@optional
/**
 *  录音失败
 */
- (void)failureRecord;
/**
 *  开始转换格式
 */
- (void)beginConvert;
/**
 *  <#Description#>
 *
 *  @param recordTime <#recordTime description#>
 *  @param volume     <#volume description#>
 */
- (void)recording:(float)recordTime volume:(float)volume;
/**
 *  <#Description#>
 *
 *  @param voiceData <#voiceData description#>
 */
- (void)endConvertWithData:(NSData *)voiceData;
@end