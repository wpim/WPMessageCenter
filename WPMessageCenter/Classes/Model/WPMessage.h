//
//  WPMessage.h
//  WPMessageCenter
//
//  Created by 甘文鹏 on 2018/5/27.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WPMessageType) {
    WPMessageTypeUnknown,
    WPMessageTypeText,
    WPMessageTypeImage
};

@interface WPMessage : NSObject<NSCoding>
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) WPMessageType type;

/**
 消息对象转二进制数据
 @return 消息对象的二进制数据
 */
- (NSData *)messageData;
@end
