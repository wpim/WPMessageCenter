//
//  WPMessageCenter.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/26.
//

#import "WPMessageCenter.h"
#import <SocketRocket/SocketRocket.h>
#import <WPEnvCenter/WPEnvCenter.h>

@interface WPMessageCenter()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSMutableArray<id<WPMessageObserver>> *observerPool;
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
        NSString *url = [NSString stringWithFormat:@"%@?token=666", [WPEnvCenter sharedCenter].currentConfig.socketUrl];
        SRWebSocket *socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
        socket.delegate = self;
        _socket = socket;
    }
    return _socket;
}
- (NSMutableArray<id<WPMessageObserver>> *)observerPool {
    if (!_observerPool) {
        _observerPool = [NSMutableArray array];
    }
    return _observerPool;
}

#pragma mark - public
+ (instancetype)sharedCenter {
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

- (void)connect {
    SRReadyState state = self.socket.readyState;
    
    // 如果连接已经关闭或正在关闭，尝试连接WebSocket服务器
    if (SR_OPEN != state) {
        [self.socket open];
    }
}

- (void)close {
    SRReadyState state = self.socket.readyState;
    
    // 如果连接打开或正在连接，尝试断开连接
    if (SR_OPEN == state || SR_CONNECTING ) {
        [self.socket close];
    }
}

- (void)sendMessage:(WPMessage *)message {
    SRReadyState state = self.socket.readyState;
    
    // 如果处于断开状态，连接服务器后再试
    if (SR_CLOSED == state || SR_CLOSING == state) {
        [self connect];
    }
    
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
    
    [self.observerPool addObject:observer];
}

- (void)removeObserver:(id<WPMessageObserver>)observer {
    if ([self.observerPool containsObject:observer]) {
        [self.observerPool removeObject:observer];
    }
}

- (void)removeAllObserver {
    [self.observerPool removeAllObjects];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    for (id<WPMessageObserver> observer in self.observerPool) {
        if ([observer respondsToSelector:@selector(didConnectServer)]) {
            [observer didConnectServer];
        }
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
}


@end
