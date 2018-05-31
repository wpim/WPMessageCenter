//
//  WPMessageCenter.m
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/26.
//

#import "WPMessageCenter.h"
#import <SocketRocket/SocketRocket.h>
#import <WPEnvCenter/WPEnvCenter.h>
#import <YYModel/YYModel.h>
#import "WPMessageEntity.h"

@interface WPMessageCenter()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *socketParams;

@property (nonatomic, copy)   NSString *ownerUid;

@property (nonatomic, strong) NSMutableArray<id<WPMessageObserver>> *observerPool;

@property (nonatomic, strong) NSMutableArray<WPMessageEntity *> *buffer;
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
- (NSMutableArray<id<WPMessageObserver>> *)observerPool {
    if (!_observerPool) {
        _observerPool = [NSMutableArray array];
    }
    return _observerPool;
}

- (NSMutableArray<WPMessageEntity *> *)buffer {
    if (!_buffer) {
        _buffer = [NSMutableArray array];
    }
    return _buffer;
}

//- (NSDictionary<NSString *,NSString *> *)socketParams {
//    if (!_socketParams) {
//        _socketParams = @{@"im_token" : [self getImToken]};
//    }
//    return _socketParams;
//}

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
        
        [weakSelf.buffer enumerateObjectsUsingBlock:^(WPMessageEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf sendMessage:obj fromBuffer:YES];
            [weakSelf.buffer removeObject:obj];
        }];
        
        [weakSelf.bufferLock unlock];
    });
}

- (void)sendMessage:(WPMessageEntity *)message fromBuffer:(BOOL)isFromBuffer {
    // 判空
    if (!message || ![message isKindOfClass:WPMessageEntity.class]) {
        return;
    }
    
    // 按状态分发
    SRReadyState state = self.socket.readyState;
    // 如果处于断开状态，连接服务器后再试
    if (SR_OPEN != state) {
        // 如果不是从缓冲区来的，将这条消息加入缓冲区
        if (!isFromBuffer) {
            [self.buffer addObject:message];
        }
    } else {
        [self.socket send:message.messageData];
        if (isFromBuffer) {
            [self.buffer removeObject:message];
        }
    }
}

#pragma mark - public
+ (instancetype)sharedCenter {
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+ (void)setupSocketWithUid:(NSString *)uid params:(NSDictionary<NSString *,NSString *> *)params {
    WPMessageCenter *instance = [self sharedCenter];
    instance.ownerUid = uid;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    dict[@"im_token"] = uid;
    
    instance.socketParams = [dict copy];
}

#pragma mark 连接服务器
- (SRWebSocket *)createSocket {
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
    return socket;
}

- (void)connect {
    [self close];
    
    self.socket = [self createSocket];
    [self.socket open];
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(keepConnect) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
    
    self.bufferTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendBuffer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.bufferTimer forMode:NSRunLoopCommonModes];
}

- (void)keepConnect {
    if (SR_OPEN != self.socket.readyState) {
        [self connect];
    }
}

- (void)close {
    if (self.socket) {
        [self.socket close];
        self.socket.delegate = nil;
        self.socket = nil;
    }
    
    if (self.bufferTimer) {
        [self.bufferTimer invalidate];
        self.bufferTimer = nil;
    }
    
    if (self.connectTimer) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
}

#pragma mark 消息监听
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

#pragma mark 发送消息
- (void)sendText:(NSString *)text toUid:(NSString *)uid{
    if (text==nil || text.length==0) {
        return;
    }
    
    WPMessageEntity *msg = [[WPMessageEntity alloc] initWithDateNow];
    msg.text = text;
    msg.toUid = uid;
    msg.ownerUid = self.ownerUid;
    [self sendMessage:msg fromBuffer:NO];
}

- (void)sendImageData:(NSData *)image {
    if (image==nil) {
        return;
    }
    
//    WPImageMessage
}

- (void)sendImageURL:(NSString *)imageUrl {
    
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
    NSLog(@"%@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    for (id<WPMessageObserver> observer in self.observerPool) {
        if ([observer respondsToSelector:@selector(didCloseServer)]) {
            [observer didCloseServer];
        }
    }
}

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    WPMessageEntity *msg = [WPMessageEntity yy_modelWithJSON:message];
    if (!msg) {
        return;
    }
    
    for (id<WPMessageObserver> observer in self.observerPool) {
        if ([observer respondsToSelector:@selector(didReceiveMessage:)]) {
            [observer didReceiveMessage:message];
        }
    }
}

@end
