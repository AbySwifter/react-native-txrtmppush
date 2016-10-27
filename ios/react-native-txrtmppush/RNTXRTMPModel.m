//
//  RNTXRTMPModel.m
//  RNTXRTMP
//
//  Created by Bear on 16/10/18.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RNTXRTMPModel.h"
#import "UIImage+Color.h"
#import "TXRTMPSDK/TXLivePush.h"

#define MP4 @"&record=mp4"
#define FLV @"&record=flv"


@interface RNTXRTMPModel ()<TXLivePushListener>

@property(nonatomic, retain)TXLivePush* pusher;//推流器
@property(nonatomic, retain)TXLivePushConfig* liveConfig;//推流配置
@property (nonatomic, retain)NSTimer* timer;//定时器，模拟发送假数据
@property (nonatomic, assign)unsigned char* buffer;//视屏数据

@end

@implementation RNTXRTMPModel

+(instancetype)shareRTMPPush{

  static RNTXRTMPModel* model = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    model = [[RNTXRTMPModel alloc] init];
  });
  return model;
}

-(BOOL)isPusherExist{
  if (self.pusher) {
    return YES;
  }
  return NO;
}
//创建推流对象
-(void)createWithParams:(NSDictionary*)params{
  NSLog(@"SDK Version = %@", [[TXLivePush getSDKVersion] componentsJoinedByString:@"."]);
  //初始化配置器
  self.liveConfig = [[TXLivePushConfig alloc] init];
  //只用sdk来推流采集视屏数据
  [self.liveConfig setCustomModeType:CUSTOM_MODE_VIDEO_CAPTURE];
  //默认视屏分辨率为
  self.liveConfig.videoResolution = VIDEO_RESOLUTION_TYPE_360_640;//由于只需要实现音屏，所以设置为最低分辨率
  self.liveConfig.videoFPS = 5;//视屏编码器的每秒多少帧
  self.liveConfig.enableAutoBitrate = YES;//根据网络状况自动适应码率
  self.liveConfig.pauseImg = [UIImage imageNamed:@"pauseImag"];
  //如果设置了参数
  if (params) {
    if ([params objectForKey:@"pauseImg"]) {
      NSMutableDictionary* paramsMutable = [params mutableCopy];
//      [paramsMutable removeObjectForKey:@"ppauseImg"];
      [paramsMutable setObject:[UIImage imageNamed:@"pauseImg"] forKey:@"pauseImg"];
      [self.liveConfig setValuesForKeysWithDictionary:paramsMutable];
    }else{
      NSLog(@"%@",params);
      [self.liveConfig setValuesForKeysWithDictionary:params];

    }
  }
  //初始化推流器
  self.pusher = [[TXLivePush alloc] initWithConfig:self.liveConfig];

}

//启动推流
-(void)startPusher:(NSString*)url option:(RNRecod)options{

  if (options!=RNNORecod) {
    //这里是打开录制的代码
    if (options == RNRecodMP4) {
      url = [url stringByAppendingString:MP4];
    }else if (options == RNRecodFLV){
      url = [url stringByAppendingString:FLV];
    }

  }
  if (self.pusher) {
    self.pusher.delegate = self;
    [self.pusher startPush:url];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(sendVideodata) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterForegroud:) name:UIApplicationWillEnterForegroundNotification object:nil];
    NSLog(@"开始了推流，当前线程是%@",[NSThread currentThread]);
  }else{
    NSLog(@"推流器不存在，未创建推流器");
  }
}

-(void)handleEnterBackground:(NSNotification*)notification{

  [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{

  }];
  [self pauseTXPush];
}

-(void)handleEnterForegroud:(NSNotification* )notification{

  [self resumeTXPush];
}

-(void)pauseTXPush{
  if (![self isPusherExist]) {
    return;
  }
  [self.timer setFireDate:[NSDate distantFuture]];
  [self.pusher pausePush];
}

-(void)resumeTXPush{
  if (![self isPusherExist]) {
    return;
  }
  [self.pusher resumePush];
  [self.timer setFireDate:[NSDate distantPast]];
}



-(void)creatBufferWithColor:(UIColor*)color{
  UIImage *image = [UIImage imageWithColor:color];
  unsigned char* buffer = [self convertUIImageToBitmapRGBA8:image];
  self.buffer = buffer;
}

-(void)sendVideodata{
  if (!self.buffer) {
#ifdef DEBUG
    [self creatBufferWithColor:[UIColor greenColor]];
#else
    [self creatBufferWithColor:[UIColor blackColor]];
#endif
  }

  [self.pusher sendCustomVideoData:self.buffer dataLen:369*640*4 videoType: VIDEO_TYPE_RGBA8888 width:360 height:640];
}

