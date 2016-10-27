//
//  RNTXRTMPModel.h
//  RNTXRTMP
//
//  Created by Bear on 16/10/18.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTConvert+Options.h"

@protocol RNTXRTMPModelStateDelegate <NSObject>

-(void)RTMPOnPushEvent:(int)EvtID withParam:(NSDictionary*)param;

-(void)RTMPOnNetStatus:(NSDictionary *)param;

@end

@interface RNTXRTMPModel : NSObject

@property(nonatomic, assign)id<RNTXRTMPModelStateDelegate> delegate;

+(instancetype)shareRTMPPush;

//创建推流对象
-(void)createWithParams:(NSDictionary*)params;


//启动推流
-(void)startPusher:(NSString*)url option:(RNRecod)options;

//停止推流
-(void)stopPusher;

//暂停推流
-(void)pauseTXPush;

//重新开始推流
-(void)resumeTXPush;

//播放背景音乐
-(BOOL)getMusicWithPath:(NSString*)path;

//音频播放停止
-(BOOL)stopTXBGM;

//音频播放继续
-(BOOL)resumTCBGM;

//音频播放继暂停
-(BOOL)pauseTXBGM;

//设置静音
-(void)setMute:(BOOL)isMute;

/* setMicVolume 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小
 * @param volume: 音量大小，1为正常音量，建议值为0~2，如果需要调大音量可以设置更大的值
 */
- (BOOL)setTXMicVolume:(float)volume;

/* setBGMVolume 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小
 * @param volume: 音量大小，1为正常音量，建议值为0~2，如果需要调大背景音量可以设置更大的值
 */
- (BOOL)setTXBGMVolume:(float)volume;

@end
