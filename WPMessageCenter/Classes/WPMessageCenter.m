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
@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *socketParams;

@property (nonatomic, strong) NSMutableArray<id<WPMessageObserver>> *observerPool;

@property (nonatomic, strong) NSMutableArray<WPMessage *> *buffer;
@property (nonatomic, strong) NSTimer *bufferTimer;
@property (nonatomic, strong) NSLock *bufferLock;
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
        // 拼接参数
        NSMutableArray *paramArr = [NSMutableArray array];
        for (NSString *key in self.socketParams.allKeys) {
            [paramArr addObject:[NSString stringWithFormat:@"%@=%@", key, self.socketParams[key]]];
        }
        NSString *param = [paramArr componentsJoinedByString:@"&"];
        
        // 拼接WebSocket请求链接
        NSString *url = [NSString stringWithFormat:@"%@?%@", [WPEnvCenter sharedCenter].currentConfig.socketUrl, param];
        
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

- (NSMutableArray<WPMessage *> *)buffer {
    if (!_buffer) {
        _buffer = [NSMutableArray array];
    }
    return _buffer;
}

- (NSDictionary<NSString *,NSString *> *)socketParams {
    if (!_socketParams) {
        _socketParams = @{@"im_token" : [self getImToken]};
    }
    return _socketParams;
}

- (NSLock *)bufferLock {
    if (!_bufferLock) {
        _bufferLock = [[NSLock alloc] init];
    }
    return _bufferLock;
}
#pragma mark - private
- (void)sendBuffer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.bufferLock lock];
        
        [weakSelf.buffer enumerateObjectsUsingBlock:^(WPMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf sendMessage:obj];
            [weakSelf.buffer removeObject:obj];
        }];
        
        [weakSelf.bufferLock unlock];
    });
}

- (NSString *)getImToken {
    static NSString *KEY_IM_TOKEN = @"KEY_IM_TOKEN";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 从缓存中取
    NSString *cahche = [defaults stringForKey:KEY_IM_TOKEN];
    if (cahche.length > 0) {
        return cahche;
    }
    
    // 缓存中没有，生成16位随机串作为im_token
    static NSString *chars = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger len = chars.length;
    NSMutableString *token = [NSMutableString string];
    for (int i=0; i<16; i++) {
        NSString *item = [chars substringWithRange:NSMakeRange((NSInteger)arc4random_uniform((uint32_t)len), 1)];
        [token appendString:item];
    }
    
    // 新生成的字符串存沙盒
    [defaults setObject:token forKey:KEY_IM_TOKEN];
    [defaults synchronize];
    
    return token;
}

#pragma mark - public
+ (instancetype)sharedCenter {
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+ (void)setupSocketWithParams:(NSDictionary<NSString *,NSString *> *)params {
    if (!params || params.count==0) {
        return;
    }
    
    WPMessageCenter *instance = [self sharedCenter];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    dict[@"im_token"] = [instance getImToken];
    
    instance.socketParams = [dict copy];
}

- (void)connect {
    SRReadyState state = self.socket.readyState;
    
    // 如果连接已经关闭或正在关闭，尝试连接WebSocket服务器
    if (SR_OPEN != state) {
        [self.socket open];
    }
    
    self.bufferTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendBuffer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.bufferTimer forMode:NSRunLoopCommonModes];
}

- (void)close {
    SRReadyState state = self.socket.readyState;
    
    // 如果连接打开或正在连接，尝试断开连接
    if (SR_OPEN == state || SR_CONNECTING ) {
        [self.socket close];
    }
}

- (void)sendMessage:(WPMessage *)message {
    // 判空
    if (!message) {
        return;
    }
    
    // 按状态分发
    SRReadyState state = self.socket.readyState;
    // 如果处于断开状态，连接服务器后再试
    if (SR_OPEN != state) {
        [self connect];
        [self.buffer addObject:message];
    } else {
        [self.socket send:message.messageData];
    }
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