//停止推流
-(void)stopPusher{
  NSLog(@"停止了推流");
  if (self.pusher) {
    [self.pusher stopPush];
    self.pusher.delegate = nil;
  }
      if (self.timer) {
      [self.timer invalidate];
      self.timer = nil;
    }
}

//设置静音
-(void)setMute:(BOOL)isMute{

  if (![self isPusherExist]) {
    return;
  }
  [self.pusher setMute:isMute];
}

#pragma mark - txlivePushListenerDelegate
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param{
  NSLog(@"%@",param[@"EVT_MSG"]);
  if (self.delegate&&[self.delegate respondsToSelector:@selector(RTMPOnPushEvent:withParam:)]) {
    [self.delegate RTMPOnPushEvent:EvtID withParam:param];
  }

}

-(void)onNetStatus:(NSDictionary *)param{
//  NSLog(@"status:%@",param);
  if (self.delegate&&[self.delegate respondsToSelector:@selector(RTMPOnNetStatus:)]) {
    [self.delegate RTMPOnNetStatus:param];
  }

}

//设置混音的大小
-(BOOL)setTXBGMVolume:(float)volume{

  if (![self isPusherExist]) {
    return NO;
  }
  return  [self.pusher setBGMVolume:volume];
}

//设置mac的大小
-(BOOL)setTXMicVolume:(float)volume{

  if (![self isPusherExist]) {
    return NO;
  }
  return [self.pusher setMicVolume:volume];
}
//音频播放相关
-(BOOL)getMusicWithPath:(NSString*)path{

  if (![self isPusherExist]) {
    return NO;
  }
  BOOL success = [self.pusher playBGM:path];
  return success;
}

//音频播放停止
-(BOOL)stopTXBGM{

  if (![self isPusherExist]) {
    return NO;
  }
  BOOL success = [self.pusher stopBGM];
  return success;
}

//音频播放继续
-(BOOL)resumTCBGM{

  if (![self isPusherExist]) {
    return NO;
  }
  BOOL success = [self.pusher resumeBGM];
  return success;
}

//音频播放继暂停
-(BOOL)pauseTXBGM{
  if (![self isPusherExist]) {
    return NO;
  }
  BOOL success = [self.pusher pauseBGM];
  return success;
}

#pragma mark - UIImage
//自定义推流的状态
- (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {

  CGImageRef imageRef = image.CGImage;

  // Create a bitmap context to draw the uiimage into
  CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];

  if(!context) {
    return NULL;
  }

  size_t width = CGImageGetWidth(imageRef);
  size_t height = CGImageGetHeight(imageRef);

  CGRect rect = CGRectMake(0, 0, width, height);

  // Draw image into the context to get the raw image data
  CGContextDrawImage(context, rect, imageRef);

  // Get a pointer to the data
  unsigned char *bitmapData = (unsigned char*)CGBitmapContextGetData(context);

  // Copy the data and release the memory (return memory allocated with new)
  size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
  size_t bufferLength = bytesPerRow * height;

  unsigned char *newBitmap = NULL;

  if(bitmapData) {
    newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);

    if(newBitmap) {    // Copy the data
      for(int i = 0; i < bufferLength; ++i) {
        newBitmap[i] = bitmapData[i];
      }
    }

    free(bitmapData);

  } else {
    NSLog(@"Error getting bitmap pixel data\n");
  }

  CGContextRelease(context);

  return newBitmap;
}

- (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
  CGContextRef context = NULL;
  CGColorSpaceRef colorSpace;
  uint32_t *bitmapData;

  size_t bitsPerPixel = 32;
  size_t bitsPerComponent = 8;
  size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;

  size_t width = CGImageGetWidth(image);
  size_t height = CGImageGetHeight(image);

  size_t bytesPerRow = width * bytesPerPixel;
  size_t bufferLength = bytesPerRow * height;

  colorSpace = CGColorSpaceCreateDeviceRGB();

  if(!colorSpace) {
    NSLog(@"Error allocating color space RGB\n");
    return NULL;
  }

  // Allocate memory for image data
  bitmapData = (uint32_t *)malloc(bufferLength);

  if(!bitmapData) {
    NSLog(@"Error allocating memory for bitmap\n");
    CGColorSpaceRelease(colorSpace);
    return NULL;
  }

  //Create bitmap context

  context = CGBitmapContextCreate(bitmapData,
                                  width,
                                  height,
                                  bitsPerComponent,
                                  bytesPerRow,
                                  colorSpace,
                                  kCGImageAlphaPremultipliedLast);    // RGBA
  if(!context) {
    free(bitmapData);
    NSLog(@"Bitmap context not created");
  }

  CGColorSpaceRelease(colorSpace);

  return context;
}

@end
