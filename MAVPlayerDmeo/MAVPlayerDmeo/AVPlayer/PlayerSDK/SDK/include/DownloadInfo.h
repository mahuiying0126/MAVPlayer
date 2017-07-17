//
//  DownloadInfo.h
//  SDKv2
//
//  Created by yanning on 2017/2/21.
//  Copyright © 2017年 yanning. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUS_WAITING		2
#define STATUS_DOWNLOADING	3
#define STATUS_COMPLETED	4
#define STATUS_ERROR		5
#define STATUS_STOPPED		6
#define STATUS_DELETED		7
#define STATUS_PAUSED		8

@interface DownloadInfo : NSObject

@property (copy, nonatomic, readonly)	NSString*	ID;
@property (assign, nonatomic, readonly) int			status;
@property (assign, nonatomic, readonly) float		speed;
@property (assign, nonatomic, readonly) int			progress;
@property (assign, nonatomic, readonly) long		size;

@end
