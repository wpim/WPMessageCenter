//
//  WPMessageCenter.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/26.
//

#import "WPMessageCenter.h"
#import <SocketRocket/SocketRocket.h>
#import <WPEnvCenter/WPEnvCenter.h>

@interface WPMessageCenter()
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSMutableArray<id<WPMessageObserver>> *observers;
@end

@implementation WPMessageCenter
#pragma mark - 单例
static WPMessageCenter *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - 懒加载
- (SRWebSocket *)socket {
    if (!_socket) {
        NSString *url = [WPEnvCenter sharedCenter].currentConfig.socketUrl;
        _socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    }
    return _socket;
}

- (NSMutableArray<id<WPMessageObserver>> *)observers {
    if (!_observers) {
        _observers = [NSMutableArray array];
    }
    return _observers;
}
#pragma mark - public
+ (instancetype)sharedCenter {
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

- (void)connect {
    [self.socket open];
}

- (void)close {
    [self.socket close];
}

- (void)sendMessage:(WPMessage *)message {
    [self.socket send:message.messageData];
}

- (void)addObserver:(id<WPMessageObserver>)observer {
    // 观察者不得为空
    if (!observer) {
        return;
    }
    
    // 观察者必须遵守协议
    if (![observer conformsToProtocol:@protocol(WPMessageObserver)]) {
        return;
    }
}

- (void)removeObserver:(id<WPMessageObserver>)observer {
    if ([self.observers containsObject:observer]) {
        [self.observers removeObject:observer];
    }
}

- (void)removeAllObserver {
    [self.observers removeAllObjects];
}
@end
