//
//  WPMessage.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import <Foundation/Foundation.h>
#import "WPMessageType.h"

@interface WPMessage : NSObject<NSCoding>
/// 消息ID
@property (nonatomic, copy)     NSString        *ID;
/// 消息创建时间戳
@property (nonatomic, assign)   NSTimeInterval  timestamp;
/// 消息类型
@property (nonatomic, assign)   WPMessageType   type;
/// 消息所有者ID
@property (nonatomic, copy)     NSString        *ownerUid;
/// 消息接受者ID
@property (nonatomic, copy)     NSString        *toUid;

- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithDateNow;

/**
 消息对象转二进制数据
 @return 消息对象的二进制数据
 */
- (NSData *)messageData;
@end
