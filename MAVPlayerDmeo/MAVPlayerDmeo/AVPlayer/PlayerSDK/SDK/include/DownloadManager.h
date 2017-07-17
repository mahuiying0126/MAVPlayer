//
//  DownloadManager.h
//  SDKv2
//
//  Created by yanning on 2017/2/21.
//  Copyright © 2017年 yanning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
#import "DownloadInfo.h"
#import "Speed.h"

@protocol DownloadStatusChangedDelegate<NSObject>

- (void)downloadStatusChanged:(DownloadInfo*)downloadInfo;

@end

@interface DownloadManager : NSObject

+ (void)setDebugMode:(BOOL)value;

+ (void)init:(NSString*)dir completion:(void(^)(NSError*))completion;

+ (void)setDownloadStatusChangedDelegate:(id<DownloadStatusChangedDelegate>)delegate;

+ (void)startWithName:(NSString*)name channel:(int)channel speed:(int)speed;

+ (void)start:(NSString*)ID;

+ (void)stop:(NSString*)ID;

+ (void)delete:(NSString*)ID;

+ (NSArray<DownloadInfo*>*)listDownloadInfos;

+ (void)pauseAll;

@end
