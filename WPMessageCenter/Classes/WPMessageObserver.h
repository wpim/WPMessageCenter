//
//  WPMessageObserver.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import <Foundation/Foundation.h>

@class WPMessageEntity;

@protocol WPMessageObserver <NSObject>

/**
 连接上服务器的回调
 */
- (void)didConnectServer;

/**
 关闭WebSocket服务器连接
 */
- (void)didCloseServer;

/**
 收到消息时的回调
 @param message 收到的消息
 */
- (void)didReceiveMessage:(WPMessageEntity *)message;
@end
