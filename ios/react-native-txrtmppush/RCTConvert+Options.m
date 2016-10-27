//
//  RCTConvert+Options.m
//  RNTXRTMP
//
//  Created by Bear on 2016/10/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "RCTConvert+Options.h"



@implementation RCTConvert (Options)

RCT_ENUM_CONVERTER(RNRecod, (@{@"RNNORecord":@(RNNORecod),
                               @"RNRecordMP4":@(RNRecodMP4),
                               @"RNRecordFLV":@(RNRecodFLV)}), RNNORecod, integerValue);

@end
