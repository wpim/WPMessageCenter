//
//  WPMessageObserver.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import <Foundation/Foundation.h>

@class WPMessage;

@protocol WPMessageObserver <NSObject>

/**
 收到消息时的回调
 @param observer 观察者对象
 @param message 收到的消息
 */
- (void)messageObserver:(id<WPMessageObserver>)observer didReceiveMessage:(WPMessage *)message;
@end
