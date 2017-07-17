//
//  MediaServer.h
//  SDKv2
//
//  Created by yanning on 2017/2/21.
//  Copyright © 2017年 yanning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
#import "Speed.h"

@interface MediaServer : NSObject

+ (void)setDebugMode:(BOOL)value;

+ (void)prepareLocalFileAsync:(NSString*)url channel:(int)channel speed:(int)speed completion:(void(^)(NSError*, NSString*))completion;
+ (void)prepareNetworkStreamAsync:(NSString*)url reconnect:(BOOL)reconnect completion:(void(^)(NSError*, NSDictionary*))completion;

@end
