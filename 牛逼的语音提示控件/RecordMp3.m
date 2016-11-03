//
//  RecordMp3.m
//  牛逼的语音提示控件
//
//  Created by 三 on 16/11/1.
//  Copyright © 2016年 三. All rights reserved.
//

#import "RecordMp3.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordMp3 ()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioSession *session;
@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,strong) NSString *path;
@end

@implementation RecordMp3

- (id)initWithDelegate:(id<RecordMp3Delegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)setRecorder{
    _recorder = nil;
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:[self cafPath]];
    //配置录音设置
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:AVAudioQualityLow],
                              AVEncoderAudioQualityKey,
                              [NSNumber numberWithInt:16],
                              AVEncoderBitRateKey,
                              [NSNumber numberWithInt:2],
                              AVNumberOfChannelsKey,
                              [NSNumber numberWithFloat:11025.0],
                              AVSampleRateKey,nil];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }else{
        if ([_recorder prepareToRecord]) {
            NSLog(@"机器准备就绪");
        }
    }
}

- (void)setSesstion
{
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(_session == nil){
        NSLog(@"Error creating session: %@", [sessionError description]);
    }else{
        [_session setActive:YES error:nil];
    }
}

- (void)startRecord{
    
    [self setRecorder];
    [self setSesstion];
    [_recorder record];
    
    _recordTime = 0;
    _Timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
}

#pragma mark - 录音计时
- (void)countVoiceTime{
    _recordTime += 0.01;
    [_recorder updateMeters];
    const double ALPHA = 0.05;
    //声音分贝值转换
    double peakPowerForChannel = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    _lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * _lowPassResults;
    if ([_delegate respondsToSelector:@selector(recording:volume:)]) {
        [_delegate recording:_recordTime volume:_lowPassResults];
    }
}

#pragma mark - 停止录音
- (void)stopRecord{
    if (_Timer) {
        double currentTime = _recorder.currentTime;
        [_recorder stop];
        
        if (currentTime > 1) {
            //开始转化MP3
            [self audio_PCMtoMP3];
        }else{
            //删除录音
            [_recorder deleteRecording];
            if ([_delegate respondsToSelector:@selector(failureRecord)]) {
                [_delegate failureRecord];
            }
        }
        //关
        [_Timer invalidate];
        _Timer = nil;
    }
}

#pragma mark - 取消录音
- (void)cancelRecord{
    if (_Timer) {
        [_recorder stop];
        [_recorder deleteRecording];
        [_Timer invalidate];
        _Timer = nil;
    }
}

- (void)deleteMp3Cache{
    [self deleteFileWithPath:[self mp3Path]];
}

- (void)deleteCafCache{
    [self deleteFileWithPath:[self cafPath]];
}

#pragma mark - 删除录音
- (void)deleteFileWithPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:path error:nil]) {
        NSLog(@"删除以前的MP3文件");
    }
}

- (void)audio_PCMtoMP3{
    NSString *cafFilePath = [self cafPath];
    NSString *mp3FilePath = [self mp3Path];
    
    //删除旧的MP3
    [self deleteMp3Cache];
    
    NSLog(@"转化MP3开始");
    if (_delegate && [_delegate respondsToSelector:@selector(beginConvert)]) {
        [_delegate beginConvert];
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);//跳过头文件
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb"); //输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            }else{
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    
    @finally {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    }
    [self deleteCafCache];
    NSLog(@"MP3转化结束");
    if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithData:)]) {
        NSData *MP3Data = [NSData dataWithContentsOfFile:[self mp3Path]];
        [_delegate endConvertWithData:MP3Data];
    }
}

#pragma mark - Path Utils
- (NSString *)cafPath
{
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
    return cafPath;
}

- (NSString *)mp3Path
{
    NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mp3.caf"];
    return mp3Path;
}
@end