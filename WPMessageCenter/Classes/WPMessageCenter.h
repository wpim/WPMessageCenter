//
//  WPMessageCenter.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/26.
//

#import <Foundation/Foundation.h>
#import "WPMessageObserver.h"
#import "WPMessageType.h"
#import "WPMessageEntity.h"

@interface WPMessageCenter : NSObject
#pragma mark - 单例、初始化
/**
 获取单例
 @return 单例对象
 */
+ (instancetype)sharedCenter;

/**
 消息通道初始化方法

 @param uid 用户ID，这个是IM的用户ID，跟用户系统的ID不是一个，不耦合
 @param params 初始化参数，这些参数将会以【key=value】的形式带在WebSocket链接后面，参数一般都是身份信息、签名信息等。SDK有一个默认参数【im_token】，请勿覆盖
 */
+ (void)setupSocketWithUid:(NSString *)uid params:(NSDictionary<NSString*, NSString*> *)params;

#pragma mark - 连接消息服务器
/**
 连接WebSocket服务器
 */
- (void)connect;

/**
 断开与WebSocket服务器的连接
 */
- (void)close;

#pragma mark - 消息监听
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

#pragma mark - 发送消息
/**
 发送文本消息
 @param text 文本消息内容
 */
- (void)sendText:(NSString *)text toUid:(NSString *)uid;
//
///**
// 发送二进制图片消息
// @param image 二进制图片
// */
//- (void)sendImageData:(NSData *)image;
//
///**
// 发送图片链接
// @param imageUrl 图片链接
// */
//- (void)sendImageURL:(NSString *)imageUrl;
@end
