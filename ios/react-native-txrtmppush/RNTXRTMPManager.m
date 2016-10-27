//
//  RNTXRTMPManager.m
//  RNTXRTMP
//
//  Created by Bear on 16/10/18.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RNTXRTMPManager.h"
#import "RNTXRTMPModel.h"
#import "RCTConvert+Options.h"


@interface RNTXRTMPManager ()<RNTXRTMPModelStateDelegate>

@end
@implementation RNTXRTMPManager


@synthesize bridge=_bridge;

RCT_EXPORT_MODULE(RNTXRTMPManager);


//创建直播
RCT_EXPORT_METHOD(createWithParams:(NSDictionary *)params){

  RNTXRTMPModel* shareModel = [RNTXRTMPModel shareRTMPPush];
  shareModel.delegate = self;
  [shareModel createWithParams:params];

}

//开始直播
RCT_EXPORT_METHOD(startPusher:(NSString*)url option:(RNRecod)options){

  [[RNTXRTMPModel shareRTMPPush] startPusher:url option:options];
}

//停止直播
RCT_EXPORT_METHOD(stopPusher){
  [[RNTXRTMPModel shareRTMPPush] stopPusher];
}

-(NSArray<NSString *> *)supportedEvents{

  return @[@"RTMPOnPushEvent",@"RTMPOnNetStatus"];
}

-(void)RTMPOnPushEvent:(int)EvtID withParam:(NSDictionary *)param{

  NSNumber* evtId = @(EvtID);
  [self sendEventWithName:@"RTMPOnPushEvent" body:@{@"EvtID":evtId,@"result":param}];
}

-(void)RTMPOnNetStatus:(NSDictionary *)param{

  [self sendEventWithName:@"RTMPOnNetStatus" body:param];
}

-(NSDictionary<NSString *,id> *)constantsToExport{

  return @{@"RNNORecod":@(RNNORecod),
           @"RNRecodMP4":@(RNRecodMP4),
           @"RNRecodFLV":@(RNRecodFLV)};
}

//暂停推流
RCT_EXPORT_METHOD(pausePush){

  [[RNTXRTMPModel shareRTMPPush] pauseTXPush];
}

//开始推流
RCT_EXPORT_METHOD(resumePush){

  [[RNTXRTMPModel shareRTMPPush] resumeTXPush];
}

RCT_EXPORT_METHOD(setTXMute:(BOOL)isMute){

  [[RNTXRTMPModel shareRTMPPush] setMute:isMute];
}

//播放指定路径的音乐
RCT_EXPORT_METHOD(playTXBGMWithUrl:(NSString*)url){

#ifdef DEBUG
  // Debug 模式的代码...
//  NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//  NSString* musicDocumentPath = [documentPath stringByAppendingPathComponent:@"mySky.mp3"];
//  NSFileManager* manager = [NSFileManager defaultManager];
//  if ([manager fileExistsAtPath:musicDocumentPath]) {
//    url = musicDocumentPath;
//    NSLog(@"url:%@",musicDocumentPath);
//  }
#else
  // Release 模式的代码...
#endif

  NSLog(@"当前实际播放的url:%@",url);
  [[RNTXRTMPModel shareRTMPPush] getMusicWithPath:url];
}

//停止播放
RCT_EXPORT_METHOD(stopTXBGM){

  [[RNTXRTMPModel shareRTMPPush] stopTXBGM];
}

//暂停播放
RCT_EXPORT_METHOD(pauseTXBGM){

  [[RNTXRTMPModel shareRTMPPush] pauseTXBGM];
}

//继续播放
RCT_EXPORT_METHOD(resumTXBGM){

  [[RNTXRTMPModel shareRTMPPush] resumeTXPush];
}

//设置混合音量的大小
RCT_EXPORT_METHOD(setTXBGMVolume:(CGFloat)volume){

  [[RNTXRTMPModel shareRTMPPush] setTXBGMVolume:volume];
}

//设置mic的音量大小
RCT_EXPORT_METHOD(setTXMicVolume:(CGFloat)volume){

  [[RNTXRTMPModel shareRTMPPush] setTXMicVolume:volume];
}
//为避免阻塞线程
-(dispatch_queue_t)methodQueue{

  return dispatch_get_main_queue();
}

@end
