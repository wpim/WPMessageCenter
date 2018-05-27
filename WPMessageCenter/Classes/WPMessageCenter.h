//
//  WPMessageCenter.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/26.
//

#import <Foundation/Foundation.h>
#import "WPMessageObserver.h"
#import "WPMessage.h"
#import "WPTextMessage.h"
#import "WPImageMessage.h"

@interface WPMessageCenter : NSObject

/**
 获取单例
 @return 单例对象
 */
+ (instancetype)sharedCenter;


/**
 连接WebSocket服务器
 */
- (void)connect;

/**
 断开与WebSocket服务器的连接
 */
- (void)close;

/**
 向WebSocket服务器发送消息
 @param message 消息对象
 */
- (void)sendMessage:(nonnull WPMessage *)message;

/**
 添加消息观察者，可以监听消息的到达，可以添加多个。观察者对象会被强引用，所以需要注意在不需要的时候手动移除
 @param observer 观察者对象
 */
- (void)addObserver:(nonnull id<WPMessageObserver>)observer;

/**
 移除某个观察者
 @param observer 被移除的观察者对象
 */
- (void)removeObserver:(nonnull id<WPMessageObserver>)observer;

/**
 移除所有观察者
 */
- (void)removeAllObserver;
@end
