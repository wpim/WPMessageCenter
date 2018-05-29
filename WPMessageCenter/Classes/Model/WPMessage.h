//
//  WPMessage.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import <Foundation/Foundation.h>
#import "WPMessageType.h"

@interface WPMessage : NSObject<NSCoding>
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) WPMessageType type;

- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithDateNow;

/**
 消息对象转二进制数据
 @return 消息对象的二进制数据
 */
- (NSData *)messageData;
@end
